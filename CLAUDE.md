# PriceWin Skills Hub

Agent skills for hotel search + OTA price comparison. Published to skills.sh,
ClawHub, Hermes, and OpenClaw.

## Skills

- `skills/pricewin-hotel-deal-finder/` — **standalone** (no MCP), Patchright daemon
  over Booking.com + Agoda + Google Hotels + OpenTravel API. Canonical slug on
  skills.sh + ClawHub is **`pricewin-hotel-deal-finder`**. Deliberately renamed
  from `pricewin-deal-finder` (keyword choice, accepting the trade-off): skills.sh
  forfeited the old slug's ~6.4K installs (GitHub indexer, no redirect — new folder
  = fresh 0-install listing). ClawHub used `skill rename` which PRESERVES the
  install lineage and keeps `pricewin-deal-finder` as a redirect. **Now keep this
  slug stable — every further rename forfeits skills.sh installs again.**
- The three `pricewin-*` MCP skills drive the `pricewin` MCP server.

## Publishing (ClawHub)

**Token:** stored locally in `.env` (gitignored, never commit) as `CLAWHUB_TOKEN`.
The same token also lives as the GitHub repo secret `CLAWHUB_TOKEN` (used by CI).
If `.env` is missing, regenerate a token at https://clawhub.ai (GitHub sign-in).

**Publish via CI (preferred):**
```bash
gh workflow run publish-skill.yml -f dry_run=false     # dry_run=true to preview
```

**Publish locally (needs the token loaded):**
```bash
set -a; source .env; set +a
scripts/deploy-clawhub.sh --dry-run     # preview bundle
scripts/deploy-clawhub.sh               # publish
```

**Versioning gotcha:** ClawHub is registry-driven with `bump: patch` — it does NOT
read the manifest version. A brand-new slug starts at `1.0.0`, then auto-bumps
each publish. Keep `SKILL.md` / `package.json` version in sync manually for
skills.sh/GitHub display only.

## Notes

- Never fold flights/rental-car into the `pricewin-hotel-deal-finder` slug — ship
  them as separate skills. Keep each skill's `description` honest to its CURRENT
  capability (the agent trigger), not the roadmap.
