# Kiwix Server Setup

Kiwix server is not available via Homebrew for Apple Silicon, so we build from source.

## Building from Source

```bash
# Clone repos
mkdir -p ~/src
cd ~/src
git clone https://github.com/kiwix/kiwix-build
git clone https://github.com/kiwix/kiwix-tools

# Install kiwix-build in virtualenv
cd kiwix-build
python3 -m venv venv
source venv/bin/activate
pip install .

# Build kiwix-tools (includes kiwix-serve)
kiwix-build kiwix-tools

# Copy binary to PATH
cp ~/src/kiwix-build/BUILD_native_dyn/INSTALL/bin/kiwix-serve ~/.local/bin/
```

## Running

```bash
# Download ZIM file to ~/kiwix/
kiwix-serve --port 8080 ~/kiwix/yourfile.zim
```

Access at http://localhost:8080
