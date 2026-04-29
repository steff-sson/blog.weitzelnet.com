# blog.weitzelnet.com

Persönliche Markenseite + Projekt-Portfolio von Stefan Weitzel.
Hugo + Tailwind CSS. Keine Cookies, kein Tracking.

## Voraussetzungen

- [Hugo Extended](https://gohugo.io/installation/)
- [Tailwind CSS Standalone CLI](https://github.com/tailwindlabs/tailwindcss/releases) v3.4+

### Für Deployment zusätzlich

- **Git** (Repository klonen/pullen)
- **webhook** (Arch-Paket: `webhook`)
- **SWAG** (Docker) oder Nginx mit SSL
- **systemd**

## Tools installieren

```bash
# Hugo Extended (Arch)
sudo pacman -S hugo

# Tailwind Standalone CLI (Linux x64)
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
sudo mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss
```

Zusätzlich auf dem **Server**:

```bash
sudo pacman -S webhook git
```

## Lokale Entwicklung

### Dev-Server starten

Zwei Terminals:

```bash
# Terminal 1: CSS automatisch neu bauen
tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --watch

# Terminal 2: Hugo Dev-Server
hugo server
```

Öffne `http://localhost:1313` — Änderungen an Templates und CSS werden automatisch sichtbar.

### Für den Live-Betrieb bauen

```bash
tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --minify
hugo --minify
# Ergebnis in public/
```

## Deployment auf dem eigenen Server

Die Site wird bei jedem Push auf `main` automatisch aktualisiert:

```
GitHub Push auf main
       ↓
  GitHub Webhook (HMAC-gesichert)
       ↓
  Webhook-Service empfängt → startet Deploy-Script
       ↓
  git pull → Tailwind-Build → Hugo-Build → Auslieferung
```

### 1. Repository klonen

```bash
git clone [REPO-URL] [PFAD-ZUM-REPO]
```

### 2. Deployment-Script ausführen

`deployment/setup.sh` fragt alle Pfade und Zugangsdaten interaktiv ab
und erzeugt fertige Konfigurationen in `deployment/generated/`:

```bash
cd [PFAD-ZUM-REPO]
./deployment/setup.sh
```

| Vorlage | Erzeugt | Wohin? |
|---|---|---|
| `deploy.sh.example` | `generated/deploy.sh` | `[WEBHOOK-PFAD]/scripts/` |
| `hooks.json.example` | `generated/hooks.json` | `[WEBHOOK-PFAD]/` |
| `webhook.service.example` | `generated/webhook.service` | `/etc/systemd/system/` |
| `nginx-location.conf.example` | `generated/nginx-location.conf` | In SWAG/Nginx-Site-Konfig einfügen |
| `logrotate.conf.example` | `generated/logrotate.conf` | `/etc/logrotate.d/` |

### 3. Dateien kopieren

Die `sudo cp`-Befehle zeigt `setup.sh` am Ende an.

### 4. Service starten

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now webhook
```

### 5. GitHub Webhook einrichten

1. GitHub → **Repository** → **Settings** → **Webhooks** → **Add webhook**
2. **Payload URL:** Die URL, die `setup.sh` ausgibt
3. **Content type:** `application/json`
4. **Secret:** Das aus `setup.sh`
5. **Events:** "Just the push event"
6. **Add webhook**

### Testen

```bash
# Läuft der Service?
sudo systemctl status webhook

# Requests beobachten
sudo journalctl -u webhook -f

# Deploy-Log (nach einem Push)
cat [WEBHOOK-PFAD]/deploy.log
```

### Falls etwas nicht funktioniert

| Problem | Prüfen mit |
|---|---|
| Webhook antwortet nicht | `ss -tlnp \| grep 9000`, Nginx-Proxy korrekt? |
| Trigger-Regeln schlagen fehl | `journalctl -u webhook` → "Trigger rules were not satisfied" |
| Build fehlgeschlagen | `cat [WEBHOOK-PFAD]/deploy.log` |
| Alte Seite nach Deployment | Browser Hard-Refresh (Strg+Shift+R) |

## Projektstruktur

```
blog.weitzelnet.com/
├── content/              ← Markdown-Inhalte
├── layouts/              ← Hugo-Templates
├── static/               ← Bilder, CSS-Output (generiert)
├── assets/css/           ← Tailwind-Quelle (editieren!)
├── deployment/           ← Setup-Script + .example-Vorlagen (generated/ ist gitignored)
├── hugo.toml
└── tailwind.config.js
```

## Lizenz

- **Code** (Templates, CSS): MIT License
- **Content** (Texte, Bilder): CC BY-NC-ND 4.0
