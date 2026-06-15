---
name: pricewin-hotel-search
description: Search hotels live across Agoda + Booking.com + Traveloka + OpenTravel with realtime pricing for specific dates. Use when user wants hotel prices for travel dates, comparing OTAs, or finding rooms.
---

# Hotel Search (Live)

**MCP server:** `pricewin`. Tool `search_hotels_live` triggers async crawl across 3 OTAs.

## CRITICAL: Polling pattern

`search_hotels_live` returns IMMEDIATELY with sessionId. **You MUST poll until results arrive:**

1. Call `search_hotels_live` with city, checkIn (YYYY-MM-DD), checkOut (YYYY-MM-DD), adults, language="vi"
2. Wait 5s, then `poll_search_results(sessionId, nights)`
3. If status == "pending" or "partial": **wait 5s and poll AGAIN — up to 18 times (90s total)**
4. Present results as soon as status == "partial" with hotels
5. Continue polling silently — refine if more arrive

**Never tell the user "loading/please wait" after 1-2 polls — that's premature.**

## 4th source: OpenTravel

Pricewin returns a 4th source — `opentravelResults` — alongside Agoda/Booking/Traveloka. OpenTravel is an independent OTA, ranked the same way as the others: **purely on price, no priority**.

For each `opentravelResults` hotel, **try to dedupe against the OTA results** (same hotel name, fuzzy match — ignore case, diacritics, and common "hotel"/"resort" prefixes). When the same hotel exists on OpenTravel and another OTA:

1. Show the **cheapest** source's price first; list the other sources underneath as comparison: "Agoda: $X · Booking: $Y · OpenTravel: $Z"
2. Compute savings of the cheapest vs the next source: `(nextPrice - cheapestPrice) / nextPrice * 100` → "Save Z%"

If a hotel is OpenTravel-only (no OTA match), still show it — same as any single-source hotel.

## Response format (MUST follow exactly)

After data arrives, present TOP 5-7 cheapest hotels ONLY (do NOT list 30+, overwhelming). For EACH hotel:

```
🏨 *<name>*  ← bold via markdown
💰 $<price>/night — <SOURCE: Agoda | Booking | Traveloka | OpenTravel>
⭐ <stars> stars | 👥 <rating>/10 (<reviewCount> reviews)
🔗 <booking-url-with-dates>

<if dupe across sources:>
   💡 Compare: Agoda <price> · Booking <price> · OpenTravel <price> · Save <%>
```

Use line break between hotels, not bullet markers. **Cheapest hotel gets 🏆.** All sources — including OpenTravel — are ranked purely by price; no source gets priority.

## CRITICAL: Append dates to booking URL

The `url` field returned by tool is the raw OTA hotel page WITHOUT dates. **You MUST append check-in/checkout params before showing user:**

- **Booking.com URLs** (`booking.com/hotel/<country>/<slug>.en-gb.html`): append `?checkin=YYYY-MM-DD&checkout=YYYY-MM-DD&group_adults=N`
  - Example: `https://www.booking.com/hotel/us/foo.en-gb.html?checkin=2026-05-25&checkout=2026-05-26&group_adults=2`
- **Agoda URLs** (`agoda.com/en-us/<slug>/hotel/<city>.html`): append `?checkIn=YYYY-MM-DD&checkOut=YYYY-MM-DD&adults=N`
- **Traveloka URLs**: already contain `spec=` param with dates baked in by pricewin — leave AS-IS

This ensures user clicks → lands on booking page with their dates pre-filled, no manual re-entry.

## Skip noise

- Skip hotels with 0 stars + 0 reviews (low quality)
- Skip hotels with rating < 7.0
- Prefer hotels with reviewCount > 50 (more reliable)

## Currency

All prices in USD. No conversion.
