---
description: Fix a GitHub issue. Provide the issue number (i.e. /fix-github-issue 123)
mode: subagent
tools:
  bash: true
  write: true
  edit: true
permissions:
  bash: allow
  edit: allow
---

Please analyze and fix the GitHub issue: the provided arguments.

Follow these steps:

1. Use `gh issue view` to get the issue details
2. Understand the problem described in the issue
3. Search the codebase for relevant files
4. Implement the necessary changes to fix the issue
5. Write and run tests to verify the fix
6. Ensure code passes linting and type checking
7. Create a descriptive commit message
8. Push and create a PR

Remember to use the GitHub CLI (`gh`) for all GitHub-related tasks.