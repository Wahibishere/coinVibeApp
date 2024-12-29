import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modules/coinListModel.dart';

class FetchCoinService {
  final String _baseUrl =
      'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest';
  final String _apiKey = '46c733c2-adbb-403f-9428-8463fc7a554c';

  Future<List<Crypto>> fetchLatestSpotPairs() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'X-CMC_PRO_API_KEY': _apiKey,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? [];

      // Convert List<dynamic> to List<Crypto>
      return data.map((item) => Crypto.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  }

  Future<Crypto?> fetchCryptoById(String id) async {
    final String url =
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/info?id=$id';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-CMC_PRO_API_KEY': _apiKey,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final Map<String, dynamic> data = jsonResponse['data'] ?? {};

      if (data.containsKey(id)) {
        return Crypto.fromJson(data[id]);
      } else {
        throw Exception('Crypto with ID $id not found');
      }
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  }
}
