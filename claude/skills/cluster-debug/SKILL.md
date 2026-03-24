---
name: cluster-debug
description: >
  Runbook for diagnosing issues on the mini1+mini2 cluster. Use when the user
  reports Ollama is down, Hermes gateway won't start, Thunderbolt SSH fails,
  GPU memory is full, models won't load, Telegram/Discord bot is unresponsive,
  or any infrastructure issue involving the two-Mac-Mini cluster.
allowed-tools: Read, Grep, Glob, Bash
user-invocable: true
metadata:
  author: SGridworks
  version: 1.0.0
  category: runbook
  tags: [infrastructure, ollama, hermes, thunderbolt, cluster, debugging]
---

# Cluster Debug Runbook

Two-Mac-Mini cluster: mini1 (Hermes) + mini2 (Ollama). Connected via Thunderbolt 4.

Read the symptom files in `symptoms/` for specific diagnosis procedures.

## Network Quick Reference

| Machine | Thunderbolt IP | User | Role |
|---------|---------------|------|------|
| mini1 | 10.0.5.1 | mini1-samwise | Hermes agent platform |
| mini2 | 10.0.5.2 | 2agents | Ollama inference, dev work |

**Never use 192.168.4.x** -- that's deprecated Wi-Fi.

## First Response Checklist

Run ALL of these before diagnosing. The pattern of pass/fail tells you which symptom to chase.

```bash
# 1. Thunderbolt link
ping -c 1 -W 2 10.0.5.1 && echo "PASS: Thunderbolt up" || echo "FAIL: Thunderbolt down"

# 2. Ollama
curl -s --max-time 5 http://10.0.5.2:11434/api/tags | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'PASS: Ollama up, {len(d.get(\"models\",[]))} models')" 2>/dev/null || echo "FAIL: Ollama not responding"

# 3. Hermes on mini1
ssh -o ConnectTimeout=5 mini1-samwise@10.0.5.1 'pgrep -fl hermes' 2>/dev/null && echo "PASS: Hermes running" || echo "FAIL: Hermes down"

# 4. LaunchAgents
launchctl list | grep -E 'hermes|ollama' | awk '{print "  "$3": pid="$1}' || echo "FAIL: no agents loaded"
```

## Symptom Routing

Based on checklist results, read the matching symptom file:

| Checklist result | Symptom file | Likely cause |
|---|---|---|
| Thunderbolt FAIL | `symptoms/thunderbolt-ssh-fail.md` | Cable, wrong IP/user, interface down |
| Ollama FAIL | `symptoms/ollama-oom.md` | OOM, competing process, crashed |
| Hermes FAIL | `symptoms/hermes-gateway-down.md` | Process died, config error, upstream dep |
| Telegram/Discord unresponsive but Hermes running | `symptoms/hermes-gateway-down.md` | Token issue, gateway.json stale |
| Everything PASS but user reports issue | Check Kimi API status, Ollama model loading, or application-layer bug |

**Read the symptom file fully** -- it has specific diagnosis commands and resolution steps. Do not improvise fixes without reading the file first.

## Key Paths

| What | Where |
|------|-------|
| Hermes config | `~/.hermes/config.yaml` |
| Hermes secrets | `~/.hermes/.env` |
| Hermes gateway config | `~/.hermes/gateway.json` |
| Hermes scripts | `~/.hermes/scripts/` |
| LaunchAgents | `~/Library/LaunchAgents/` |
| Ollama models | mini2 default Ollama path |
| Cost tracking | `~/.hermes/cost_log.json` |

## Quick Fixes (most common resolution per symptom)

If the symptom file diagnosis is straightforward, these are the go-to fixes:

**Ollama down:**
```bash
# Kill competing processes, restart Ollama, verify
pkill -f llama-server 2>/dev/null; pkill -f mlx 2>/dev/null
launchctl kickstart -k gui/$(id -u)/com.ollama.ollama
sleep 3
curl -s http://10.0.5.2:11434/api/tags | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'VERIFIED: {len(d.get(\"models\",[]))} models available')" 2>/dev/null || echo "STILL DOWN -- read symptoms/ollama-oom.md for deeper diagnosis"
```

**Hermes/Telegram down:**
```bash
# Restart Hermes gateway on mini1, verify
ssh mini1-samwise@10.0.5.1 'launchctl kickstart -k gui/$(id -u)/com.hermes.gateway'
sleep 5
ssh mini1-samwise@10.0.5.1 'pgrep -fl hermes' && echo "VERIFIED: Hermes restarted" || echo "STILL DOWN -- read symptoms/hermes-gateway-down.md"
```

**Thunderbolt SSH fails:**
```bash
# Check cable, wait for interface, verify
echo "1. Check physical Thunderbolt 4 cable on both Macs"
echo "2. Wait 10 seconds after reseat"
ping -c 1 -W 5 10.0.5.1 && echo "VERIFIED: Thunderbolt link restored" || echo "STILL DOWN -- read symptoms/thunderbolt-ssh-fail.md"
```

**Always verify after fixing.** If the verify command still shows DOWN, read the full symptom file for deeper diagnosis.

## Gotchas

1. **GPU memory is shared (16GB)** -- Ollama and llama-server cannot run simultaneously. Kill one before starting the other.
2. **SSH username differs** -- mini1 is `mini1-samwise`, mini2 is `2agents`. Getting this wrong = "Permission denied."
3. **Hermes requires venv activation** -- `cd ~/hermes-agent && source .venv/bin/activate && python cli.py gateway`
4. **Ollama auto-starts via LaunchAgent** -- if you kill it manually, `launchctl kickstart` to restart, not just running `ollama serve`.
5. **Kimi K2.5 is the primary LLM** -- if Kimi API is down, Hermes falls back but quality degrades. Check api.moonshot.ai status.
6. **Gemma3:12b is Q4_K_M quantized** -- fits in 16GB but barely. Loading a second model will OOM.
