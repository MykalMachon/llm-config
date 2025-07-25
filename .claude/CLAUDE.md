# Language Tooling Preferences

## TypeScript / JavaScript

Below are some general guidelines for writing TypeScript / JavaScript
applications:

- When possible, use TypeScript for it's improved DX and type safety. Do not
  convert existing JavaScript to TypeScript unless asked.
- I prefer to use Deno when possible due to it's including formatting, linting,
  testing, and compiling features alongside a solid std lib.
- ALWAYS use async/await over chained `.then()` or `.catch()` handling or
  callback functions when using Promises.
- If the project is not using Deno, using node.js as a fallback is fine.

## Python

Below are some general guidelines for writing Python applications:

- I prefer to use uv as a replacement for pip, pipx, poetry, and virtualenv.
  It's faster, and is simpler to use.
- I prefer to use ruff as a linter for python as, like uv, it's faster than
  alternatives.

## Golang

Below are some general guidelines when writing golang applications:

- Follow the official Go style guide and use `gofmt` to format code consistently.
- Use `go mod` for dependency management and avoid vendoring unless absolutely necessary.
- Prefer composition over inheritance - use interfaces and embedding rather than complex type hierarchies.
- Handle errors explicitly and return them as the last return value from functions.
- Use meaningful variable and function names that clearly express intent.
- Keep functions small and focused on a single responsibility.
- Use context.Context for cancellation, timeouts, and passing request-scoped values.
- Prefer struct literals with field names for better readability and maintainability.
- Use channels for communication between goroutines rather than shared memory.
- Initialize structs with zero values when possible to avoid nil pointer dereferences.
- Use `go vet` and `golint` (or `golangci-lint`) for static analysis and linting.
- Write table-driven tests using subtests for comprehensive test coverage.
- Use meaningful package names that are short, clear, and not overly broad.
- Avoid init() functions unless absolutely necessary for package initialization.
- Use defer for cleanup operations like closing files or database connections.

# Bash Tools

Below is a list of bash tools that should be available to use:

- `gh` please use the github CLI whenever you may need to interact with GitHub.
- `git` for generic git commands if needed. IMPORTANT: you should always consult
  with the user before interacting with git directly.
- `docker` for interacting with OCI compliant containers. IMPORTANT: you should
  always consult with the user before pulling new containers or deleting
  containers

Please use the `--help` flag with any of these commands when needed.

# Code style & Philosophy

- In general, use tabs over spaces.
- Follow software engineering best practices and write consistent and DRY code.
- Prefer standard lib tooling over dependencies. Think of each dependency as an
  added liability.
- Prefer clear or "obvious" code over clever solutions.
- When writing tests
  - test what is _important_. Follow the practice of "Write tests. Not too many.
    Mostly integration."
  - test coverage % around 65-70% is totally fine. Past that has diminishing
    returns.

# Workflow

- Be sure to typecheck, lint, and format when you're done making a series of
  code changes.
- Prefer running single tests, and not the whole test suite when testing to
  improve performance.
