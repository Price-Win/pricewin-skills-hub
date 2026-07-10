# Pricewin Skills Hub

**Find the cheapest hotel deal in one command.** AI-agent skills that compare
**live** prices across Booking.com, Agoda, Google Hotels & OpenTravel and hand
back ranked best-value / cheapest / quality picks with direct booking links.

> ⭐ **Most popular skill: [`pricewin-hotel-deal-finder`](https://www.skills.sh/price-win/pricewin-skills-hub/pricewin-hotel-deal-finder)** — standalone, no MCP server, no API keys.
>
> ```bash
> npx skills add https://github.com/Price-Win/pricewin-skills-hub --skill pricewin-hotel-deal-finder
> ```

```
🏨 Tokyo • Aug 12–15 • 3 nights • 2 guests
━━━━━━━━━━━━━━━━━━━━
🥇 BEST VALUE   Shinjuku Granbell Hotel   ✅ agoda $118  ·  booking $131  → save $13
🥈 CHEAPEST     APA Hotel Shinjuku        ✅ google $94
📊 18 hotels | agoda, booking, google, opentravel • prices in USD
```

Why people install it:
- 🥇🥈🥉 best-value / cheapest / quality picks, side by side
- 4 sources, all normalized to **USD**, with clickable links to the cheapest OTA
- Works for **any city worldwide** — even bot-hardened ones (Shanghai, Hangzhou, Bangkok) via a stealth Patchright daemon
- No MCP server, no API keys — just `node` + `npx`

---

Skills for AI agents to search hotels, compare OTA prices, and surface the best
booking deals. Two families:

- **MCP skills** — drive the Pricewin MCP server (`pricewin`).
- **Standalone skill** — `pricewin-hotel-deal-finder` runs its own browser + API stack,
  no MCP server required.

**Repo:** `git@github.com:Price-Win/pricewin-skills-hub.git`

## Skills

| Skill | Type | Trigger | Sources / Tools |
|-------|------|---------|-----------------|
| `pricewin-hotel-search` | MCP | search/find hotels live for travel dates | `search_hotels_live` → `poll_search_results` (Agoda + Booking.com + Traveloka, plus `opentravelResults` OpenTravel listings) |
| `pricewin-price-comparison` | MCP | compare prices, check room rates | `search_hotels`, `autocomplete_city`, `get_hotel_prices`, `compare_hotel_prices`, `get_hotel_details` |
| `pricewin-booking-assistant` | MCP | recommend room, generate booking link | orchestrates search → compare → recommend (`search_hotels`, `compare_hotel_prices`, `get_hotel_details`, `get_popular_hotels`) |
| `pricewin-hotel-deal-finder` | Standalone | hotel deals / price comparison for travel dates | Browser automation (Patchright) over Booking.com + Agoda + Google Hotels, plus the **OpenTravel** public API — no MCP server |

## `pricewin-hotel-deal-finder` (standalone)

Self-contained skill: a long-running Patchright (stealth Chromium) daemon scrapes
Booking.com, Agoda, and Google Hotels, while a single HTTPS call hits the
OpenTravel public API. One command does everything:

```bash
node bin/search.js "<city>" <checkIn YYYY-MM-DD> <checkOut YYYY-MM-DD> <adults> en-us
```

- **OpenTravel API base:** `https://api.opentravel.one`
  (override with `OPENTRAVEL_API_BASE_URL`)
- **Setup:** `skills/pricewin-hotel-deal-finder/install.sh` (Node deps + Chromium, ~200MB one-time)
- **Cache:** `~/.cache/pricewin-hotel-deal-finder/selectors.json`

See `skills/pricewin-hotel-deal-finder/SKILL.md` for full usage and rules.

**Roadmap:** hotels ship today; **flight** and **rental-car** price comparison are on the way — the same one-command, multi-source, USD-normalized deal-finding, extended across your whole trip. (Powered by [PriceWin](https://price.win) — *tìm giá tốt nhất* across 50+ travel platforms.)

### Install (agents)

The skill follows the [agentskills.io](https://agentskills.io) `SKILL.md` standard and
publishes to both ecosystems. `node_modules` and Chromium are **not** bundled — the
install hook fetches them on first install (needs network + `node`/`npx` on PATH).

```bash
# OpenClaw / ClawHub
clawhub skill publish ./skills/pricewin-hotel-deal-finder \
  --slug pricewin-hotel-deal-finder --name "PriceWin Hotel Deal Finder" --version 0.7.0 --tags travel,hotel
openclaw skills install pricewin-hotel-deal-finder            # users / agents

# Hermes — install straight from this repo (github: source pulls the whole dir)
hermes skills install github:Price-Win/pricewin-skills-hub/skills/pricewin-hotel-deal-finder

# Manual / dev
git clone git@github.com:Price-Win/pricewin-skills-hub.git
cd pricewin-skills-hub/skills/pricewin-hotel-deal-finder && ./install.sh
```

## FAQ

**Is Booking.com or Agoda cheaper?** Neither wins universally — it depends on the hotel, dates, and region. Independent tests (CNBC's review of ~200,000 hotel searches) found **Agoda had the lowest rate about 34% of the time** globally, and it tends to win in **Asia-Pacific** while **Booking.com pulls ahead more often in Europe**. That is exactly why `pricewin-hotel-deal-finder` queries **both** (plus Google Hotels and OpenTravel) in a single run, shows the per-night gap, labels the cheapest source per property, and links you straight to it — so you never have to guess.

**How many sources does it compare, and how fast?** Up to **4 sources** (Booking.com, Agoda, Google Hotels, OpenTravel), all normalized to **USD**. A cached city returns in **~30–60 seconds**; a brand-new city pays a one-time Agoda discovery cost of **2–4 minutes**, then joins the cache.

**Do I need API keys or an MCP server?** No. `pricewin-hotel-deal-finder` is standalone — `node` + `npx` is all it needs. The only external dependency is Chromium (~200 MB), fetched once by the install hook.

**Does it work for bot-hardened cities?** Yes. A stealth Patchright (stealth Chromium) daemon handles anti-bot detection, so cities like Shanghai, Hangzhou, and Bangkok resolve where vanilla scrapers get blocked.

**How are prices normalized?** Booking.com returns USD natively; Agoda, Google Hotels, and OpenTravel geo-lock to VND by IP and are converted via a live FX rate. Every price in the output is USD.

**What does one command return?** Ranked **best-value 🥇 · cheapest 🥈 · quality 🥉** picks, each hotel name a clickable link to its cheapest OTA, plus a "More good deals" list grouped by source and a USD footer of exactly which sources returned data.

> _Last verified: 2026-07-08 · reviewed quarterly._

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
