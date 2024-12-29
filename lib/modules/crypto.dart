class Crypto {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double marketCap;
  final double priceChange1h;
  final double priceChange1d;
  final double priceChange1w;
  final String? iconUrl;

  Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.marketCap,
    required this.priceChange1h,
    required this.priceChange1d,
    required this.priceChange1w,
    this.iconUrl,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'].toString(), // Ensure id is treated as a String
      name: json['name'] ?? 'Unknown',
      symbol: json['symbol'] ?? '',
      price: (json['quote']?['USD']?['price'] ?? 0.0)
          .toDouble(), // Handle null price
      marketCap: (json['quote']?['USD']?['market_cap'] ?? 0.0)
          .toDouble(), // Handle null market cap
      priceChange1h:
          (json['quote']?['USD']?['percent_change_1h'] ?? 0.0).toDouble(),
      priceChange1d:
          (json['quote']?['USD']?['percent_change_24h'] ?? 0.0).toDouble(),
      priceChange1w:
          (json['quote']?['USD']?['percent_change_7d'] ?? 0.0).toDouble(),
      iconUrl: json['icon_url'],
    );
  }
}
