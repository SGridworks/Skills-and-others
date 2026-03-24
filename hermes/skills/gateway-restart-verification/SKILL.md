---
name: gateway-restart-verification
description: Verify messaging platform connectivity after any gateway restart
category: infrastructure
---

# Gateway Restart Verification

## Trigger
After any `hermes gateway restart` or gateway process restart.

## Steps

1. After `hermes gateway restart`, wait 5 seconds
2. Run: `tail -30 ~/.hermes/logs/gateway.log | grep -i "telegram\|connected\|polling\|failed"`
3. Confirm `[Telegram] Connected and polling for Telegram updates` appears
4. Confirm `✓ telegram connected` appears
5. If Telegram failed: grep log for the specific error, kill blocking PID if token lock, restart again
6. Also verify Discord: confirm `✓ discord connected` if Discord is in use
7. Report status to user

## Pitfalls

- Gateway may fail to grab Telegram token if another instance (PID) still holds it
- Token lock error looks like: `Another local Hermes gateway is already using this Telegram bot token (PID NNNNN)`
- Fix: kill the blocking PID, then `hermes gateway restart` again
- Always wait 5 seconds before checking logs -- connection is async

## Verification

- Telegram: `Connected and polling` + `telegram connected` in gateway.log
- Discord: `discord connected` in gateway.log
- Both platforms should show connected, not failed
