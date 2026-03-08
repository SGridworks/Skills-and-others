# YAML Frontmatter Reference

Complete specification for SKILL.md frontmatter fields.

## Required Fields

### name
- Type: string
- Format: kebab-case only (e.g., `my-cool-skill`)
- Rules: no spaces, no capitals, no underscores, must match folder name
- Reserved: cannot contain "claude" or "anthropic"

### description
- Type: string
- Max length: 1024 characters
- Must include: what it does + when to use it (trigger phrases)
- Should include: when NOT to use it (negative triggers)
- Forbidden: XML angle brackets (< >)
- Format: `[What it does]. Use when [triggers]. Do NOT use for [negative triggers].`

## Optional Fields

### allowed-tools
- Type: string
- Format: space-separated tool names with optional argument restrictions
- Examples:
  - `"Read Grep Glob"` -- read-only tools
  - `"Bash(python:*) Bash(npm:*) WebFetch"` -- restricted Bash access
  - `"Read Grep Glob Edit Write Bash"` -- full access
- Purpose: restrict which tools the skill can use

### model
- Type: string
- Values: `sonnet`, `haiku`, `inherit`, `opus`
- Default: inherit (uses the session's current model)
- Guidance: use `haiku` for simple/fast tasks, `sonnet` for analysis, `inherit` for complex work

### user-invocable
- Type: boolean
- Default: true
- Set to `false` for background knowledge skills that only Claude triggers

### arguments
- Type: string
- Description of expected arguments
- Accessed in body via `$ARGUMENTS`, `$0`, `$1`, etc.

### compatibility
- Type: string (1-500 characters)
- Environment requirements: required packages, OS, network access, etc.

### license
- Type: string
- Common values: `MIT`, `Apache-2.0`
- Use for open-source skills

### metadata
- Type: object (key-value pairs)
- Suggested fields:
  - `author`: creator name or organization
  - `version`: semantic version (1.0.0)
  - `mcp-server`: required MCP server name
  - `category`: skill category
  - `tags`: array of searchable tags
  - `documentation`: URL to external docs
  - `support`: support contact

## Security Restrictions

Forbidden in frontmatter:
- XML angle brackets (< >) -- could inject into system prompt
- Code execution in YAML -- uses safe YAML parsing
- Skills named with "claude" or "anthropic" prefix -- reserved by Anthropic
