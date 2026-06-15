---
name: pricewin-booking-assistant
description: Recommend hotels and rooms, generate direct OTA booking links for Agoda and Booking.com. Use when booking a hotel, getting room recommendations, or generating booking links.
---

# Booking Assistant

**Server:** `pricewin` MCP. Orchestrates search → compare → recommend workflow across Agoda + Booking.com.

## Recommendation Algorithm

1. **Search**: `search_hotels` with city + guest count + budget filters
2. **Score**: rating × log(reviewCount + 1) — balances quality with credibility
3. **Rank**: top 3-5 hotels by score
4. **Compare**: `compare_hotel_prices` for each shortlisted hotel
5. **Recommend**: filter rooms by guest capacity → pick best value

## Booking Link Rules

- **NEVER invent URLs** — only use `url` from `providers[]` or room data
- Links go directly to OTA (Agoda/Booking.com) booking pages
- Always show the OTA source name alongside the link
- If multiple OTAs have the same room, show both with prices

## Multi-Hotel Comparison

When user wants to compare across hotels:
1. `search_hotels` with filters → get top candidates
2. `compare_hotel_prices` for each (parallel if possible)
3. Present side-by-side: hotel name, best room price, cancellation, rating

## Output Format

For each recommendation:
```
### Hotel Name ★★★★☆
- Rating: 8.5/10 (1,234 reviews)
- Best room: Deluxe Double — $85/night
- Free cancellation: Yes
- Book: [Agoda](url) | [Booking.com](url)
```

## Key Parameters

| Tool | When to Use |
|------|-------------|
| `search_hotels` | Initial discovery with filters |
| `get_hotel_details` | Deep dive on a specific hotel |
| `compare_hotel_prices` | Date-specific price comparison |
| `get_popular_hotels` | Quick recommendations without filters |
| `autocomplete_city` | Resolve city name to slug |

Payload shapes: [reference.md](reference.md).
