# Symptom: Ollama Out of Memory / Model Won't Load

## Indicators
- `ollama run gemma3:12b` hangs or returns memory error
- `curl http://10.0.5.2:11434/api/generate` returns 500 or timeout
- System becomes sluggish on mini2

## Diagnosis

```bash
# Check what's using GPU memory
ps aux | grep -E 'ollama|llama-server|mlx' | grep -v grep

# Check Ollama loaded models
curl -s http://10.0.5.2:11434/api/ps | python3 -m json.tool

# Check system memory pressure
memory_pressure
```

## Resolution

1. **Kill competing processes** -- llama-server and Ollama cannot coexist:
   ```bash
   pkill -f llama-server
   pkill -f mlx
   ```

2. **Unload extra models** -- only gemma3:12b + nomic-embed-text should be loaded:
   ```bash
   # List loaded models
   curl -s http://10.0.5.2:11434/api/ps
   # If extra models loaded, restart Ollama to clear
   launchctl kickstart -k gui/$(id -u)/com.ollama.ollama
   ```

3. **If Ollama itself is crashed**:
   ```bash
   launchctl list | grep ollama  # check if loaded
   launchctl kickstart -k gui/$(id -u)/com.ollama.ollama
   # Wait 5 seconds, then verify
   curl -s http://10.0.5.2:11434/api/tags
   ```

4. **Nuclear option** -- full restart:
   ```bash
   launchctl bootout gui/$(id -u)/com.ollama.ollama
   sleep 2
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.ollama.ollama.plist
   ```
