#!/bin/sh
# Usage: heartbeat.sh start|success|failure  (reads the hook JSON on stdin; run_id = session_id)
EVENT="$1"; IN=$(cat)
SID=$(printf '%s' "$IN" | sed -n 's/.*"session_id":"\([^"]*\)".*/\1/p')
if [ "$EVENT" = "success" ] && printf '%s' "$IN" | grep -q '"background_tasks":\[[^]]'; then exit 0; fi
curl -fsS -m 5 -o /dev/null "https://api.drumbeats.io/v1/s-ping/<your-drumbeats-project-id>/nightly-dependency-audit/$EVENT?run_id=$SID" || true
exit 0
