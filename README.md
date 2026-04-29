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

Die Site wird bei jedem Push auf `main` automatisch aktualisiert.
Setup-Details befinden sich in **DEPLOYMENT.md** (lokal, nicht im Repository).

## Projektstruktur

```
blog.weitzelnet.com/
├── content/              ← Markdown-Inhalte
├── layouts/              ← Hugo-Templates
├── static/               ← Bilder, CSS-Output (generiert)
├── assets/css/           ← Tailwind-Quelle (editieren!)
├── hugo.toml
└── tailwind.config.js
```

## Lizenz

- **Code** (Templates, CSS): MIT License
- **Content** (Texte, Bilder): CC BY-NC-ND 4.0
