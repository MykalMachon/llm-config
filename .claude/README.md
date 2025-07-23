# `.claude` Settings

This folder contains settings for Claude Code.

## Slash Commands (`.claude/commands/*`)

Copy these into your project OR your home directory 

```bash
cp llm-config/.claude/commands/* ~/.claude/commands

claude 
# you can use slash commands in here
```

## Model Context Protocol Setup (`.claude/.mcp.json`)

This should be copied into your project's home directory to get setup.

For example:

```bash
mkdir ~/projects/new-app/ 

cp ~/.claude/.mcp.json ~/projects/new-app/.mcp.json

claude 
# from within claude, the MCP servers will get picked up
```

## Additional Documentation

- [Common Claude Code Workflows](https://docs.anthropic.com/en/docs/claude-code/common-workflows)
- [Extended thinking in Claude Code](https://docs.anthropic.com/en/docs/claude-code/common-workflows#use-extended-thinking)
- [Resume Previous Conversations](https://docs.anthropic.com/en/docs/claude-code/common-workflows#resume-previous-conversations)
- [Running Claude in Parallel](https://docs.anthropic.com/en/docs/claude-code/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees)
- [Using MCP with Claude Code](https://docs.anthropic.com/en/docs/claude-code/mcp)