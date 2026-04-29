# agents.md – LLM Context für blog.weitzelnet.com

> Vollständiger Projekt-Kontext für Large Language Models.
> Architektur-Entscheidungen, Konventionen, Design-Tokens.
> **KEINE Sicherheits-relevanten Daten** (Secrets, IPs, Pfade mit Usernamen).

---

## Executive Summary

**blog.weitzelnet.com** ist die persönliche Markenseite von Stefan Weitzel – eine Hugo-basierte Static Site mit Projekt-Portfolio.

**Kern-Anforderung:** Keine Cookies, kein Tracking, kein Kontaktformular. Einfachste Datenschutzerklärung. Alle Projekte sind KI-gestützt entstanden und als solche gekennzeichnet.

---

## Tech Stack & Warum

| Komponente | Technologie | Warum |
|------------|-------------|-------|
| Static Site Generator | Hugo Extended | Single Binary, bewährt, große Template-Bibliothek |
| CSS | Tailwind CSS v3 (Standalone CLI) | Utility-First, minimales CSS-Bundle, Single Binary |
| Deployment | GitHub Webhook → Server → Hugo Build | Direktes Git-basiertes Deployment |
| Webserver | SWAG (Nginx Docker) | Reverse Proxy mit Let's Encrypt |
| Hosting | Eigener Arch-Linux-Server | Volle Kontrolle |

**Lessons aus campa (GEW-Bund/campa):**
- Build-Tools (Hugo) auf Host, nicht in Docker
- Hugo ist ein Single Binary – kein Container nötig
- Tailwind Standalone CLI ist ebenfalls ein Single Binary – kein Node.js nötig
- Docker nur für Services, die 24/7 laufen (SWAG/Nginx)
- GitHub Webhook statt Actions — der Server pullt selbst
- `assets/css/` editieren, `static/css/` ist generiert – nie manuell editieren

---

## Projektstruktur

```
blog.weitzelnet.com/
├── content/
│   ├── _index.md                    ← Startseite (Hero, Vorstellung, Projekte, Footer)
│   ├── projekte/
│   │   ├── _index.md                ← Nur Metadaten (nicht als Seite gerendert)
│   │   ├── csv2md.md
│   │   ├── html2md-flask.md
│   │   ├── taunus3-gartenbegehung.md
│   │   └── ai-development.md
│   ├── impressum.md
│   └── datenschutz.md
├── layouts/
│   ├── _default/
│   │   └── baseof.html             ← HTML-Grundgerüst (Header, Footer)
│   ├── index.html                   ← Startseiten-Template
│   ├── partials/
│   │   ├── header.html
│   │   ├── footer.html
│   │   ├── hero.html
│   │   ├── vorstellung.html
│   │   └── projekt-teaser.html
│   └── projekte/
│       └── single.html              ← Projekt-Detailseite
├── static/
│   ├── css/
│   │   └── main.css                 ← Tailwind-Output (GENERIERT, nicht editieren!)
│   ├── img/
│   │   └── logo.svg                 ← Weitzelnet-Logo (wird noch entwickelt)
│   └── favicon.ico
├── assets/
│   └── css/
│       └── main.css                 ← Tailwind-Quelle (editieren!)
├── hugo.toml
├── tailwind.config.js
├── Plan.md                          ← Projekt-Plan
└── agents.md                        ← Diese Datei
```

---

## Hugo-Grundlagen

### content/_index.md wird als `/` gerendert

Hugo rendert `content/_index.md` immer als Startseite (`/index.html`).
Andere `_index.md`-Dateien (z.B. `content/projekte/_index.md`) sind nur Metadaten,
werden nicht als eigenständige Seiten gerendert.

### Content-Lookup

Projekt-Teaser auf der Startseite laden Inhalte aus den Projekt-Detailseiten:

```yaml
# In content/_index.md
projekte:
  - slug: csv2md
    title: "csv2md"
    teaser: "CSV zu Markdown, mit systemd-Integration"
```

Template lädt dann: `content/projekte/csv2md.md`

### Frontmatter-Konvention

Jede Content-Datei hat YAML-Frontmatter:

```yaml
---
title: "Seitentitel"
date: 2026-04-29
draft: false
---

# Markdown-Inhalt
```

### Markdown-Konventionen (Goldmark)

In `hugo.toml` wird `unsafe = true` gesetzt, damit rohes HTML in Markdown funktioniert.
Goldmark-Parser mit `hardLineBreak = true` (Zeilenumbrüche im Markdown werden zu `<br>`).

---

## Design-Tokens

### Farbpalette

| Token | Wert | Verwendung |
|-------|------|------------|
| `--color-primary` | `#00b894` | Buttons, Links, Akzente, Hover |
| `--color-primary-dark` | `#00a381` | Hover/Dunkler |
| `--color-bg` | `#ffffff` | Hintergrund |
| `--color-bg-alt` | `#f5f6f8` | Alternativer Hintergrund (Sektionen) |
| `--color-text` | `#1a1a2e` | Fließtext |
| `--color-text-muted` | `#6b7280` | Sekundärtext, Metadaten |
| `--color-border` | `#e5e7eb` | Trennlinien, Karten-Rahmen |

### Typographie

- System-Font-Stack: `system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`
- Keine externen Webfonts (Performance, Datenschutz)
- Überschriften: `font-weight: 700`, `letter-spacing: -0.02em`
- Fließtext: `font-weight: 400`, `line-height: 1.7`

### Spacing

