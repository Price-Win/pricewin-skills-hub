# Price Comparison – Response shapes

**HotelPricesResponse:** hotelName, checkIn?, checkOut?, rooms (RoomPriceDetail[]), source, crawledAt

**RoomPriceDetail:** name, bedType?, maxGuests?, roomSize?, price?, pricePerNight?, originalPrice?, currency, breakfast?, cancellable?, cancellationPolicy?, availability?, amenities[]

**HotelDetailResponse:** extends HotelResponse + roomTypes (RoomType[]), reviewHighlights[], nearbyPlaces ({name, distance}[]), reviewGrades (Record<string, number>)

**RoomType:** name, price, maxGuests, bedType, amenities[]

**Notes:** price and pricePerNight may both be present; prefer price for total cost comparison. cancellable=true means free cancellation available.
