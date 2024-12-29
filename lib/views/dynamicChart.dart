import 'package:flutter/material.dart';
import 'package:mad_project/modules/liveChartModel.dart';
import '../services/liveCharts/fetchChart.dart' as fetchChart;
import '../screens/showChartScreen.dart';

class DynamicChartScreen extends StatefulWidget {
  @override
  _DynamicChartScreenState createState() => _DynamicChartScreenState();
}

class _DynamicChartScreenState extends State<DynamicChartScreen> {
  late Future<List<Map<String, String>>> _cryptosFuture;
  late Future<List<String>> _fiatsFuture;
  String? _selectedCrypto;
  String? _selectedFiat;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cryptosFuture = fetchChart.CoinGeckoService().fetchCoinsList();
    _fiatsFuture = fetchChart.CoinGeckoService().fetchSupportedCurrencies();
  }

  void _showChart() {
    if (_selectedCrypto != null && _selectedFiat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowChartScreen(
            cryptoId: _selectedCrypto!,
            vsCurrency: _selectedFiat!,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Please select both cryptocurrency and fiat currency.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<List<Map<String, String>>>(
              future: _cryptosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No cryptocurrencies available');
                } else {
                  return DropdownButton<String>(
                    hint: Text('Select Cryptocurrency'),
                    value: _selectedCrypto,
                    onChanged: (value) {
                      setState(() {
                        _selectedCrypto = value;
                      });
                    },
                    items: snapshot.data!.map((crypto) {
                      return DropdownMenuItem<String>(
                        value: crypto['id'],
                        child: Text(crypto['name']!),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            SizedBox(height: 16.0),
            FutureBuilder<List<String>>(
              future: _fiatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No fiat currencies available');
                } else {
                  return DropdownButton<String>(
                    hint: Text('Select Fiat Currency'),
                    value: _selectedFiat,
                    onChanged: (value) {
                      setState(() {
                        _selectedFiat = value;
                      });
                    },
                    items: snapshot.data!.map((fiat) {
                      return DropdownMenuItem<String>(
                        value: fiat,
                        child: Text(fiat.toUpperCase()),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _showChart,
              child: Text('Show Chart'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
