class Crypto {
  final String id;
  final String name;
  final String symbol;
  final double? price;
  final double? marketCap;
  final double? priceChange24h;
  final String? iconUrl; // Nullable field for icon

  Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    this.price,
    this.marketCap,
    this.iconUrl,
    this.priceChange24h,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      symbol: json['symbol'] ?? 'N/A',
      price: json['quote']?['USD']?['price']?.toDouble(),
      marketCap: json['quote']?['USD']?['market_cap']?.toDouble(),
      priceChange24h: json['quote']?['USD']?['percent_change_24h']?.toDouble(),
      iconUrl:
          json['iconUrl'], // Update this field based on the actual API response
    );
  }
}
