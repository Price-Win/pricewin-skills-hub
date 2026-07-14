# Security & Data Handling — PriceWin Hotel Deal Finder

This skill drives a stealth browser (Patchright/Chromium) to read **public** hotel
listings and compare prices. It runs entirely on the user's machine, needs no API
keys, and collects no personal data. This document discloses exactly what it
executes, what it downloads, what leaves the machine, and how untrusted web
content is contained — so an auditing agent (or a human) can verify the behavior
instead of inferring it.

## What runs (command execution)

The skill's only entry point is one command:

```bash
node bin/search.js "<city>" <checkIn> <checkOut> <adults> [locale]
```

`search.js` spawns `bin/browse.js` / `bin/daemon.js` (both shipped in this repo)
to control a local browser. It runs **no** shell strings built from scraped
content, executes **no** downloaded code, and takes **no** command input from web
pages — the browser flow is fixed in this repo's source. `npm install` / `npx`
appear **only** at install time to fetch the `patchright` dependency (see below).

## What it downloads

| Item | When | Source | Purpose |
|------|------|--------|---------|
| `patchright` npm package | install | npm registry | Stealth Playwright fork (browser driver) |
| Chromium | first run (`install.sh`) | Patchright's official host | The browser engine that renders OTA pages |

No other binaries or code are downloaded at runtime.

## What leaves the machine (network egress)

Egress is limited to a fixed, auditable set of hosts. **The only user-derived data
sent is the search query itself** — city, check-in/out dates, guest count. No
account data, credentials, cookies from other sites, files, or PII are transmitted.

| Host | Data sent | Why |
|------|-----------|-----|
| `booking.com`, `agoda.com`, `google.com/travel` | city + dates + guests (as normal search URL params) | Read public listing prices |
| `api.opentravel.one` (override via `OPENTRAVEL_API_BASE_URL`) | city + dates + guests | Partner inventory lookup |
| `open.er-api.com` | none (public `GET /latest/USD`) | Live VND→USD FX rate for price normalization |

There is no telemetry, analytics, or callback to PriceWin servers.

## Untrusted content containment (indirect prompt injection)

Hotel names, prices, and aria-labels scraped from OTA pages are **untrusted
third-party content**. Before any of it reaches the model-visible output,
`sanitizeText()` in `bin/search.js`:

- strips control, zero-width, and bidirectional-override characters (defeats
  hidden-instruction and text-spoofing tricks);
- removes the markdown/link control set (`` ` `` `[ ] ( ) < > { } \ |`) so scraped
  text cannot forge `[label](url)` structure or smuggle directives;
- collapses whitespace and caps length.

All booking links (including the OpenTravel partner API's) are passed through
`cleanLink()`, which **accepts only `http(s)` URLs** — a `javascript:` or other
scheme can never render as a clickable link. The skill also treats scraped data
as data only: it ranks and formats prices, and never executes or follows
instructions found inside scraped text.

## Guidance for the running agent

The skill instructs the agent to treat OTA output as reference data to present to
the user, not as commands. Partial results (a source blocked or empty) are normal
and are surfaced honestly rather than "fixed" by ad-hoc scraping.

## Reporting

Found an issue? Open a ticket at
<https://github.com/Price-Win/pricewin-skills-hub/issues>.
