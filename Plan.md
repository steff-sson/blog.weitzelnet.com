# Plan – blog.weitzelnet.com

> Persönliche Markenseite + Projekt-Portfolio
> Stand: April 2026

---

## Vision

Persönliche Markenseite für Stefan Weitzel. Minimalistisch, modern, menschlich.
Zielgruppe: Arbeitgeber und Experten aus den Themenfeldern Web, Online-Marketing, SEO/SEA, Content.

Keine Cookies. Kein Tracking. Kein Kontaktformular. Einfachste Datenschutzerklärung.

---

## Tech-Stack

- **Hugo Extended** (Static Site Generator, Single Binary)
- **Tailwind CSS v3 – Standalone CLI** (Utility-First CSS, kein Node.js nötig)
- **Deployment**: GitHub Webhook → Arch-Linux-Server → SWAG (Nginx) → Hugo Build `public/`
- **KEINE Cookies, KEINE Tracker**

---

## Seitenstruktur

| Route | Inhalt | Content-Datei |
|-------|--------|---------------|
| `/` | Startseite (Hero, Vorstellung, Projekte-Teaser, Footer) | `content/_index.md` |
| `/projekte/<slug>/` | Projekt-Detailseiten | `content/projekte/<slug>.md` |
| `/impressum/` | Impressum (Pflichtangaben) | `content/impressum.md` |
| `/datenschutz/` | Datenschutzerklärung (einfachst) | `content/datenschutz.md` |

---

## Startseite – Blöcke (von oben nach unten)

1. **Header** – Typo/Logo "Weitzelnet", direkte Links rechts → Impressum, Datenschutz
2. **Hero** – Breites Logo, Claim, Kurzsatz
3. **"Das ist Weitzelnet"** – Persönliche Vorstellung (Basis: `wwwweitzelnetcom.md`)
4. **Projekte-Teaser** – 4 Karten mit Link zur jeweiligen Detailseite
5. **Footer** – E-Mail-Alias, "Mit KI-Unterstützung entwickelt"

---

## Projekte (4 Stück)

| Projekt | Typ | Kernaussage |
|---------|-----|-------------|
| **csv2md** | Python-CLI | CSV strukturiert nach Markdown, mit systemd-Integration |
| **html2md-flask** | Flask-Webapp | HTML-Webseiten zu Markdown extrahieren, Docker + CI/CD |
| **taunus3-gartenbegehung** | Full-Stack | Flask-Formular mit PDF-Generierung für Kleingartenverein |
| **AI-Development** | Workflow | librechat + opencode – KI-gestützter Entwicklungsalltag |

Alle Projekte vermerken: *"Entstanden mit KI-Unterstützung"*

---

## Design

- **Primary**: `#00b894` (Grün/Türkis)
- **Background**: Weiß/hellgrau, viel Weißraum
- **Typo**: System-Font-Stack, modern, clean
- **Layout**: Mobile-First, scrollbar, minimalistisch

---

## Content-Verzeichnis

```
content/
├── _index.md
├── projekte/
│   ├── _index.md
│   ├── csv2md.md
│   ├── html2md-flask.md
│   ├── taunus3-gartenbegehung.md
│   └── ai-development.md
├── impressum.md
└── datenschutz.md
```

---

## Domain

`weitzelnet.com` / `www.weitzelnet.com` → `blog.weitzelnet.com`
(DNS/Nginx-Redirect — ist in SWAG bereits lauffähig.)

---

## SEO-Basics

- `<title>` und `<meta name="description">` pro Seite (aus Frontmatter)
- `og:title`, `og:description`, `og:image` für Social-Media-Previews
- `hugo.toml`: `languageCode = "de-DE"`, kanonische `baseURL`
- Kein `noindex` — Seite soll indexierbar sein

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

## Offene Punkte

- [ ] Logo entwickeln
- [ ] Exakten Hero-Claim formulieren
- [ ] Projekttexte schreiben
- [ ] Hugo-Templates bauen (Layouts, Partials)
- [ ] Tailwind-Konfiguration
