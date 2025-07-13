class Restaurant {
  final int restaurantId;
  final String name;
  final String address;
  final String pincode;
  final String imageUrl;
  final double rating;
  final String cityName;

  Restaurant({
    required this.restaurantId,
    required this.name,
    required this.address,
    required this.pincode,
    required this.imageUrl,
    required this.rating,
    required this.cityName,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantId: json['restaurantId'],
      name: json['name'],
      address: json['address'],
      pincode: json['pincode'],
      imageUrl: json['imageUrl'],
      rating: (json['rating'] as num).toDouble(),
      cityName: json['cityName'],
    );
  }
}
