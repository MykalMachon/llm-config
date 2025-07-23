---
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(gh *)
description: Review the changes on this branch. Provide a summary of what you're trying to achieve.
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- User Provided summary of changes: $ARGUMENTS.

## Your Task

Image you are a senior tech lead and review the code changes in this repository.

Think about how the code changes solve the problem and keep the following in mind:

- **Maintainability**: include code readability and clarity. Simple over clever always!
- **Testability**: how testable is this approach? if the project has tests, are they updated.
- **Security considerations**: ensure that code changes are secure and identify any possible issues.
- **Performance implications**: ensure that the code is performant within reason. Identify large issues.
- **Adherence to existing patterns**: ensure that all changes adhere to existing patterns.
- **Identify breaking changes**: note them if they exist.

When providing your review to the user, follow this format:

- **Summary:** Brief overview of changes.
- **Strengths:** What's done well.
- **Issues:** Problems that need addressing.
- **Suggestions:** Improvements or alternatives:
  - check for missing tests for new functionality.
  - Documentation updates needed.
  - Proper error handling and edge case coverage.

Ensure that you're focussing on significant changes and try not to get stuck on minor style issues. Linters and formatters should catch style issues.
