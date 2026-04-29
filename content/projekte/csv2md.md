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

**csv2md** ist ein Python-CLI-Tool zur Extraktion einer CSV-Spalte und Export als Markdown-Datei.

## Features

- Interaktiver und nicht-interaktiver Modus
- Automatische Trennzeichenerkennung
- Duplikatbereinigung (case-sensitive)
- systemd-Integration für regelmäßige Ausführung (stündlich, täglich, wöchentlich)
- URL-Input möglich (CSV von externen Quellen)
- Exit-Codes für jedes Szenario

## Entstehung

Entstanden aus dem Bedarf heraus, CSV-Daten schnell und zuverlässig in Markdown zu konvertieren – für Webseiten, Doks und Systemdokumentation.
