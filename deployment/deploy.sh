#!/bin/bash
set -e

# === Diese drei Pfade vor dem Einsatz anpassen ===
REPO_DIR="[PFAD-ZUM-REPO]"
WEB_DIR="[PFAD-WWW]"
LOG="[PFAD-ZUM-WEBHOOK]/deploy.log"

echo "$(date): Deploy gestartet" >> "$LOG"

cd "$REPO_DIR"
git pull origin main >> "$LOG" 2>&1

tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --minify >> "$LOG" 2>&1

hugo --minify -d "$WEB_DIR" >> "$LOG" 2>&1

echo "$(date): Deploy erfolgreich" >> "$LOG"
