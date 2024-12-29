import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _news = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    const String apiUrl =
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/news/latest';
    const String apiKey =
        'CG-LzGfBhfM1fTPuViijeSt2LHh'; // Replace with your key.

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accepts': 'application/json',
          'X-CMC_PRO_API_KEY': apiKey, // Add your API key here.
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _news =
              data['data']; // Update based on actual JSON response structure.
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch news: ${response.body}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto News'),
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
              : ListView.builder(
                  itemCount: _news.length,
                  itemBuilder: (context, index) {
                    final article = _news[index];
                    return ListTile(
                      title: Text(
                        article['title'] ?? 'No Title',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        article['description'] ?? 'No Description',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        if (article['url'] != null) {
                          _openUrl(article['url']);
                        }
                      },
                    );
                  },
                ),
    );
  }

  void _openUrl(String url) async {
    // Add logic to open URLs, like using `url_launcher` package.
    print('Open URL: $url'); // Placeholder for URL opening logic.
  }
}
