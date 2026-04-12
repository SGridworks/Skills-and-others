# Symptom: Thunderbolt SSH Connection Failed

## Indicators
- `ssh mini1-samwise@10.0.5.1` hangs or refuses connection
- `ping 10.0.5.1` fails (no response)
- "Permission denied" errors

## Diagnosis

```bash
# Is the Thunderbolt interface up?
ifconfig | grep -A5 bridge

# Can we reach mini1 at all?
ping -c 3 10.0.5.1

# Is it a username issue?
# mini1 user is mini1-samwise, NOT 2agents
ssh -v mini1-samwise@10.0.5.1

# Check SSH keys
ls -la ~/.ssh/id_* ~/.ssh/authorized_keys
```

## Common Causes

### 1. Wrong username
- mini1: `mini1-samwise@10.0.5.1`
- mini2: `2agents@10.0.5.2`
- **Never use `2agents@10.0.5.1`** -- different user on each machine

### 2. Wrong IP subnet
- Use `10.0.5.x` (Thunderbolt) -- NOT `192.168.4.x` (deprecated Wi-Fi)
- mini1: 10.0.5.1
- mini2: 10.0.5.2

### 3. Thunderbolt cable disconnected
- Physical check: is the Thunderbolt 4 cable seated on both ends?
- After reconnect, interfaces may take 5-10 seconds to come up
- Verify: `ifconfig | grep -A2 bridge` should show 10.0.5.x

### 4. SSH key not authorized on mini1
- mini1 authorized_keys location: `/Users/mini1-samwise/.ssh/authorized_keys`
- Copy key: `ssh-copy-id mini1-samwise@10.0.5.1` (if password auth works)

## Resolution

1. Verify correct username + IP
2. Check physical cable
3. Wait 10 seconds after cable reseat
4. `ping 10.0.5.1` to confirm link
5. `ssh mini1-samwise@10.0.5.1` with correct user
