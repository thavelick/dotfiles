---
name: parse-claude-logs
description: Inspect Claude Code session logs (transcripts) for the current or another project. Use when the user explicitly asks to "look at the claude logs", "parse my session", "what did I ask claude", "show the transcript", "list claude sessions", or similar phrasings referencing Claude's own JSONL logs.
---

Run the script with `--help` to see all flags, then invoke it with the appropriate filters for the user's request.

```bash
~/.claude/skills/parse-claude-logs/parse_claude_logs --help
```

Default behavior: prints user messages, assistant text, and tool calls from the most-recently-modified session in the current working directory.

## Summarizing / classifying conversations

The first user message is usually a poor signal for what a session was actually about — preambles, `/clear` commands, and exploratory questions often precede the real task. To classify or summarize sessions, dispatch one or more `Agent` calls with `subagent_type: "general-purpose"` and `model: "haiku"` (summarization is cheap and high-volume — use Haiku, not the default).

Each agent should run the script itself (e.g. `parse_claude_logs --session <UUID> --user --assistant`) and report a 1-line summary of what was actually accomplished. Batch ~5-7 sessions per agent and run agents in parallel.
