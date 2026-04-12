Invoke the code-simplifier agent to review and refine recently modified code for clarity, consistency, and maintainability while preserving all functionality.

Additional context from the user: $ARGUMENTS

Use the code-simplifier agent. If the user supplied specific files, focus the agent on those. If they supplied other instructions (e.g. "skip the tests", "only the auth module"), pass those along as part of the agent's prompt. If $ARGUMENTS is empty, let the agent default to recently modified code.
