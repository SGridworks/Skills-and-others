# Go Microservice (gRPC + PostgreSQL)

## Stack
- Go 1.22+
- gRPC + Protocol Buffers
- PostgreSQL + sqlc
- Wire (dependency injection)
- Docker + docker-compose

## Critical Rules
- Context as first parameter: `func Foo(ctx context.Context, ...)`
- Error wrapping with `fmt.Errorf("operation: %w", err)` — never `%v` for errors
- No `init()` functions — use explicit initialization
- No global mutable state
- Table-driven tests for all logic
- Race detection in CI: `go test -race ./...`
- Always close database rows: `defer rows.Close()`

## Project Structure

```
cmd/
  server/            # Main entry point
internal/
  domain/            # Business logic (no external dependencies)
  handler/           # gRPC handlers
  repository/        # Database access (sqlc generated)
  service/           # Application services
proto/               # Protocol Buffer definitions
migrations/          # SQL migrations
```

## Commands

- `go build ./...` — Build
- `go test ./...` — Unit tests
- `go test -race ./...` — Race detection
- `golangci-lint run` — Lint
- `sqlc generate` — Regenerate DB code
- `buf generate` — Regenerate gRPC code
- `docker-compose up -d` — Start dependencies
