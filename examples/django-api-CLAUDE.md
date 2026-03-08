# Django REST API (DRF + Celery)

## Stack
- Python 3.12+
- Django 5.x + Django REST Framework
- Celery + Redis (async tasks)
- PostgreSQL
- pytest + factory_boy

## Critical Rules
- ALL views MUST have explicit permission classes
- ALL querysets MUST be filtered by tenant/user — no unscoped queries
- Use `select_related()` / `prefetch_related()` to prevent N+1 queries
- Serializer validation for ALL input — never trust `request.data` directly
- Celery tasks MUST be idempotent
- Database migrations reviewed before merging

## Project Structure

```
config/              # Django settings, URLs, WSGI/ASGI
apps/
  users/             # User management
  core/              # Shared models, mixins, utils
  api/               # API versioning (v1/, v2/)
tasks/               # Celery task definitions
tests/
  factories/         # factory_boy factories
  fixtures/          # Test data
```

## Commands

- `python manage.py runserver` — Dev server
- `pytest` — Run tests
- `pytest --cov --cov-report=term` — Coverage
- `ruff check .` — Lint
- `ruff format .` — Format
- `mypy .` — Type check
- `python manage.py migrate` — Apply migrations
- `celery -A config worker -l info` — Start Celery worker
