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

- **Git** (Repo klonen/pullen)
- **Hugo Extended**
- **Tailwind CSS Standalone CLI**
- **webhook** ([github.com/adnanh/webhook](https://github.com/adnanh/webhook))
- **SWAG** (Docker) oder Nginx mit SSL (Reverse Proxy)
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

#### 2. Deployment-Dateien anpassen und ablegen

Im Ordner `deployment/` findest du alle nötigen Konfigurationsdateien als Vorlage.
Kopiere sie an die angegebenen Pfade und ersetze die Platzhalter `[...]` mit deinen Werten.

| Datei | Ablegen nach | Platzhalter |
|---|---|---|
| `deployment/deploy.sh` | `[WEBHOOK-PFAD]/scripts/deploy.sh` | `[PFAD-ZUM-REPO]`, `[WWW-PFAD]`, `[WEBHOOK-PFAD]` |
| `deployment/hooks.json` | `[WEBHOOK-PFAD]/hooks.json` | `[WEBHOOK-PFAD]`, `[WEBHOOK-SECRET]` |
| `deployment/webhook.service` | `/etc/systemd/system/webhook.service` | `[BENUTZER]`, `[WEBHOOK-PFAD]` |
| `deployment/nginx-location.conf` | In die Nginx/SWAG-Site-Konfig einfügen | `[GEHEIMER-PFAD]` |

```bash
chmod +x [WEBHOOK-PFAD]/scripts/deploy.sh
```

**Was die Platzhalter bedeuten:**

| Platzhalter | Bedeutung | Beispiel |
|---|---|---|
| `[PFAD-ZUM-REPO]` | Pfad zum geklonten Repository | `/home/stefan/blog.weitzelnet.com` |
| `[WWW-PFAD]` | Webroot – wo Hugo die fertigen Dateien hinbaut | `/var/www/blog.weitzelnet.com` |
| `[WEBHOOK-PFAD]` | Ordner für Webhook-Dateien (deploy.sh, hooks.json, deploy.log) | `/opt/webhook` |
| `[BENUTZER]` | System-Benutzer, unter dem der Service läuft | `stefan` |
| `[WEBHOOK-SECRET]` | HMAC-Key zur Signatur-Prüfung | `openssl rand -hex 32` |
| `[GEHEIMER-PFAD]` | Geheimer Teil der Webhook-URL | `a3f8b2c1…` (zufällig, kein Passwort) |

#### 3. Webhook-Service starten

```bash
sudo systemctl daemon-reload
sudo systemctl enable webhook
sudo systemctl start webhook
```

#### 4. GitHub Webhook einrichten

1. GitHub → **Repository** → **Settings** → **Webhooks** → **Add webhook**
2. **Payload URL:** `https://[DEINE-DOMAIN]/webhook-[GEHEIMER-PFAD]/`
3. **Content type:** `application/json`
4. **Secret:** Das `[WEBHOOK-SECRET]` aus Schritt 2
5. **Events:** "Just the push event" (reicht für `main`)
6. **Add webhook** — GitHub schickt einen Ping, der im Log erscheint

#### 5. Testen

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
| Webhook antwortet nicht | `ss -tlnp \| grep 9000` (Port offen?), Nginx-Proxy korrekt? |
| Trigger-Regeln schlagen fehl | `journalctl -u webhook` → "Trigger rules were not satisfied" |
| Build fehlgeschlagen | `cat [WEBHOOK-PFAD]/deploy.log` |
| Alte Seite nach Deployment | Browser Hard-Refresh (Strg+Shift+R) |

## Projektstruktur

```
blog.weitzelnet.com/
├── content/              ← Markdown-Inhalte
│   ├── _index.md         ← Startseite (Hero, Vorstellung, Projekte)
│   ├── projekte/         ← Projekt-Detailseiten
│   ├── impressum.md
│   └── datenschutz.md
├── layouts/              ← Hugo-Templates
├── static/               ← Bilder, CSS-Output (generiert)
├── assets/css/           ← Tailwind-Quelle (editieren!)
├── deployment/           ← Beispiel-Dateien fürs Server-Deployment
├── hugo.toml
└── tailwind.config.js
```

## Lizenz

- **Code** (Templates, CSS): MIT License
- **Content** (Texte, Bilder): CC BY-NC-ND 4.0
