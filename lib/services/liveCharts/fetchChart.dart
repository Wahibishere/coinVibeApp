import 'dart:convert';
import 'package:http/http.dart' as http;

class CoinGeckoService {
  final String baseUrl = 'https://api.coingecko.com/api/v3';

  // Fetch the list of coins
  Future<List<Map<String, String>>> fetchCoinsList() async {
    final String url = '$baseUrl/coins/list';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, String>>.from(data.map((coin) => {
            'id': coin['id'],
            'name': coin['name'],
          }));
    } else {
      throw Exception(
          'Failed to load coins list. Error: ${response.statusCode}');
    }
  }

  // Fetch supported currencies
  Future<List<String>> fetchSupportedCurrencies() async {
    final String url = '$baseUrl/simple/supported_vs_currencies';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to load supported currencies. Error: ${response.statusCode}');
    }
  }

  // Fetch historical data for the chart
  Future<List<List<dynamic>>> fetchHistoricalData(
      String coinId, String currency) async {
    final String url =
        '$baseUrl/coins/$coinId/market_chart?vs_currency=$currency&days=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['prices'] != null) {
        return List<List<dynamic>>.from(data['prices']);
      } else {
        throw Exception('No price data found for $coinId in $currency.');
      }
    } else {
      throw Exception(
          'Failed to load historical data. Error: ${response.statusCode}');
    }
  }
}
