---
name: cluster-ops
description: >
  Routine maintenance operations for the mini1+mini2 cluster. Use when the user
  wants to check cluster health, manage Ollama models, restart LaunchAgents,
  check disk space, view LLM cost tracking, or perform any routine infrastructure
  maintenance on the two-Mac-Mini cluster.
allowed-tools: Read, Grep, Glob, Bash
user-invocable: true
metadata:
  author: SGridworks
  version: 1.0.0
  category: infrastructure-ops
  tags: [cluster, ollama, hermes, launchagent, maintenance, infrastructure]
---

# Cluster Operations

Routine maintenance for the mini1 (Hermes) + mini2 (Ollama) cluster.

For troubleshooting, use `/cluster-debug` instead.

## Health Check

Run all of these to get a quick cluster status:

```bash
# Thunderbolt link
ping -c 1 -W 1 10.0.5.1 && echo "mini1: UP" || echo "mini1: DOWN"

# Ollama status + loaded models
curl -s http://10.0.5.2:11434/api/tags | python3 -c "import sys,json; d=json.load(sys.stdin); [print(f'  {m[\"name\"]}: {m.get(\"size\",0)/1e9:.1f}GB') for m in d.get('models',[])]" 2>/dev/null || echo "Ollama: DOWN"

# Hermes process on mini1
ssh mini1-samwise@10.0.5.1 'pgrep -fl hermes 2>/dev/null || echo "Hermes: NOT RUNNING"'

# LaunchAgents
launchctl list | grep -E 'hermes|ollama' | awk '{print "  "$3": pid="$1}'

# Disk space (local)
df -h / | tail -1 | awk '{print "Disk: "$4" free ("$5" used)"}'
```

## Ollama Model Management

```bash
# List models
curl -s http://10.0.5.2:11434/api/tags | python3 -m json.tool

# Currently loaded (in VRAM)
curl -s http://10.0.5.2:11434/api/ps | python3 -m json.tool

# Pull a new model (careful: GPU memory is 16GB shared)
ollama pull <model>

# Delete a model
ollama rm <model>
```

**Active models**: gemma3:12b (primary), nomic-embed-text (embeddings)
**Memory budget**: 16GB shared. Only one large model at a time.

## LaunchAgent Management

```bash
# List all custom agents
ls ~/Library/LaunchAgents/com.{hermes,ollama,mini2}*

# Restart Ollama
launchctl kickstart -k gui/$(id -u)/com.ollama.ollama

# Restart Hermes (on mini1)
ssh mini1-samwise@10.0.5.1 'launchctl kickstart -k gui/$(id -u)/com.hermes.gateway'

# Stop a service
launchctl bootout gui/$(id -u)/com.ollama.ollama

# Start a service
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.ollama.ollama.plist
```

## Cost Tracking

```bash
# View LLM routing cost log
python3 -c "
import json
with open('/Users/2agents/.hermes/cost_log.json') as f:
    data = json.load(f)
total = sum(t.get('cost', 0) for t in data)
by_model = {}
for t in data:
    m = t.get('model', 'unknown')
    by_model[m] = by_model.get(m, 0) + t.get('cost', 0)
print(f'Total cost: \${total:.4f}')
for m, c in sorted(by_model.items(), key=lambda x: -x[1]):
    print(f'  {m}: \${c:.4f}')
" 2>/dev/null || echo "No cost log found"
```

## Hermes Scripts

Existing automation scripts in `~/.hermes/scripts/`:
- Email: auto_label_newsletters, cleanup_categories, daily_triage, newsletter_digest
- Routing: hermes_router, ceo_quality_gate, ceo_router, gemma_auto, llm_router
- Ops: generate_image, handoff_integration

## Gotchas

1. **Never run llama-server and Ollama simultaneously** -- they fight over GPU memory.
2. **Restart via launchctl, not process kill** -- launchctl manages the lifecycle.
3. **mini1 SSH user is mini1-samwise** -- not 2agents.
4. **Cost log path**: `~/.hermes/cost_log.json` (hermes_router) and `~/.hermes/cost_tracker.json` (llm_router). Two separate files.
