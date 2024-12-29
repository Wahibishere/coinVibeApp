import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CryptoNews extends StatefulWidget {
  @override
  _CryptoNewsState createState() => _CryptoNewsState();
}

class _CryptoNewsState extends State<CryptoNews> {
  List<dynamic> _news = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedType = 'bullish'; // Default to bullish

  @override
  void initState() {
    super.initState();
    fetchCryptoNews(_selectedType);
  }

  Future<void> fetchCryptoNews(String type) async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear any previous errors
    });

    final String apiUrl =
        'https://openapiv1.coinstats.app/news/type/$type'; // API URL with type
    const String apiKey = 'TWKDD8iwAmdohm/SMFEC31wc1NEkOw1s4atqaXaYIzA=';

    try {
      // Make GET request to the CoinStats API with the required headers
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'X-Api-Key': apiKey, // Pass API key in header
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        setState(() {
          if (data is List) {
            _news = data;
          } else if (data is Map<String, dynamic>) {
            _news = data['result'] ?? [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load news: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // This method returns a button for each news type
  Widget buildTypeMenu() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMenuButton('Bullish'),
          _buildMenuButton('Bearish'),
          _buildMenuButton('Trending'),
          _buildMenuButton('Latest'),
          _buildMenuButton('Handpicked'),
        ],
      ),
    );
  }

  // This method creates a button for each news type
  Widget _buildMenuButton(String type) {
    final bool isSelected = _selectedType.toLowerCase() == type.toLowerCase();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedType = type.toLowerCase();
          });
          fetchCryptoNews(_selectedType);
        },
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.yellow : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crypto News',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add the scrollable menu below the AppBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildTypeMenu(),
          ),
          // Display error message if exists
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          // Loading indicator or list of news
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_news.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _news.length,
                itemBuilder: (context, index) {
                  final newsItem = _news[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.grey[850],
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8.0),
                      leading: newsItem['imgUrl'] != null
                          ? Image.network(
                              newsItem['imgUrl'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : null,
                      title: Text(
                        newsItem['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        newsItem['source'] ?? 'No Source',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.link, color: Colors.white),
                        onPressed: () {
                          final String id = newsItem['id'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailScreen(newsId: id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final String newsId;

  const NewsDetailScreen({Key? key, required this.newsId}) : super(key: key);

  Future<Map<String, dynamic>> fetchNewsDetail() async {
    final String apiUrl = 'https://openapiv1.coinstats.app/news/$newsId';
    const String apiKey = 'TWKDD8iwAmdohm/SMFEC31wc1NEkOw1s4atqaXaYIzA=';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'X-Api-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load news details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News Details',
        ),
        backgroundColor: Colors.yellow,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchNewsDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final newsDetail = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (newsDetail['imgUrl'] != null)
                      Image.network(newsDetail['imgUrl']),
                    const SizedBox(height: 16.0),
                    Text(
                      newsDetail['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      newsDetail['source'] ?? 'No Source',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      newsDetail['description'] ?? 'No Description',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
