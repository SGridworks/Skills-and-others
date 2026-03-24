# Improvement Strategies Catalog

Organized by target type. The agent selects strategies based on the current target and experiment history.

## Strategy Selection Rules

1. Start with low-risk, high-confidence strategies (category A)
2. Move to moderate strategies (category B) after A is exhausted
3. Try creative/radical strategies (category C) only when B is exhausted
4. Never repeat a strategy that was already tried and discarded (check results.tsv)
5. After 3 consecutive failures in one category, move to the next

## Per-Target Strategies

### test-speed

**A -- Low Risk:**
- Parallelize independent test files (jest `--maxWorkers`, pytest `-n auto`)
- Remove unnecessary `beforeEach`/`afterEach` that recreate state identically
- Replace synchronous file reads in tests with cached fixtures
- Use `jest.mock()` for slow external calls (network, DB) not already mocked
- Reduce `setTimeout`/`sleep` waits in async tests to minimum needed

**B -- Moderate:**
- Consolidate redundant test setup into shared fixtures
- Replace heavy test database with in-memory alternatives (SQLite)
- Optimize test discovery by restructuring test directories
- Use snapshot testing where deep equality checks are slow
- Batch related assertions to reduce test overhead

**C -- Creative:**
- Rewrite integration tests as focused unit tests where possible
- Profile test suite and target the slowest 10% specifically
- Implement test-level caching for deterministic computations

### build-time

**A -- Low Risk:**
- Enable persistent caching in bundler config
- Set `transpileOnly: true` for TypeScript in dev builds
- Exclude test files from production build
- Add `sideEffects: false` to package.json for tree shaking
- Use `esbuild-loader` instead of `ts-loader` / `babel-loader`

**B -- Moderate:**
- Split vendor chunk to improve cache hit rate
- Configure module resolution aliases to reduce search paths
- Enable incremental compilation in tsconfig
- Remove unused polyfills and transforms
- Parallelize compilation with thread-loader

**C -- Creative:**
- Restructure barrel exports to reduce import graph depth
- Replace dynamic imports with static where the target is known at build time
- Migrate config from JS to simpler JSON format

### lint-warnings

**A -- Low Risk:**
- Fix unused import warnings (`no-unused-vars`, `F401`)
- Add missing return type annotations
- Fix simple type errors (missing null checks, wrong types)
- Remove unused variables and parameters
- Fix inconsistent naming (camelCase vs snake_case)

**B -- Moderate:**
- Replace `any` types with proper type definitions
- Add missing error handling for promise rejections
- Fix accessibility warnings (missing alt text, aria labels)
- Resolve deprecation warnings by using updated APIs
- Fix complexity warnings by extracting helper functions

**C -- Creative:**
- Refactor complex conditionals into guard clauses
- Replace magic numbers with named constants
- Consolidate duplicate type definitions

### bundle-size

**A -- Low Risk:**
- Remove dead exports that no file imports
- Replace `import * as X` with named imports for tree shaking
- Remove unused CSS/style imports
- Ensure `sideEffects: false` is set for pure modules
- Remove development-only code behind `process.env.NODE_ENV` checks

**B -- Moderate:**
- Replace heavy utility libraries with native equivalents (e.g., lodash → native)
- Lazy-load routes and heavy components
- Move large constants to separate chunks loaded on demand
- Deduplicate shared code across chunks
- Optimize image/asset imports

**C -- Creative:**
- Rewrite hot-path code to avoid pulling in large dependency trees
- Extract rarely-used features into optional plugins
- Replace runtime type checking with build-time validation

### test-coverage

**A -- Low Risk:**
- Add tests for untested public functions/methods
- Add edge case tests (null, empty, boundary values)
- Cover error handling paths (catch blocks, error callbacks)
- Add tests for conditional branches not yet covered
- Test default parameter values

**B -- Moderate:**
- Add integration tests for untested API endpoints
- Test error recovery and retry logic
- Cover race condition scenarios in async code
- Add tests for configuration edge cases
- Test lifecycle hooks and cleanup paths

**C -- Creative:**
- Add property-based tests for pure functions
- Test state machine transitions exhaustively
- Add mutation testing to find weak test assertions

### shellcheck-issues

**A -- Low Risk:**
- Quote all variable expansions (`"$var"` not `$var`)
- Replace `backtick` command substitution with `$()`
- Add `set -euo pipefail` to scripts missing it
- Fix SC2086 (double-quote to prevent globbing)
- Use `[[ ]]` instead of `[ ]` for bash conditionals

**B -- Moderate:**
- Replace `echo` with `printf` for portable output
- Use arrays instead of word-splitting strings
- Fix SC2046 (quote command substitution to prevent splitting)
- Replace `which` with `command -v`
- Add proper error messages to exit calls

**C -- Creative:**
- Refactor complex pipelines into functions
- Replace `eval` with safer alternatives
- Restructure scripts to reduce global variable usage

## General Meta-Strategies

These apply across all targets:

1. **Profile first** -- Before optimizing, measure where time/size/errors concentrate
2. **80/20 rule** -- Target the top 20% of offenders for 80% of the improvement
3. **Compound gains** -- Small improvements stack multiplicatively across experiments
4. **Simplify to improve** -- Removing code often improves multiple metrics at once
5. **Read the warnings** -- Compiler/linter output often points directly to the fix
