import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class ShowChartScreen extends StatefulWidget {
  final String cryptoId;
  final String vsCurrency;

  const ShowChartScreen({
    Key? key,
    required this.cryptoId,
    required this.vsCurrency,
  }) : super(key: key);

  @override
  _ShowChartScreenState createState() => _ShowChartScreenState();
}

class _ShowChartScreenState extends State<ShowChartScreen> {
  List<FlSpot> _chartData = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    final url =
        'https://api.coingecko.com/api/v3/coins/${widget.cryptoId}/market_chart?vs_currency=${widget.vsCurrency}&days=30';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> prices = data['prices'];
        setState(() {
          _chartData = prices
              .map((price) => FlSpot(
                    (price[0] as num).toDouble(),
                    (price[1] as num).toDouble(),
                  ))
              .toList();
          _minX = _chartData.first.x;
          _maxX = _chartData.last.x;
          _minY =
              _chartData.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
          _maxY =
              _chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load chart data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load chart data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double interval = (_maxX - _minX) / 10;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Chart for ${widget.cryptoId} / ${widget.vsCurrency}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        2, // Adjust the width as needed
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: _chartData,
                            isCurved: true,
                            color: Colors.yellow,
                            barWidth: 2,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.yellow.withOpacity(0.3),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                value.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: interval == 0
                                  ? 1
                                  : interval, // Ensure interval is not zero
                              getTitlesWidget: (value, meta) => Text(
                                value.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey),
                        ),
                        minX: _minX,
                        maxX: _maxX,
                        minY: _minY,
                        maxY: _maxY,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            // tooltipBgColor: Colors.yellow,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((touchedSpot) {
                                return LineTooltipItem(
                                  '${touchedSpot.x}, ${touchedSpot.y}',
                                  const TextStyle(color: Colors.black),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
