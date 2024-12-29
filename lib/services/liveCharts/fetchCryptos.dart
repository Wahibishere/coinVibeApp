import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FetchCryptos {
  static const String _url = "https://api.coingecko.com/api/v3/coins/list";
  static const String _fileName = "cryptos.json"; // File name for local storage

  // Custom method to get the application documents directory without using path_provider
  static Future<Directory> getApplicationDocumentsDirectory() async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = Directory(
          '/storage/emulated/0/Download'); // Common directory for Android
    } else if (Platform.isIOS) {
      directory = Directory(
          '${Platform.environment['HOME']}/Documents'); // Common directory for iOS
    } else {
      directory = Directory.systemTemp;
    }
    return directory;
  }

  // Fetch cryptocurrencies and save them as JSON if the file doesn't exist
  static Future<List<String>> initializeCryptos() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');

    if (await file.exists()) {
      print("Cryptocurrency JSON file already exists at: ${file.path}");
      return readCryptos(file); // Read from existing file
    } else {
      print("Cryptocurrency JSON file not found. Fetching data...");
      return fetchAndSaveCryptos(file); // Fetch and save data
    }
  }

  // Fetch cryptocurrencies and save them as JSON
  static Future<List<String>> fetchAndSaveCryptos(File file) async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        // Write data to the file
        await file.writeAsString(json.encode(data));
        print("Cryptocurrency data saved to ${file.path}");
        return data.map((crypto) => crypto['name'] as String).toList();
      } else {
        throw Exception(
            'Failed to fetch cryptocurrencies: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching cryptocurrencies: $e");
      return [];
    }
  }

  // Read from the saved JSON file
  static Future<List<String>> readCryptos(File file) async {
    if (await file.exists()) {
      final data = await file.readAsString();
      final List<dynamic> jsonData = json.decode(data);
      return jsonData.map((crypto) => crypto['name'] as String).toList();
    } else {
      throw Exception("JSON file not found. Please fetch cryptos first.");
    }
  }
}
