#!/bin/bash
set -e

echo "=== blog.weitzelnet.com — Deployment-Setup ==="
echo ""
echo "Dieses Skript erzeugt aus den .example-Vorlagen die echten Konfigurationsdateien."
echo ""

read -p "Pfad zum geklonten Repository  [PFAD-ZUM-REPO]: " REPO_DIR
read -p "Pfad zum Webroot              [WWW-PFAD]:        " WEB_DIR
read -p "Pfad für Webhook-Dateien      [WEBHOOK-PFAD]:    " HOOK_DIR
read -p "System-Benutzer für Service   [BENUTZER]:        " SVC_USER
read -p "Deine Domain                  [DEINE-DOMAIN]:    " DOMAIN

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
echo "=== Bitte prüfen ==="
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

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
OUTDIR="$SCRIPT_DIR/generated"
mkdir -p "$OUTDIR"

sed -e "s|\[PFAD-ZUM-REPO\]|$REPO_DIR|g" \
    -e "s|\[WWW-PFAD\]|$WEB_DIR|g" \
    -e "s|\[WEBHOOK-PFAD\]|$HOOK_DIR|g" \
    -e "s|\[DEINE-DOMAIN\]|$DOMAIN|g" \
    "$SCRIPT_DIR/deploy.sh.example" > "$OUTDIR/deploy.sh"
chmod +x "$OUTDIR/deploy.sh"

sed -e "s|\[WEBHOOK-PFAD\]|$HOOK_DIR|g" \
    -e "s|\[WEBHOOK-SECRET\]|$HOOK_SECRET|g" \
    "$SCRIPT_DIR/hooks.json.example" > "$OUTDIR/hooks.json"

sed -e "s|\[WEBHOOK-PFAD\]|$HOOK_DIR|g" \
    -e "s|\[BENUTZER\]|$SVC_USER|g" \
    "$SCRIPT_DIR/webhook.service.example" > "$OUTDIR/webhook.service"

sed -e "s|\[GEHEIMER-PFAD\]|$SECRET_PATH|g" \
    "$SCRIPT_DIR/nginx-location.conf.example" > "$OUTDIR/nginx-location.conf"

sed -e "s|\[WEBHOOK-PFAD\]|$HOOK_DIR|g" \
    "$SCRIPT_DIR/logrotate.conf.example" > "$OUTDIR/logrotate.conf"

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
echo "Inhalt von $OUTDIR/nginx-location.conf in die"
echo "SWAG/Nginx-Site-Konfiguration einfügen:"
echo ""
echo "  cat $OUTDIR/nginx-location.conf"
echo ""
echo "=== GitHub Webhook-URL ==="
echo ""
echo "  https://$DOMAIN/webhook-$SECRET_PATH/"
echo ""
echo "Trage diese URL unter GitHub → Settings → Webhooks ein."
echo "Content-Type: application/json"
echo "Secret: $HOOK_SECRET"
echo ""
echo "Danach Service starten:"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl enable --now webhook"