- Sektionen: `py-24` (6rem oben/unten)
- Karten: `p-8` (2rem Innenabstand)
- Max-Breite Content: `max-w-3xl` (768px) oder `max-w-5xl` (1024px)

### Mobile-First

- Basis-Layout für Mobile, Breakpoints für größer
- `md:` → `lg:` → `xl:` Breakpoints

---

## Seiten-Templates

### Startseite (`layouts/index.html`)

Baut die Seite aus folgenden Blöcken auf:

```
Header (Logo, Nav-Links: Impressum, Datenschutz)
Hero (Logo breit, Claim)
"Das ist Weitzelnet" (Vorstellungstext)
Projekte-Teaser (Karten-Grid, je mit Link)
Footer (E-Mail-Alias, KI-Hinweis)
```

Daten aus `content/_index.md`:
- `hero.title`, `hero.claim`
- `vorstellung` (Markdown-Inhalt unterhalb des Frontmatter)
- `projekte` (Array mit `slug`, `title`, `teaser`)

### Projekt-Detailseite (`layouts/projekte/single.html`)

Maximal einfach:
- Titel
- Markdown-Inhalt (Beschreibung, Tech-Stack, Links)
- Hinweis "KI-gestützt entwickelt"
- Zurück-zur-Startseite-Link

### Impressum & Datenschutz

Eigene Templates: `layouts/_default/single.html` mit Content aus `impressum.md` / `datenschutz.md`.

---

## Tailwind CSS Pipeline

```
assets/css/main.css (editieren!)
       ↓
  Tailwind Standalone CLI (Binary)
       ↓
static/css/main.css (GENERIERT – nicht editieren!)
       ↓
  Hugo lädt es per <link>
```

### Tailwind Standalone CLI

**Kein Node.js nötig.** Das Binary wird von GitHub Releases geladen:

```bash
# Einmalig: Binary herunterladen (Beispiel Linux x64)
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
sudo mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss
```

### Development (Watch-Modus)

```bash
tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --watch
```

### Production (Build)

```bash
tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --minify
```

### tailwind.config.js

```js
module.exports = {
  content: [
    "./layouts/**/*.html",
    "./content/**/*.md",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#00b894",
        'primary-dark': "#00a381",
      },
    },
  },
}
```

---

## Entwicklung (Lokal)

```bash
git clone <repo-url> .

# Terminal 1: Tailwind Watch
tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --watch

# Terminal 2: Hugo Dev Server
hugo server
```

Öffnen: `http://localhost:1313`

### Build

```bash
tailwindcss -i ./assets/css/main.css -o ./static/css/main.css --minify
hugo --minify
# Output in public/
```

---

## Deployment (Konzept)

1. Änderung wird auf `main`-Branch gepusht
2. GitHub Webhook triggert Server-seitiges Script
3. Script macht `git pull`, `tailwindcss --minify`, `hugo --minify`
4. Nur bei Build-Erfolg (Exit 0) wird `public/` ausgeliefert
5. Statischer Output wird von SWAG (Nginx) ausgeliefert

**Details zum Deployment sind NICHT in diesem Repo** (private Server-Konfiguration).

---

## Konventionen & Regeln

### Für LLMs die an diesem Projekt arbeiten

1. **Keine Kommentare** in Code-Dateien, außer explizit gefordert
2. **Keine Cookies, kein Tracking** – nie Code einführen, der dies benötigt
3. **Keine externen Abhängigkeiten** die Nutzer tracken (Google Fonts, Analytics, CDNs mit Tracking)
4. **Bestehende Konventionen respektieren** – vor Änderungen umgebenden Code lesen
5. **Keine Sicherheits-relevanten Daten** in agents.md, README.md oder anderen versionierten Dateien
6. **Mobile-First** denken
7. **Deutsch** als primäre Content-Sprache (Templates, Markdown-Inhalte)

### Datei-Regeln

- `assets/css/main.css` → **editieren** (Tailwind-Quelle)
- `static/css/main.css` → **NIEMALS editieren** (generiert)
- `hugo.toml` → Hugo-Konfiguration
- `tailwind.config.js` → Tailwind-Konfiguration

---

## SEO

- `<title>` und `<meta name="description">` pro Seite aus Hugo-Frontmatter
- Open Graph: `og:title`, `og:description`, `og:image` in `<head>`
- `hugo.toml`: `languageCode = "de-DE"`, kanonische `baseURL`
- Keine `robots.txt`-Einschränkung — Seite soll indexiert werden
- Keine externen Abhängigkeiten die Crawler blockieren könnten

---

## Datenschutz & Server-Logs

Die Seite setzt keine Cookies, kein Tracking. Nginx-Server-Logs werden
**ohne Client-IP** konfiguriert (DSGVO-konform), z.B.:

```nginx
log_format noclient '$remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer"';
access_log /var/log/nginx/access.log noclient;
```

Damit fallen faktisch keine personenbezogenen Daten an.
Die vollständige Datenschutzerklärung steht in `content/datenschutz.md`.

---

## Security-Header (Nginx/SWAG)

```nginx
add_header Strict-Transport-Security "max-age=63072000" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "no-referrer" always;
add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline'" always;
```

---

## Offene Design-Entscheidungen

- [ ] Logo (wird separat entwickelt)
- [ ] Exakter Hero-Claim
- [ ] Projekt-Karten: vertikaler Stack (Mobile) → Grid (Desktop)?
- [ ] Dark Mode? (Aktuell nicht im Plan, aber Tailwind `dark:` bereithalten)

---

**Repository:** https://github.com/steff-sson/blog.weitzelnet.com
**Aktueller Stand:** Plan-Phase, April 2026
