# blog.weitzelnet.com

Persönliche Markenseite + Projekt-Portfolio von Stefan Weitzel.
Hugo + Tailwind CSS. Keine Cookies, kein Tracking.

## Lokale Entwicklung

### Was du brauchst

- [Hugo Extended](https://gohugo.io/installation/)
- [Tailwind CSS Standalone CLI](https://github.com/tailwindlabs/tailwindcss/releases) v3.4+

```bash
# Tailwind CLI installieren (Linux x64)
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
sudo mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss
```

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

### Was auf dem Server installiert sein muss

- **Git**, **Hugo Extended**, **Tailwind CSS Standalone CLI**
- **webhook** ([github.com/adnanh/webhook](https://github.com/adnanh/webhook))
- **SWAG** (Docker) oder Nginx mit SSL
- **systemd** (für den Webhook-Service)

```bash
# Arch Linux
sudo pacman -S webhook hugo git

# Tailwind CLI (Linux x64)
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
sudo mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss
```

### Schritt-für-Schritt

#### 1. Repository auf den Server klonen

```bash
git clone [REPO-URL] [PFAD-ZUM-REPO]
```

#### 2. Setup-Script ausführen

Das Script `deployment/setup.sh` fragt alle Pfade und Zugangsdaten ab und
erzeugt daraus die fertigen Konfigurationsdateien:

```bash
cd [PFAD-ZUM-REPO]
./deployment/setup.sh
```

Die fertigen Dateien liegen danach in `deployment/generated/`.

Das sind:

| Vorlage | Erzeugt | Wohin? |
|---|---|---|
| `deploy.sh.example` | `generated/deploy.sh` | `[WEBHOOK-PFAD]/scripts/` |
| `hooks.json.example` | `generated/hooks.json` | `[WEBHOOK-PFAD]/` |
| `webhook.service.example` | `generated/webhook.service` | `/etc/systemd/system/` |
| `nginx-location.conf.example` | `generated/nginx-location.conf` | In SWAG/Nginx-Site-Konfig einfügen |
| `logrotate.conf.example` | `generated/logrotate.conf` | `/etc/logrotate.d/` |

#### 3. Dateien an ihre Zielpfade kopieren

Die genauen `sudo cp`-Befehle zeigt `setup.sh` am Ende an.

#### 4. Webhook-Service starten

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now webhook
```

#### 5. GitHub Webhook einrichten

1. GitHub → **Repository** → **Settings** → **Webhooks** → **Add webhook**
2. **Payload URL:** Die URL, die `setup.sh` ausgibt (z. B. `https://example.com/webhook-a3f8b2c1/`)
3. **Content type:** `application/json`
4. **Secret:** Das `[WEBHOOK-SECRET]` aus `setup.sh`
5. **Events:** "Just the push event"
6. **Add webhook**

### Testen

```bash
# Läuft der Webhook-Service?
sudo systemctl status webhook

# Eingehende Requests beobachten
sudo journalctl -u webhook -f

# Deploy-Log prüfen (nach einem Push)
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
