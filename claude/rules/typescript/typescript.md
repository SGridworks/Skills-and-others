# TypeScript Rules

- Use strict mode (`"strict": true` in tsconfig)
- Prefer `interface` over `type` for object shapes
- Use `unknown` over `any` — narrow with type guards
- Use `const` by default, `let` only when reassignment is needed
- Use Zod or similar for runtime validation of external data
- Prefer `async/await` over raw Promises
- Handle all Promise rejections
- Use discriminated unions for state management
- Prefer `Map`/`Set` over plain objects for dynamic keys
- No `!` non-null assertions except in tests
