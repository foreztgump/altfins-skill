# Code Quality Principles

Single source of truth for code quality standards in this project.
Referenced by: CLAUDE.md, .coderabbit.yaml, OpenSpec task rules.

## Hard Rules (Must Follow)

### 1. Single Responsibility
Every function does one thing. If you need "and" in its description, split it.
Scripts: one primary action per script. Shared logic goes in `_lib.sh`.

### 2. No Magic Values
All literals that aren't self-evident must be named constants (`readonly` in bash).
URLs, timeouts, defaults, file paths — all in `_lib.sh` constants.

### 3. Descriptive Names
Names reveal intent. No abbreviations, no generic names (data, info, item, temp).
Functions: `verb_noun` pattern (e.g., `make_api_request`, `check_http_status`).
Variables: `snake_case`, descriptive (e.g., `from_date`, `page_content`).

### 4. Error Handling at Boundaries
Every `curl` call must check HTTP status. Every `jq` parse must handle invalid input.
Use `set -euo pipefail` in every script. Use `check_http_status` for API responses.

### 5. Maximum Limits
- Functions: 40 lines max
- Parameters: 5 max per function (use structured input for more)
- Nesting: 3 levels max — use early returns and guard clauses
- Script args: use `--flag value` pattern, not positional (except mode as $1)

### 6. No Duplication
Extract shared behavior into `_lib.sh` functions. If you copy-paste 5+ lines, extract.

### 7. YAGNI
Only build what the current task requires. No speculative abstractions.
No "might need later" features. No optional parameters nobody asked for.

### 8. KISS
Pick the simplest solution that works. `curl | jq` over custom parsers.
Shell builtins over external tools where equivalent. No unnecessary indirection.

### 9. Comments Explain Why, Not What
Code should be self-documenting for the what. Comments are for:
- Why a non-obvious decision was made
- What gotcha or assumption exists
- Security boundaries and trust decisions

### 10. Secure by Default
- Build JSON with `jq`, never string interpolation
- Never log or echo API keys
- Validate all user input before use
- Atomic writes via mktemp + mv for persistence files
- Single endpoint, single credential pattern

### 11. Consistent Error Reporting
Errors to stderr. Data to stdout. Never mix.
Exit codes: 0 = success, 1 = error. Clear error messages with context.

## Soft Guidelines (Prefer)

### A. Deep Modules
Simple interface (CLI flags), complex implementation hidden behind it.
Users see `--symbol BTC --type RSI14`. They don't see pagination, caching, error handling.

### B. Composition Over Inheritance
Source `_lib.sh` for shared functions. Don't build class hierarchies.
Each script is self-contained after sourcing the library.

### C. Strategic Programming
Spend time on good interfaces. A well-designed `_lib.sh` function saves hours.
Invest in the library; scripts should be thin wrappers.

### D. Law of Demeter
Talk to direct collaborators only. Scripts call `_lib.sh` functions.
`_lib.sh` calls `curl` and `jq`. No chain: script → lib → other-lib → tool.

### E. Arrange-Act-Assert in Tests
Each test covers one behavior. Test name describes expected behavior.
Mock `curl` responses — don't hit real API in CI.

### F. Fail Fast
Validate required parameters at script start, before any API calls.
Use `${VAR:?error message}` pattern for required env vars.

### G. Idempotent Operations
Cache reads are safe to retry. Reference data (symbols, intervals) is cached.
No side effects from read operations.

### H. Defensive JSON Processing
Always use `// empty` or `// "N/A"` fallbacks in jq for optional fields.
Never assume a field exists in API responses — the schema may change.
