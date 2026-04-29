# blog.weitzelnet.com

Persönliche Markenseite + Projekt-Portfolio von Stefan Weitzel.
Hugo + Tailwind CSS. Keine Cookies, kein Tracking.

## Tech-Stack

- Hugo Extended (Static Site Generator)
- Tailwind CSS v3 (Standalone CLI, kein Node.js)
- Deployment via GitHub Webhook

## Lokale Entwicklung

### Voraussetzungen

- [Hugo Extended](https://gohugo.io/installation/) v0.100+
- [Tailwind CSS Standalone CLI](https://github.com/tailwindlabs/tailwindcss/releases) v3.4+

```bash
# Tailwind CLI einmalig installieren (Linux x64)
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
sudo mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss
```

### Dev-Server starten

Zwei Terminals:

```bash
# Terminal 1: Tailwind Watch
tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --watch

# Terminal 2: Hugo Dev Server
hugo server
```

Öffnen: `http://localhost:1313`

### Production-Build

```bash
tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --minify
hugo --minify
# Output in public/
```

## Deployment (Server)

Die Site wird bei jedem Push auf `main` automatisch deployed.

### Ablauf

```
GitHub.com → Push auf main
     ↓
GitHub Webhook (HMAC-signiert, nur main-Branch)
     ↓
SWAG/Nginx leitet weiter an Webhook-Service (Port 9000)
     ↓
Deploy-Script: git pull → tailwindcss --minify → hugo --minify → [PFAD-WWW]
     ↓
Statische Dateien werden von SWAG/Nginx ausgeliefert
```

### Server-Voraussetzungen

- **Hugo Extended** installiert (im PATH)
- **Tailwind CSS Standalone CLI** installiert (im PATH)
- **Git** (HTTPS-Clone des Repos)
- **webhook** Binary ([github.com/adnanh/webhook](https://github.com/adnanh/webhook))
- **SWAG** (Docker) oder Nginx mit SSL
- **systemd** für den Webhook-Service

### Deployment einrichten (Schritt-für-Schritt)

#### 1. Repository klonen

```bash
git clone [REPO-URL] [PFAD-ZUM-REPO]
```

#### 2. Webhook Binary installieren

```bash
# Arch Linux
sudo pacman -S webhook

# Oder via Go
go install github.com/adnanh/webhook@latest
```

#### 3. Deploy-Script erstellen

Pfad: `[PFAD-ZUM-WEBHOOK]/scripts/deploy.sh`

```bash
#!/bin/bash
set -e

REPO_DIR="[PFAD-ZUM-REPO]"
WEB_DIR="[PFAD-WWW]"
LOG="[PFAD-ZUM-WEBHOOK]/deploy.log"

echo "$(date): Deploy gestartet" >> "$LOG"

cd "$REPO_DIR"
git pull origin main >> "$LOG" 2>&1

tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --minify >> "$LOG" 2>&1

hugo --minify -d "$WEB_DIR" >> "$LOG" 2>&1

echo "$(date): Deploy erfolgreich" >> "$LOG"
```

```bash
chmod +x [PFAD-ZUM-WEBHOOK]/scripts/deploy.sh
```

#### 4. Webhook-Konfiguration

Pfad: `[PFAD-ZUM-WEBHOOK]/hooks.json`

```json
[
  {
    "id": "deploy-blog",
    "execute-command": "[PFAD-ZUM-WEBHOOK]/scripts/deploy.sh",
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
```

**Secret generieren:**
```bash
openssl rand -hex 32
```

#### 5. systemd-Service einrichten

Pfad: `/etc/systemd/system/webhook.service`

```ini
[Unit]
Description=GitHub Webhook Server
After=network.target

[Service]
Type=simple
User=[DEIN-USER]
WorkingDirectory=[PFAD-ZUM-WEBHOOK]
ExecStart=/usr/bin/webhook -hooks [PFAD-ZUM-WEBHOOK]/hooks.json -verbose -port 9000
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable webhook
sudo systemctl start webhook
```

#### 6. SWAG/Nginx konfigurieren

In der SWAG-Config oder Nginx-Site-Config:

```nginx
# Webhook-Endpunkt (Secret-Pfad verwenden!)
location /webhook-[GEHEIMER-PFAD]/ {
    proxy_pass http://127.0.0.1:9000/hooks/deploy-blog;
    proxy_set_header Host $host;
    proxy_set_header X-Hub-Signature-256 $http_x_hub_signature_256;
}
```

```bash
sudo systemctl reload nginx
# oder
docker restart swag
```

#### 7. GitHub Webhook einrichten

1. GitHub Repo → Settings → Webhooks → Add webhook
2. **Payload URL:** `https://[DEINE-URL]/webhook-[GEHEIMER-PFAD]/`
3. **Content type:** `application/json`
4. **Secret:** das mit `openssl rand -hex 32` generierte Secret
5. **Events:** "Just the push event"
6. **Add webhook**

GitHub sendet einen Ping — im Log prüfbar:

```bash
sudo journalctl -u webhook -f
```

### Testen

```bash
# Webhook erreichbar?
curl http://localhost:9000/hooks/deploy-blog

# Service-Status
sudo systemctl status webhook

# Logs
sudo journalctl -u webhook -n 50
cat [PFAD-ZUM-WEBHOOK]/deploy.log
```

### Deployment-Debugging

- **Webhook empfängt nichts:** `ss -tlnp | grep 9000`, prüfe Nginx-Proxy
- **Trigger-Regeln schlagen fehl:** `journalctl -u webhook` — such nach "Trigger rules were not satisfied"
- **Build fehlgeschlagen:** `cat deploy.log`
- **Nach Deployment alte Seite sichtbar:** Browser Hard-Refresh

## Projektstruktur

```
blog.weitzelnet.com/
├── content/             ← Markdown-Inhalte
│   ├── _index.md        ← Startseite
│   ├── projekte/        ← Projekt-Detailseiten
│   ├── impressum.md
│   └── datenschutz.md
├── layouts/             ← Hugo-Templates
├── static/              ← Bilder, Fonts, generiertes CSS
├── assets/css/          ← Tailwind-Quelle
├── hugo.toml
└── tailwind.config.js
```

## Lizenz

- **Code** (Templates, CSS): MIT License
- **Content** (Texte, Bilder): CC BY-NC-ND 4.0
