Two files that make a Claude Code scheduled task send start, success and failure heartbeats to a Drumbeats monitor through hooks.

**This repository accompanies the Drumbeats article [A heartbeat for Claude Code scheduled tasks](https://drumbeats.io/blog/monitor-claude-code-scheduled-tasks). Read it there first; this README only covers using the files.**

## Use it

1. Create a Drumbeats monitor with the slug `nightly-dependency-audit` (or change the slug in the script). Create it first: a ping to a slug that does not exist returns "Monitor not found".
2. Put your Drumbeats project id in `.claude/hooks/heartbeat.sh` in place of `<your-drumbeats-project-id>`.
3. Commit `.claude/settings.json` and `.claude/hooks/heartbeat.sh` (executable) into the repository the Claude Code scheduled task runs in.

## Which hook sends which ping

| Hook | Ping |
|---|---|
| `SessionStart` | `start` |
| `Stop` | `success` (skipped while the session is only paused for background tasks) |
| `StopFailure` | `failure` |

Every ping carries `run_id` = the hook's `session_id`, so the start and the finish of one run meet on the monitor. The script always exits 0, so a monitoring failure never blocks the session from stopping. Hook timeout is 10 s; `curl` gives up after 5 s.

## Network allowlist

A cloud scheduled task's shell runs behind a network allowlist, and `api.drumbeats.io` is not in the default list. Add it (Custom, with "Also include default list" checked), or the `curl` in the script fails silently.

## Observed run

From the article: `claude -p` in a directory with these two files, with an expired CLI token.

```text
START    run_id=0e9ab6fd-1fbd-45a3-b9ad-86b6240ff261   21:43:35.423 UTC
FAILURE  run_id=0e9ab6fd-1fbd-45a3-b9ad-86b6240ff261   21:43:39.664 UTC   duration_ms=4240
```

`SessionStart` fired before authentication, `StopFailure` fired on `API Error: 401 OAuth access token has expired`, and the failure ping opened an incident.

## Licence

MIT, see [LICENSE](LICENSE).
