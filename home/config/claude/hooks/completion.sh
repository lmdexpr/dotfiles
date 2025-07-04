#!/bin/bash

SESSION_ID=$(jq -r '.session_id')
STOP_HOOK_ACTIVE=$(jq -r '.stop_hook_active')

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

PROJECT_NAME=$(basename "$PWD")

terminal-notifier \
    -title "Claude Code 🤖" \
    -subtitle "プロジェクト: $PROJECT_NAME" \
    -message "処理が完了しました (Session: ${SESSION_ID:0:8})" \
    -sound "Blow" \
    -group "claude-code-completion"
