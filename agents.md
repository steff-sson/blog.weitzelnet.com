# agents.md – LLM Context für blog.weitzelnet.com

> Vollständiger Projekt-Kontext für Large Language Models.
> Architektur-Entscheidungen, Konventionen, Design-Tokens.
> **KEINE Sicherheits-relevanten Daten** (Secrets, IPs, Pfade mit Usernamen).

---

## Executive Summary

**blog.weitzelnet.com** ist die persönliche Markenseite von Stefan Weitzel – eine Hugo-basierte Static Site mit Projekt-Portfolio.

**Kern-Anforderung:** Keine Cookies, kein Tracking, kein Kontaktformular. Einfachste Datenschutzerklärung. Alle Projekte sind KI-gestützt entstanden und als solche gekennzeichnet.

**Lizenz:** Code (Templates, CSS) unter MIT. Content (Texte, Bilder) unter CC BY-NC-ND 4.0.

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
├── README.md                        ← Setup, Dev
├── TODO.md                          ← Offene Aufgaben
└── agents.md                        ← Diese Datei
```

---

## Hugo-Grundlagen

## Hugo-Konfiguration

### hugo.toml (vollständig)

```toml
baseURL = "https://blog.weitzelnet.com/"
languageCode = "de-DE"
title = "Weitzelnet"

[params]
  description = "Persönliche Markenseite von Stefan Weitzel – Projekte & Portfolio"

[markup]
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = true
    [markup.goldmark.parser]
      [markup.goldmark.parser.attribute]
        block = true
        title = true
      hardLineBreak = true
```

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

### content/_index.md Frontmatter (vollständiges Beispiel)

```yaml
---
title: "Weitzelnet"
hero:
  title: "Stefan Weitzel"
  claim: "Webredakteur. Online-Marketing. SEO/SEA. Content."
vorstellung_title: "Das ist Weitzelnet"
projekte:
  - slug: csv2md
    title: "csv2md"
    teaser: "CSV zu Markdown — Python-CLI mit systemd-Integration"
  - slug: html2md-flask
    title: "html2md-flask"
    teaser: "HTML zu Markdown — Flask-Webapp mit Docker & CI/CD"
  - slug: taunus3-gartenbegehung
    title: "taunus3-gartenbegehung"
    teaser: "Full-Stack Flask-Formular mit PDF-Generierung"
  - slug: ai-development
    title: "AI-Development"
    teaser: "librechat + opencode — mein KI-gestützter Entwicklungsalltag"
footer_link_text: "Mit KI-Unterstützung entwickelt"
---

Der Vorstellungstext (Markdown) steht hier direkt im Body von _index.md.
Wird im Template als `.Content` gerendert.
```

### Projekt-Detailseiten Frontmatter (content/projekte/*.md)

```yaml
---
title: "csv2md"
date: 2026-04-29
draft: false
repo_url: "https://github.com/steff-sson/csv2md"
tech_stack:
  - Python 3.11+
  - systemd
  - CSV
ki_hinweis: true
---

# Beschreibung als Markdown

csv2md ist ein Python-CLI-Tool, das ...
```

**Pflichtfelder pro Projektseite:**
- `title` — Projektname
- `date` — Datum (für Hugo-Sortierung)
- `draft: false`
- `repo_url` — Link zum GitHub-Repository
- `tech_stack` — Array von Technologien (als Liste gerendert)
- `ki_hinweis: true` — steuert den "KI-gestützt"-Badge

### Vorstellungstext

Der Text für "Das ist Weitzelnet" auf der Startseite kommt aus `Hintergrund/wwwweitzelnetcom.md`.
**Vor Hugo-Init:** Diese Datei nach `content/weitzelnet.md` kopieren.
Das Template rendert ihn als `.Content` des Abschnitts.

### Markdown-Konventionen (Goldmark)

In `hugo.toml` wird `unsafe = true` gesetzt, damit rohes HTML in Markdown funktioniert.
Goldmark-Parser mit `hardLineBreak = true` (Zeilenumbrüche im Markdown werden zu `<br>`).

---

## Design-Tokens

### Farbpalette

Diese Farben werden sowohl als Tailwind-Theme (`tailwind.config.js`) als auch als CSS-Custom-Properties im Tailwind-Quell-CSS definiert:

| Token | Tailwind-Klasse | Wert | Verwendung |
|-------|-----------------|------|------------|
| `primary` | `bg-primary`, `text-primary` | `#00b894` | Buttons, Links, Akzente |
| `primary-dark` | `bg-primary-dark` | `#00a381` | Hover-Zustände |
| Hintergrund | `bg-white` | `#ffffff` | Seitenhintergrund |
| Hintergrund alt | `bg-gray-50` | `#f5f6f8` | Alternierende Sektionen |
| Text | `text-gray-900` | `#1a1a2e` | Fließtext |
| Text muted | `text-gray-500` | `#6b7280` | Sekundärtext |
| Border | `border-gray-200` | `#e5e7eb` | Trennlinien, Kartenrahmen |

