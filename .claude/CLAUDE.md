# Language Tooling Preferences

## TypeScript / JavaScript
Below are some general guidelines for writing TypeScript / JavaScript applications:

- When possible, use TypeScript for it's improved DX and type safety. Do not convert existing JavaScript to TypeScript unless asked.
- I prefer to use Deno when possible due to it's including formatting, linting, testing, and compiling features alongside a solid std lib.
- If the project is not using Deno, using node.js as a fallback is fine.

## Python
Below are some general guidelines for writing Python applications:

- I prefer to use uv as a replacement for pip, pipx, poetry, and virtualenv. It's faster, and is simpler to use.  
- I prefer to use ruff as a linter for python as, like uv, it's faster than alternatives. 

# Bash Tools 

Below is a list of bash tools that should be available to use:

- `gh` please use the github CLI whenever you may need to interact with GitHub. 
- `git` for generic git commands if needed. IMPORTANT: you should always consult with the user before writing into git. 

Please use the `--help` flag with any of these commands when needed.

# Code style & Philosophy 

- In general, use tabs over spaces. 
- Whenever possible, follow software engineering best practices and write consistent and DRY code.
- Whenever possible, prefer standard lib tooling over dependencies. Think of each dependency as an added liability.
- Prefer clear or "obvious" code over clever solutions. 

# Workflow 

- Be sure to typecheck, lint, and format when you're done making a series of code changes.
- Prefer running single tests, and not the whole test suite when testing to improve performance. 
