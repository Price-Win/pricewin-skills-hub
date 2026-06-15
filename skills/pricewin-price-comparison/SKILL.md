---
name: pricewin-price-comparison
description: Compare hotel room prices across Agoda and Booking.com for specific dates. Use when comparing prices, checking room rates, or finding the best deal.
---

# Price Comparison

**Server:** `pricewin` MCP. Queries real-time and cached room prices from Agoda + Booking.com.

## Tools

- **get_hotel_prices**: slug (req), checkIn (req), checkOut (req). Raw room list with per-night and total prices.
- **compare_hotel_prices**: slug (req), checkIn (req), checkOut (req). Smart comparison: sorted by price, cheapest + best-cancellable highlighted, savings calculated.
- **get_hotel_details**: slug (req), locale. Full hotel info including room types and provider links.

| Param | Format | Notes |
|-------|--------|-------|
| slug | string | From search results, e.g. `vinpearl-resort-nha-trang` |
| checkIn | YYYY-MM-DD | Must be today or future |
| checkOut | YYYY-MM-DD | Must be after checkIn |

## Source Interpretation

- `source: "booking"` → live crawl from Booking.com
- `source: "stored"` → cached data; check `crawledAt` for freshness

## Pricing Rules

- `pricePerNight`: per-night rate
- `price`: total stay cost
- `originalPrice`: pre-discount price (if available)
- Currency: usually USD
- Free cancellation: `cancellable: true` — prefer these when price difference is small

## Workflow

1. Get slug from `search_hotels` or `autocomplete_city` → `get_hotel_details`
2. Call `compare_hotel_prices` with dates for ranked comparison
3. Present cheapest + best-cancellable options with OTA booking links

Payload shapes: [reference.md](reference.md).
