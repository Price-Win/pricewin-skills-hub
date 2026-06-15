---
name: pricewin-deal-finder
description: "Hotel price comparison & deals across Booking, Agoda, Google Hotels, and OpenTravel for given travel dates and guest count. Use for hotel prices, deals, or comparing OTA rates."
version: 0.8.1
author: PriceWin
platforms: [linux, macos, windows]
tags: [hotel, travel, booking, agoda, google, opentravel, price-comparison, deals, ota]
metadata:
  openclaw:
    requires:
      bins: [node, npx]
    envVars:
      - name: OPENTRAVEL_API_BASE_URL
        required: false
        description: Override the OpenTravel API host (default https://api.opentravel.one).
    emoji: "🏨"
    homepage: https://github.com/Price-Win/pricewin-skills-hub
---

# PriceWin Deal Finder

## 🚨 IMPORTANT — HOW TO USE THIS SKILL

**ONE command does everything. Run this as your FIRST action — no clarifying questions first:**

```bash
cd {baseDir} && node bin/search.js "<city>" <checkInYYYY-MM-DD> <checkOutYYYY-MM-DD> <adults> en-us
```

`{baseDir}` is this skill's install directory (auto-resolved by the runtime). If your runtime does not substitute it, `cd` into the folder that contains this `SKILL.md` (the one with `bin/search.js`). Do NOT hardcode a `~/.hermes/...` or `~/.openclaw/...` path — it differs per platform.

Example:
```bash
cd {baseDir} && node bin/search.js "Hangzhou" 2026-06-10 2026-06-13 2 en-us
```

The script handles everything automatically: daemon launch, Booking + Agoda cache lookup, Google Hotels inline search, OpenTravel API lookup, discovery for new cities, and formatted tier-card output. Just run it and send the output to the user.

**DO NOT ask clarifying questions first.** Just run the command. Infer all parameters:
- **Year:** use the current year from today's date unless the user states otherwise. If the requested day/month has already passed this year, assume next year. (Get today's date with `date +%Y-%m-%d` if unsure.)
- **"10-13/6"** → `<year>-06-10 <year>-06-13` — fill `<year>` from the rule above
- **"2 guests" / "2 people"** → `2` adults
- **Locale:** language/region code passed to the OTAs (controls site language + region). Default `en-us`. Prices are in USD (Google Hotels is requested with `gl=us&curr=USD`); other sources follow the locale you pass.

**DO NOT use any other approach.** No Python scripts, no curl, no browser tools, no subagents. This one command is all you need.

---

## 🚨 CRITICAL RULES — FOLLOW EVERY TIME

**RULE 0 — FORBIDDEN TOOLS. Read this twice.** This skill drives a long-running Patchright daemon via the `terminal` tool ONLY. Your runtime exposes several other tools that LOOK convenient but are STRICTLY FORBIDDEN inside this skill:

❌ `browser_navigate` / `browser_open` — FORBIDDEN
❌ `browser_click` — FORBIDDEN
❌ `browser_type` / `browser_fill` — FORBIDDEN
❌ `browser_snapshot` — FORBIDDEN
❌ `browser_close` — FORBIDDEN
❌ Any other `browser_*` native tool — FORBIDDEN
❌ `delegate_task` / `spawn_agent` / sub-agent delegation — FORBIDDEN

Why: those native tools spawn a vanilla Chromium without stealth, so Booking.com and Agoda detect the bot within seconds and the requests just hang until the runtime kills them with "Command timed out after 30/60 seconds". You will burn 5+ minutes on timeouts and the user will get nothing. The Patchright daemon launched via `terminal` survives bot-detection.

Delegated subagents start with empty history and no skill context — they will always fall back to Python/curl scraping, which gets bot-blocked immediately. **This skill must run entirely in the current agent, using only the `terminal` tool.**

✅ The ONLY allowed way to drive a browser in this skill is via `terminal`:
```
terminal: cd {baseDir} && node bin/search.js ...
```

**RULE 1 — `search.js` handles everything.** Do not manually call `browse.js` commands, do not call the OpenTravel API separately, do not try to launch the daemon yourself. `search.js` does all of that. Your only job is to call `search.js` and send its output to the user.

**RULE 2 — First-time city discovery takes 2–4 minutes.** If `search.js` output contains `"discovering"` or `"launching"` messages, tell the user: "First time searching this city — discovering selectors, this takes about 2–4 minutes..." and wait for the result. Do NOT retry or abort.

**RULE 3 — Send the output exactly.** `search.js` outputs formatted tier cards ready to send. Copy the output directly into your response. Do not reformat, summarize, or abbreviate it.

**RULE 3a — PRESERVE MARKDOWN HYPERLINKS.** Every hotel name in the output is already wrapped as `[Hotel Name](https://booking-url...)`. This is a clickable hyperlink — DO NOT:
- Strip the markdown and show the URL on a separate `🔗 https://...` line
- Replace `[Hotel Name](url)` with plain text
- Capitalize OTA names ("google" stays "google", not "Google")
- Rename sections — "📋 More good deals" stays exactly

The output is Telegram-MarkdownV2-ready. Sending it as-is gives the user clickable hotel names with hidden URLs (clean UI).

**RULE 3b — If you DO add a suggestion / commentary section after the output, every hotel name you mention MUST also be a markdown hyperlink `[Hotel Name](url)` using the SAME URL the script printed for that hotel.** Never write a hotel name as plain text in your own commentary.

**RULE 4 — If `search.js` errors:** Tell the user what failed in 1 line, then list any partial results (e.g. OpenTravel-only) the script may have printed above the error.

---

## Output Format Reference

`search.js` prints tier cards in this format — you send this directly to the user:

The hotel name is a Markdown link to its cheapest OTA. Price rows carry NO
links and the OTA key is shown lowercase (`agoda`/`booking`/`google`/`opentravel`).
There are no star ratings or area lines — the script does not have that data.

```
🏨 <city> • <d1>–<d2> • <N> nights • <adults> guests
━━━━━━━━━━━━━━━━━━━━

🥇 BEST VALUE
[<Hotel Name>](<cheapest_link>)
  ✅ agoda      💰 <price>/night
     booking    💰 <price>/night
     opentravel 💰 <price>/night
     → Save <diff> vs Booking

🥈 CHEAPEST
[<Hotel Name>](<cheapest_link>)
  ✅ google     💰 <price>/night
     agoda      💰 <price>/night

🥉 QUALITY
[<Hotel Name>](<cheapest_link>)
  ✅ booking    💰 <price>/night
     agoda      💰 <price>/night

📋 More good deals
  — Agoda —
  • [<Hotel>](<agoda_link>) — agoda: <price> | booking: <price>
  — Booking —
  • [<Hotel>](<booking_link>) — booking: <price>
  — Google —
  • [<Hotel>](<google_link>) — google: <price>
  — OpenTravel —
  • [<Hotel>](<opentravel_link>) — opentravel: <price>

💡 Tip: <best Hotel Name>
   [Book on <OTA>](<link>) — <price>/night

📊 <N> hotels | <sources with data> • prices in USD
```

All prices are converted to USD (every OTA prices in VND for this region; a live FX rate is applied). Only sources that actually returned data are listed in the footer.

---

## Limitations

- First search per city pays the discovery cost (2–4 minutes for Booking + Agoda).
- Subsequent searches reuse the cache and complete in ~30 seconds.
