# Hotel Search – Response shapes

**SearchResponse:** data (HotelResponse[]), total, page, totalPages

**HotelResponse:** id, name, slug, city, citySlug, address, stars, rating (0-10), reviewCount, pricePerNight, currency, thumbnail, images[], amenities[], description, latitude, longitude, providers (ProviderPrice[]), originalPrice?, roomTypes?, reviews?

**ProviderPrice:** name (agoda|booking), price, url, currency

**AutocompleteResponse:** label, value (city slug), type ("city")

**CityStats:** city, citySlug, count

**RegionDestinationsResponse:** region, countries (CountryDestination[])

**CountryDestination:** name, isoCode, cities (CityDestination[])

**CityDestination:** name, displayName, slug, hotelCount, image?
