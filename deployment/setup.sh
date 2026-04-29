#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
OUTDIR="$SCRIPT_DIR/_output"
mkdir -p "$OUTDIR"

echo "=== blog.weitzelnet.com — Deployment-Setup ==="
echo ""

read -p "Pfad zum geklonten Repository  [REPO-PFAD]:     " REPO_DIR
read -p "Pfad zum Webroot              [WWW-PFAD]:        " WEB_DIR
read -p "Pfad für Webhook-Dateien      [WEBHOOK-PFAD]:    " HOOK_DIR
read -p "System-Benutzer für Service   [BENUTZER]:        " SVC_USER
read -p "Deine Domain                  [DOMAIN]:           " DOMAIN

echo ""
read -p "Webhook-Secret (Enter = auto-generieren): " HOOK_SECRET
if [ -z "$HOOK_SECRET" ]; then
  HOOK_SECRET=$(openssl rand -hex 32)
  echo "  Generiert: $HOOK_SECRET"
fi

read -p "Geheimer URL-Pfad (Enter = auto-generieren): " SECRET_PATH
if [ -z "$SECRET_PATH" ]; then
  SECRET_PATH=$(openssl rand -hex 8)
  echo "  Generiert: $SECRET_PATH"
fi

echo ""
echo "=== Zusammenfassung ==="
echo "Repository:        $REPO_DIR"
echo "Webroot:           $WEB_DIR"
echo "Webhook-Verz.:     $HOOK_DIR"
echo "Benutzer:          $SVC_USER"
echo "Domain:            $DOMAIN"
echo "Webhook-Secret:    $HOOK_SECRET"
echo "Geheimer Pfad:     $SECRET_PATH"
echo ""

read -p "Passt das? (j/N) " CONFIRM
if [ "$CONFIRM" != "j" ] && [ "$CONFIRM" != "J" ]; then
  echo "Abgebrochen."
  exit 0
fi

# ------------------------------------------------------------------
# 1. deploy.sh
# ------------------------------------------------------------------
cat > "$OUTDIR/deploy.sh" << 'SCRIPT'
#!/bin/bash
set -e

REPO_DIR="[REPO-PFAD]"
WEB_DIR="[WWW-PFAD]"
LOG="[WEBHOOK-PFAD]/deploy.log"
DOMAIN="[DOMAIN]"

command -v git >/dev/null 2>&1  || { echo "FEHLER: git nicht gefunden" >&2; exit 1; }
command -v node >/dev/null 2>&1 || { echo "FEHLER: node nicht gefunden" >&2; exit 1; }
command -v npm >/dev/null 2>&1  || { echo "FEHLER: npm nicht gefunden" >&2; exit 1; }
command -v hugo >/dev/null 2>&1 || { echo "FEHLER: hugo nicht gefunden" >&2; exit 1; }

echo "$(date): Deploy gestartet" >> "$LOG"

cd "$REPO_DIR"
git pull origin main >> "$LOG" 2>&1

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

npm install >> "$LOG" 2>&1
npm run build:css >> "$LOG" 2>&1

hugo --minify -d "$WEB_DIR" --baseURL "https://$DOMAIN" >> "$LOG" 2>&1

echo "$(date): Deploy erfolgreich" >> "$LOG"
SCRIPT

sed -i "s|\[REPO-PFAD\]|$REPO_DIR|g" "$OUTDIR/deploy.sh"
sed -i "s|\[WWW-PFAD\]|$WEB_DIR|g" "$OUTDIR/deploy.sh"
sed -i "s|\[WEBHOOK-PFAD\]|$HOOK_DIR|g" "$OUTDIR/deploy.sh"
sed -i "s|\[DOMAIN\]|$DOMAIN|g" "$OUTDIR/deploy.sh"
chmod +x "$OUTDIR/deploy.sh"

# ------------------------------------------------------------------
# 2. hooks.json
# ------------------------------------------------------------------
cat > "$OUTDIR/hooks.json" << 'JSON'
[
  {
    "id": "deploy-blog",
    "execute-command": "[WEBHOOK-PFAD]/scripts/deploy.sh",
    "response-message": "Deployment gestartet",
    "trigger-rule": {
      "and": [
        {
          "match": {
            "type": "payload-hmac-sha256",
            "secret": "[WEBHOOK-SECRET]",
            "parameter": {
              "source": "header",
              "name": "X-Hub-Signature-256"
            }
          }
        },
        {
          "match": {
            "type": "value",
            "value": "refs/heads/main",
            "parameter": {
              "source": "payload",
              "name": "ref"
            }
          }
        }
      ]
    }
  }
]
JSON

sed -i "s|\[WEBHOOK-PFAD\]|$HOOK_DIR|g" "$OUTDIR/hooks.json"
sed -i "s|\[WEBHOOK-SECRET\]|$HOOK_SECRET|g" "$OUTDIR/hooks.json"

# ------------------------------------------------------------------
# 3. webhook.service
# ------------------------------------------------------------------
cat > "$OUTDIR/webhook.service" << 'UNIT'
[Unit]
Description=GitHub Webhook Server
After=network.target

[Service]
Type=simple
User=[BENUTZER]
WorkingDirectory=[WEBHOOK-PFAD]
ExecStart=/usr/bin/webhook -hooks [WEBHOOK-PFAD]/hooks.json -verbose -port 9000
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT

sed -i "s|\[WEBHOOK-PFAD\]|$HOOK_DIR|g" "$OUTDIR/webhook.service"
sed -i "s|\[BENUTZER\]|$SVC_USER|g" "$OUTDIR/webhook.service"

# ------------------------------------------------------------------
# 4. nginx-location.conf
# ------------------------------------------------------------------
cat > "$OUTDIR/nginx-location.conf" << 'NGINX'
location /webhook-[GEHEIMER-PFAD]/ {
    proxy_pass http://127.0.0.1:9000/hooks/deploy-blog;
    proxy_set_header Host $host;
    proxy_set_header X-Hub-Signature-256 $http_x_hub_signature_256;
}
NGINX

sed -i "s|\[GEHEIMER-PFAD\]|$SECRET_PATH|g" "$OUTDIR/nginx-location.conf"

# ------------------------------------------------------------------
# 5. logrotate.conf
# ------------------------------------------------------------------
cat > "$OUTDIR/logrotate.conf" << 'LOG'
[WEBHOOK-PFAD]/deploy.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    copytruncate
}
LOG

sed -i "s|\[WEBHOOK-PFAD\]|$HOOK_DIR|g" "$OUTDIR/logrotate.conf"

echo ""
echo "=== Fertig! ==="
echo ""
echo "Jetzt die Dateien an ihre Zielpfade kopieren:"
echo ""
echo "  sudo cp $OUTDIR/deploy.sh       $HOOK_DIR/scripts/deploy.sh"
echo "  sudo cp $OUTDIR/hooks.json      $HOOK_DIR/hooks.json"
echo "  sudo cp $OUTDIR/webhook.service /etc/systemd/system/webhook.service"
echo "  sudo cp $OUTDIR/logrotate.conf  /etc/logrotate.d/blog-weitzelnet"
echo ""
echo "nginx-location.conf in SWAG/Nginx-Site-Konfiguration einfügen:"
echo "  cat $OUTDIR/nginx-location.conf"
echo ""
echo "Danach Service starten:"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl enable --now webhook"
echo ""
echo "GitHub Webhook-URL:"
echo "  https://$DOMAIN/webhook-$SECRET_PATH/"