**Hinweis für LLM:** Die Tailwind-eigenen Grautöne (`gray-50`, `gray-500`, `gray-900`) passen exakt zu den gelisteten Werten und können direkt verwendet werden. Nur `primary` und `primary-dark` müssen in `tailwind.config.js` erweitert werden.

### Max-Width-Regel

- **Text-Inhalte** (Vorstellung, Projekt-Detailseiten): `max-w-3xl` (768px)
- **Karten-Grid** (Projekte-Teaser, Hero): `max-w-5xl` (1024px)
- **Gesamte Seite**: Header/Footer `max-w-5xl`, alles zentriert via `mx-auto`

### Typographie

- System-Font-Stack: `system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`
- Keine externen Webfonts (Performance, Datenschutz)
- Überschriften: `font-weight: 700`, `letter-spacing: -0.02em`
- Fließtext: `font-weight: 400`, `line-height: 1.7`

### Spacing

- Sektionen: `py-24` (6rem oben/unten)
- Karten: `p-8` (2rem Innenabstand)
- Max-Breite Content: `max-w-3xl` für Text, `max-w-5xl` für Karten-Grids

### Mobile-First

- Basis-Layout für Mobile, Breakpoints für größer
- `md:` → `lg:` → `xl:` Breakpoints

---

## baseof.html – HTML-Grundgerüst

```html
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ .Title }} — Weitzelnet</title>
  <meta name="description" content="{{ with .Description }}{{ . }}{{ else }}{{ .Site.Params.description }}{{ end }}">
  <meta property="og:title" content="{{ .Title }} — Weitzelnet">
  <meta property="og:description" content="{{ with .Description }}{{ . }}{{ else }}{{ .Site.Params.description }}{{ end }}">
  <meta property="og:image" content="{{ .Site.BaseURL }}img/og-image.jpg">
  <meta property="og:type" content="website">
  <link rel="stylesheet" href="{{ "css/main.css" | relURL }}">
  <link rel="icon" type="image/x-icon" href="{{ "favicon.ico" | relURL }}">
</head>
<body>
  {{ partial "header.html" . }}
  <main>
    {{ block "main" . }}{{ end }}
  </main>
  {{ partial "footer.html" . }}
</body>
</html>
```

## assets/css/main.css – Tailwind-Quelle (Initial)

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-white text-gray-900 antialiased;
  }
  h1 { @apply text-3xl font-bold tracking-tight; }
  h2 { @apply text-2xl font-bold tracking-tight; }
  h3 { @apply text-xl font-semibold; }
  a { @apply text-primary hover:text-primary-dark transition-colors; }
}
```

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
- `.Params.hero.title`, `.Params.hero.claim`
- `.Params.vorstellung_title` (Überschrift für den Vorstellungsblock)
- `.Content` (der Markdown-Body von `_index.md` = Vorstellungstext)
- `.Params.projekte` (Array mit `slug`, `title`, `teaser`)
- `.Params.footer_link_text` (Platzhalter: E-Mail + KI-Hinweis)

### Projekt-Detailseite (`layouts/projekte/single.html`)

**Hugo-Template-Lookup:** Hugo findet dieses Template automatisch für alle Seiten unter `content/projekte/`, da der Content-Typ "projekte" ist. Keine weitere Konfiguration nötig.

**single.html (projekte) — minimal:**
```html
{{ define "main" }}
<article class="max-w-3xl mx-auto px-4 py-24">
  <p class="text-primary text-sm font-medium mb-4">
    <a href="/">&larr; Zurück zur Startseite</a>
  </p>
  <h1 class="mb-4">{{ .Title }}</h1>
  {{ if .Params.ki_hinweis }}
    <p class="text-sm text-gray-500 mb-8">Entstanden mit KI-Unterstützung</p>
  {{ end }}
  <div class="prose mb-8">
    {{ .Content }}
  </div>
  {{ if .Params.tech_stack }}
    <h3 class="mb-2">Tech-Stack</h3>
    <ul class="flex flex-wrap gap-2">
      {{ range .Params.tech_stack }}
        <li class="px-3 py-1 bg-gray-100 rounded-full text-sm">{{ . }}</li>
      {{ end }}
    </ul>
  {{ end }}
  {{ if .Params.repo_url }}
    <a href="{{ .Params.repo_url }}" class="inline-block mt-8 px-6 py-3 bg-primary text-white rounded-lg" target="_blank" rel="noopener">
      Repository auf GitHub
    </a>
  {{ end }}
</article>
{{ end }}
```

### Impressum & Datenschutz

Statische Seiten über `layouts/_default/single.html`. Hugo rendert `content/impressum.md` automatisch als `/impressum/` und `content/datenschutz.md` als `/datenschutz/`.

**single.html – minimal:**
```html
{{ define "main" }}
<article class="max-w-3xl mx-auto px-4 py-24">
  <h1 class="mb-8">{{ .Title }}</h1>
  <div class="prose">
    {{ .Content }}
  </div>
</article>
{{ end }}
```

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

**Deployment-Details** befinden sich in `DEPLOYMENT.md` (lokal, `.gitignore`).

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
