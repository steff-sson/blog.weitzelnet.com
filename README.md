# blog.weitzelnet.com

Persönliche Markenseite + Projekt-Portfolio von Stefan Weitzel.
Hugo + Tailwind CSS. Keine Cookies, kein Tracking.

## Voraussetzungen

- [Hugo Extended](https://gohugo.io/installation/)
- [Node.js](https://nodejs.org/) v20+ (für Tailwind CSS)
- npm (kommt mit Node.js)

## Tools installieren

```bash
# Hugo Extended (Arch)
sudo pacman -S hugo

# Node.js + npm (Arch)
sudo pacman -S nodejs npm

# Projekt-Dependencies
npm install
```

## Lokale Entwicklung

### Dev-Server starten

```bash
hugo server
```

Öffne `http://localhost:1313` — Änderungen an Inhalten und Templates werden automatisch neu geladen.

### CSS bearbeiten

Wenn du `assets/css/main.css` änderst, Tailwind neu kompilieren:

```bash
# Einmalig
npm run build:css

# Oder Watch-Modus (dauerhaft, zweites Terminal)
npm run dev:css
```

### Für den Live-Betrieb bauen

```bash
npm run build:css
hugo --minify
# Ergebnis in public/
```

## Deployment

Die Site wird bei jedem Push auf `main` automatisch aktualisiert:

```
GitHub Push → Webhook → git pull → npm install → npm run build:css → hugo --minify → Nginx
```

### Setup (einmalig auf dem Server)

**Voraussetzungen auf dem Server:** Git, Hugo, Node.js, npm, webhook (`sudo pacman -S webhook`), systemd, SWAG/Nginx mit SSL.

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
├── package.json          ← npm config + Scripts
├── hugo.toml
└── tailwind.config.js
```

## Lizenz

- **Code** (Templates, CSS): MIT License
- **Content** (Texte, Bilder): CC BY-NC-ND 4.0
