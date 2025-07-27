#!/usr/bin/env python3
import sys
import importlib
import pkgutil

def get_module_items(module_name):
    """Get categorized items from a module."""
    try:
        module = importlib.import_module(module_name)
        items = [x for x in dir(module) if not x.startswith('_')]
        
        classes = []
        functions = []
        others = []
        submodules = []
        
        # Get regular items
        for item in items:
            obj = getattr(module, item)
            if hasattr(obj, '__class__') and obj.__class__.__name__ == 'type':
                classes.append(item)
            elif callable(obj) and not (hasattr(obj, '__class__') and obj.__class__.__name__ == 'type'):
                functions.append(item)
            else:
                others.append(item)
        
        # Get submodules if this is a package
        if hasattr(module, '__path__'):
            for finder, name, ispkg in pkgutil.iter_modules(module.__path__):
                submodules.append(name)
        
        return classes, functions, others, submodules
    except ImportError as e:
        print(f"Could not import {module_name}: {e}")
        sys.exit(1)

def show_fzf_items(module_name):
    """Output items for fzf selection."""
    classes, functions, others, submodules = get_module_items(module_name)
    
    # Output format: "type:name"
    for item in classes:
        print(f"class:{item}")
    for item in functions:
        print(f"function:{item}")
    for item in others:
        print(f"other:{item}")
    for item in submodules:
        print(f"submodule:{item}")

def show_module_summary(module_name):
    """Show a summary of available items in a module."""
    classes, functions, others, submodules = get_module_items(module_name)
    
    print(f"# {module_name}")
    print()
    
    if submodules:
        print("## Submodules")
        for sub in submodules:
            print(f"- `{sub}`")
        print()
    
    if classes:
        print("## Classes")
        for cls in classes:
            print(f"- `{cls}`")
        print()
    
    if functions:
        print("## Functions")
        for func in functions:
            print(f"- `{func}`")
        print()
    
    if others:
        print("## Other")
        for other in others:
            print(f"- `{other}`")
        print()
    
    print(f"Use `help python {module_name}.ClassName` for specific help.")

def show_object_help(module_name, object_name):
    """Show help for a specific object in a module."""
    try:
        # First try to import as a submodule (e.g., unittest.mock)
        full_module_name = f"{module_name}.{object_name}"
        try:
            module = importlib.import_module(full_module_name)
            help(module)
            return
        except ImportError:
            pass
        
        # If that fails, try as an attribute of the module
        module = importlib.import_module(module_name)
        obj = getattr(module, object_name)
        help(obj)
    except (ImportError, AttributeError) as e:
        print(f"Could not get help for {module_name}.{object_name}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python_help.py <module> [--fzf|--summary] or <module.object>")
        sys.exit(1)
    
    target = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) > 2 else None
    
    if '.' in target:
        module_name, object_name = target.split('.', 1)
        show_object_help(module_name, object_name)
    elif mode == '--fzf':
        show_fzf_items(target)
    elif mode == '--summary':
        show_module_summary(target)
    else:
        show_module_summary(target)