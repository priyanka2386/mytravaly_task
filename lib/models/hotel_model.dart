class HotelModel {
  final String propertyCode;
  final String propertyName;
  final String? imageUrl;

  // Address pieces
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? zipcode;

  // Prices
  final double? propertyMinPriceAmount;
  final String? propertyMinPriceDisplay;

  // Reviews
  final double? overallRating;
  final int? totalUserRating;

  // Other
  final String? roomName;
  final bool? freeWifi;
  final bool? payAtHotel;

  HotelModel({
    required this.propertyCode,
    required this.propertyName,
    this.imageUrl,
    this.street,
    this.city,
    this.state,
    this.country,
    this.zipcode,
    this.propertyMinPriceAmount,
    this.propertyMinPriceDisplay,
    this.overallRating,
    this.totalUserRating,
    this.roomName,
    this.freeWifi,
    this.payAtHotel,
  });

  // Friendly getters used in UI
  String get propertyAddress {
    final parts = [
      if (street != null && street!.isNotEmpty) street,
      if (city != null && city!.isNotEmpty) city,
      if (state != null && state!.isNotEmpty) state,
      if (country != null && country!.isNotEmpty) country,
    ].where((p) => p != null && p!.isNotEmpty).toList();

    return parts.join(', ');
  }

  String? get minRate {
    if (propertyMinPriceDisplay != null && propertyMinPriceDisplay!.isNotEmpty) {
      return propertyMinPriceDisplay;
    }
    if (propertyMinPriceAmount != null) {
      return propertyMinPriceAmount!.toStringAsFixed(0);
    }
    return null;
  }

  double? get rating => overallRating;

  // JSON factory
  factory HotelModel.fromJson(Map<String, dynamic> json) {
    // propertyImage.fullUrl might be missing or nested
    String? img;
    try {
      img = json['propertyImage']?['fullUrl'] as String?;
    } catch (_) {
      img = null;
    }

    // propertyMinPrice.amount OR markedPrice/availableDeals might exist
    double? minAmount;
    String? minDisplay;
    try {
      final minPrice = json['propertyMinPrice'];
      if (minPrice != null) {
        minAmount = (minPrice['amount'] is num) ? (minPrice['amount'] as num).toDouble() : null;
        minDisplay = minPrice['displayAmount'] as String?;
      } else if (json['markedPrice'] != null) {
        final m = json['markedPrice'];
        minAmount = (m['amount'] is num) ? (m['amount'] as num).toDouble() : null;
        minDisplay = m['displayAmount'] as String?;
      }
    } catch (_) {
      minAmount = null;
      minDisplay = null;
    }

    // googleReview -> data -> overallRating, totalUserRating
    double? overall;
    int? totalUsers;
    try {
      final gr = json['googleReview'];
      if (gr != null && gr['data'] != null) {
        overall = (gr['data']['overallRating'] is num) ? (gr['data']['overallRating'] as num).toDouble() : null;
        totalUsers = (gr['data']['totalUserRating'] is num) ? (gr['data']['totalUserRating'] as num).toInt() : null;
      }
    } catch (_) {
      overall = null;
      totalUsers = null;
    }

    return HotelModel(
      propertyCode: json['propertyCode']?.toString() ?? '',
      propertyName: json['propertyName']?.toString() ?? 'Unnamed Hotel',
      imageUrl: img,
      street: json['propertyAddress']?['street'] as String?,
      city: json['propertyAddress']?['city'] as String?,
      state: json['propertyAddress']?['state'] as String?,
      country: json['propertyAddress']?['country'] as String?,
      zipcode: json['propertyAddress']?['zipcode'] as String?,
      propertyMinPriceAmount: minAmount,
      propertyMinPriceDisplay: minDisplay,
      overallRating: overall,
      totalUserRating: totalUsers,
      roomName: json['roomName'] as String?,
      freeWifi: json['propertyPoliciesAndAmmenities']?['data']?['freeWifi'] as bool?,
      payAtHotel: json['propertyPoliciesAndAmmenities']?['data']?['payAtHotel'] as bool?,
    );
  }
}
