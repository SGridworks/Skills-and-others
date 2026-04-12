# Symptom: Hermes Gateway Not Responding

## Indicators
- Telegram bot (@Samwise_automation_bot) not responding to messages
- Discord bot offline
- `ssh mini1-samwise@10.0.5.1 'pgrep -f hermes'` returns nothing

## Diagnosis

```bash
# Check if Hermes process is running on mini1
ssh mini1-samwise@10.0.5.1 'pgrep -fl hermes'

# Check LaunchAgent status
ssh mini1-samwise@10.0.5.1 'launchctl list | grep hermes'

# Check recent logs
ssh mini1-samwise@10.0.5.1 'tail -50 ~/.hermes/logs/gateway.log 2>/dev/null || echo "no log file"'

# Check if the venv exists
ssh mini1-samwise@10.0.5.1 'ls ~/hermes-agent/.venv/bin/python3'
```

## Resolution

1. **Restart via LaunchAgent**:
   ```bash
   ssh mini1-samwise@10.0.5.1 'launchctl kickstart -k gui/$(id -u)/com.hermes.gateway'
   ```

2. **Manual start** (if LaunchAgent isn't working):
   ```bash
   ssh mini1-samwise@10.0.5.1 'cd ~/hermes-agent && source .venv/bin/activate && nohup python cli.py gateway &'
   ```

3. **Check config** -- common issues:
   - `~/.hermes/.env` missing API keys (MOONSHOT_API_KEY, TELEGRAM_BOT_TOKEN)
   - `~/.hermes/config.yaml` has wrong Ollama URL (should be 10.0.5.2:11434)
   - `~/.hermes/gateway.json` has stale Telegram/Discord tokens

4. **Check upstream dependencies**:
   - Is Ollama reachable from mini1? `ssh mini1-samwise@10.0.5.1 'curl -s http://10.0.5.2:11434/api/tags | head'`
   - Is Kimi API up? `curl -s https://api.moonshot.ai/v1/models -H "Authorization: Bearer $MOONSHOT_API_KEY"`
