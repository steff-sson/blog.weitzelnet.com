# blog.weitzelnet.com

Persönliche Markenseite + Projekt-Portfolio von Stefan Weitzel.
Hugo + Tailwind CSS. Keine Cookies, kein Tracking.

## Voraussetzungen

- [Hugo Extended](https://gohugo.io/installation/)
- [Tailwind CSS Standalone CLI](https://github.com/tailwindlabs/tailwindcss/releases) v3.4+

## Tools installieren

```bash
# Hugo Extended (Arch)
sudo pacman -S hugo

# Tailwind Standalone CLI (Linux x64)
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
sudo mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss
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

## Deployment

Die Site wird bei jedem Push auf `main` automatisch aktualisiert:

```
GitHub Push → Webhook → git pull → tailwindcss (minify) → hugo (minify) → Nginx
```

### Setup (einmalig auf dem Server)

**Voraussetzungen auf dem Server:** Git, Hugo, Tailwind Standalone CLI, webhook (`sudo pacman -S webhook`), systemd, SWAG/Nginx mit SSL.

```bash
# Repository klonen
git clone https://github.com/steff-sson/blog.weitzelnet.com.git

# Deployment-Konfiguration erzeugen
cd blog.weitzelnet.com
./deployment/setup.sh
```

Das Script fragt alle Pfade und Secrets ab und erzeugt die fertigen Konfigurationsdateien in `deployment/_output/`. Die genauen `sudo cp`-Befehle zeigt es am Ende an.

Ausführliche manuelle Anleitung (mit allen Configs als Copy/Paste): **DEPLOYMENT.md** (lokal, nicht im Repository).

## Projektstruktur

```
blog.weitzelnet.com/
├── content/              ← Markdown-Inhalte
├── layouts/              ← Hugo-Templates
├── static/               ← Bilder, CSS-Output (generiert)
├── assets/css/           ← Tailwind-Quelle (editieren!)
├── deployment/           ← setup.sh (heredocs → _output/)
├── hugo.toml
└── tailwind.config.js
```

## Lizenz

- **Code** (Templates, CSS): MIT License
- **Content** (Texte, Bilder): CC BY-NC-ND 4.0
