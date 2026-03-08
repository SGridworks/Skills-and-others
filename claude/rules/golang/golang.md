# Go Rules

- Use `context.Context` as the first parameter in functions that do I/O
- Return errors explicitly -- never ignore with `_`
- Wrap errors with `fmt.Errorf("context: %w", err)` for stack traces
- Use `errors.Is` and `errors.As` for error checking, not string comparison
- Prefer table-driven tests with `t.Run` subtests
- Use `t.Helper()` in test helper functions
- No `init()` functions -- use explicit initialization
- Use `golangci-lint` for linting
- Run `go test -race ./...` to detect data races
- Use struct embedding for composition, not inheritance patterns
- Prefer interfaces at the consumer, not the producer
- Use `sync.Once` for lazy initialization, not `init()`
- Channel direction in function signatures (`chan<-`, `<-chan`)
