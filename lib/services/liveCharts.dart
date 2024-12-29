import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CryptoChartScreen extends StatefulWidget {
  const CryptoChartScreen({super.key});

  @override
  _CryptoChartScreenState createState() => _CryptoChartScreenState();
}

class _CryptoChartScreenState extends State<CryptoChartScreen> {
  final String _apiKey = "YOUR_API_KEY"; // Replace with your API key
  List<dynamic> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  // Fetching data from the CoinMarketCap API
  Future<void> fetchChartData() async {
    final String baseUrl = "https://pro-api.coinmarketcap.com";
    final String endpoint = "/v4/dex/pairs/trade/latest";

    // Set the required parameters
    final String contractAddress =
        "0x1234567890abcdef"; // Use the actual token address
    final String networkId = "1"; // Ethereum mainnet, change accordingly
    final String skipInvalid =
        "true"; // Set to true or false based on your requirement

    final String url =
        "$baseUrl$endpoint?contract_address=$contractAddress&network_id=$networkId&skip_invalid=$skipInvalid";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "X-CMC_PRO_API_KEY": _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _chartData = data['data']; // Adjust according to the actual response
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load chart data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Crypto Chart"),
        backgroundColor: Colors.grey[850],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _chartData.length,
              itemBuilder: (context, index) {
                final data = _chartData[index];
                return ListTile(
                  title: Text("Pair: ${data['pair']}"),
                  subtitle: Text("Price: ${data['price']} USD"),
                );
              },
            ),
      backgroundColor: Colors.grey[900],
    );
  }
}
