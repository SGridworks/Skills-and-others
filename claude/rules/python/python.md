---
paths:
  - "**/*.py"
---

# Python Rules

- Use type hints on all function signatures
- Use `pathlib.Path` over `os.path`
- Use f-strings for string formatting
- Use dataclasses or Pydantic models for structured data
- Use `contextlib` for resource management
- Prefer comprehensions over manual loops when clear
- Use `logging` module, not `print()` for production code
- Handle exceptions specifically — never bare `except:`
- Use `pytest` for testing with fixtures and parametrize
- Use `ruff` for linting and formatting
