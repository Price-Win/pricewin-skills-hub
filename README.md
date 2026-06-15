# Pricewin Skills Hub

Skills for AI agents to search hotels, compare OTA prices, and surface the best
booking deals. Two families:

- **MCP skills** — drive the Pricewin MCP server (`pricewin`).
- **Standalone skill** — `pricewin-deal-finder` runs its own browser + API stack,
  no MCP server required.

**Repo:** `git@github.com:Price-Win/pricewin-skills-hub.git`

## Skills

| Skill | Type | Trigger | Sources / Tools |
|-------|------|---------|-----------------|
| `pricewin-hotel-search` | MCP | search/find hotels live for travel dates | `search_hotels_live` → `poll_search_results` (Agoda + Booking.com + Traveloka, plus `opentravelResults` OpenTravel listings) |
| `pricewin-price-comparison` | MCP | compare prices, check room rates | `search_hotels`, `autocomplete_city`, `get_hotel_prices`, `compare_hotel_prices`, `get_hotel_details` |
| `pricewin-booking-assistant` | MCP | recommend room, generate booking link | orchestrates search → compare → recommend (`search_hotels`, `compare_hotel_prices`, `get_hotel_details`, `get_popular_hotels`) |
| `pricewin-deal-finder` | Standalone | hotel deals / price comparison for travel dates | Browser automation (Patchright) over Booking.com + Agoda + Google Hotels, plus the **OpenTravel** public API — no MCP server |

## `pricewin-deal-finder` (standalone)

Self-contained skill: a long-running Patchright (stealth Chromium) daemon scrapes
Booking.com, Agoda, and Google Hotels, while a single HTTPS call hits the
OpenTravel public API. One command does everything:

```bash
node bin/search.js "<city>" <checkIn YYYY-MM-DD> <checkOut YYYY-MM-DD> <adults> en-us
```

- **OpenTravel API base:** `https://api.opentravel.one`
  (override with `OPENTRAVEL_API_BASE_URL`)
- **Setup:** `skills/pricewin-deal-finder/install.sh` (Node deps + Chromium, ~200MB one-time)
- **Cache:** `~/.cache/pricewin-deal-finder/selectors.json`

See `skills/pricewin-deal-finder/SKILL.md` for full usage and rules.

### Install (agents)

The skill follows the [agentskills.io](https://agentskills.io) `SKILL.md` standard and
publishes to both ecosystems. `node_modules` and Chromium are **not** bundled — the
install hook fetches them on first install (needs network + `node`/`npx` on PATH).

```bash
# OpenClaw / ClawHub
clawhub skill publish ./skills/pricewin-deal-finder \
  --slug pricewin-deal-finder --name "PriceWin Deal Finder" --version 0.7.0 --tags travel,hotel
openclaw skills install pricewin-deal-finder            # users / agents

# Hermes — install straight from this repo (github: source pulls the whole dir)
hermes skills install github:Price-Win/pricewin-skills-hub/skills/pricewin-deal-finder

# Manual / dev
git clone git@github.com:Price-Win/pricewin-skills-hub.git
cd pricewin-skills-hub/skills/pricewin-deal-finder && ./install.sh
```

## MCP skills — prerequisites

- Pricewin MCP server running (`pricewin-mcp`, stdio transport, auto-launched by Claude)
- Backend API accessible

```json
{
  "mcpServers": {
    "pricewin": {
      "command": "node",
      "args": ["/path/to/pricewin-mcp/dist/index.js"]
    }
  }
}
```
