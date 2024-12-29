// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class FetchCoinService {
//   final String _baseUrl =
//       'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest';
//   final String _apiKey =
//       '46c733c2-adbb-403f-9428-8463fc7a554c'; // Replace with your API key

//   Future<List<dynamic>> fetchLatestSpotPairs() async {
//     try {
//       final response = await http.get(
//         Uri.parse(_baseUrl),
//         headers: {
//           'X-CMC_PRO_API_KEY': _apiKey,
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['data']; // Return the 'data' array
//       } else {
//         throw Exception('Failed to fetch data: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching latest spot pairs: $e');
//     }
//   }
// }
