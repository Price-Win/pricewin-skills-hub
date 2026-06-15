# Booking Assistant – Response shapes

**SearchResponse:** data (HotelResponse[]), total, page, totalPages

**HotelResponse:** id, name, slug, city, citySlug, address, stars, rating, reviewCount, pricePerNight, currency, thumbnail, images[], amenities[], description, latitude, longitude, providers (ProviderPrice[]), originalPrice?, roomTypes?, reviews?

**ProviderPrice:** name, price, url, currency — these are the ONLY valid booking links

**HotelPricesResponse:** hotelName, checkIn?, checkOut?, rooms (RoomPriceDetail[]), source, crawledAt

**RoomPriceDetail:** name, bedType?, maxGuests?, roomSize?, price?, pricePerNight?, originalPrice?, currency, breakfast?, cancellable?, cancellationPolicy?, availability?, amenities[]

**Scoring formula:** score = rating × log(reviewCount + 1). Hotels with rating ≥ 8.0 and reviewCount ≥ 100 are strong candidates.

**Currency:** USD default. No conversion — present prices as-is from API.
