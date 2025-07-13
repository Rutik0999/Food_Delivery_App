class City {
  final int cityId;
  final String cityName;
  final String state;
  final String country;

  City({
    required this.cityId,
    required this.cityName,
    required this.state,
    required this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      cityId: json['cityId'],
      cityName: json['cityName'],
      state: json['state'],
      country: json['country'],
    );
  }
}
