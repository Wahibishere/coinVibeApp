import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FetchFiats {
  static const String _url =
      "https://api.coingecko.com/api/v3/simple/supported_vs_currencies";
  static const String _fileName = "fiats.json"; // File name for local storage

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

  // Fetch fiat currencies and save them as JSON if the file doesn't exist
  static Future<List<String>> initializeFiats() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_fileName');

    if (await file.exists()) {
      print("Fiat currency JSON file already exists at: ${file.path}");
      return readFiats(file); // Read from existing file
    } else {
      print("Fiat currency JSON file not found. Fetching data...");
      return fetchAndSaveFiats(file); // Fetch and save data
    }
  }

  // Fetch fiat currencies and save them as JSON
  static Future<List<String>> fetchAndSaveFiats(File file) async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        // Write data to the file
        await file.create(recursive: true);
        await file.writeAsString(json.encode(data));
        print("Fiat currency data saved to ${file.path}");
        return data.map((fiat) => fiat as String).toList();
      } else {
        throw Exception(
            'Failed to fetch fiat currencies: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching fiat currencies: $e");
      return [];
    }
  }

  // Read from the saved JSON file
  static Future<List<String>> readFiats(File file) async {
    if (await file.exists()) {
      try {
        final data = await file.readAsString();
        final List<dynamic> jsonData = json.decode(data);
        return jsonData.map((fiat) => fiat as String).toList();
      } catch (e) {
        print("Error reading fiat JSON file: $e");
        return [];
      }
    } else {
      throw Exception("JSON file not found. Please fetch fiats first.");
    }
  }
}
