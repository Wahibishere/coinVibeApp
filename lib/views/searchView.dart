import 'package:flutter/material.dart';
import 'package:mad_project/modules/coinListModel.dart';
// import '../modules/crypto.dart';
// import '../services/fetchCrypto.dart';
import '../services/coinListService.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final fetchCoinService = FetchCoinService();
  final TextEditingController _searchController = TextEditingController();
  List<Crypto> _cryptoList = []; // Holds all crypto data
  List<Crypto> _filteredCryptoList = []; // Holds search results
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCryptoData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCryptoData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<Crypto> data =
          (await fetchCoinService.fetchLatestSpotPairs()).cast<Crypto>();

      if (mounted) {
        setState(() {
          _cryptoList = data;
          _filteredCryptoList = data; // Initialize filtered list with all data
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch data: $e';
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCryptoList = _cryptoList
          .where((crypto) =>
              crypto.name.toLowerCase().contains(query) ||
              crypto.symbol.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Search Cryptocurrency',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or symbol...',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Main Body
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Expanded(
                        child: _filteredCryptoList.isEmpty
                            ? const Center(
                                child: Text(
                                  'No results found',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredCryptoList.length,
                                itemBuilder: (context, index) {
                                  final crypto = _filteredCryptoList[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    color: Colors.grey[850],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(10),
                                      title: Text(
                                        '${crypto.name} (${crypto.symbol})',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Price: \$${crypto.price?.toStringAsFixed(2) ?? 'N/A'}',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                          Text(
                                            'Market Cap: \$${crypto.marketCap?.toStringAsFixed(2) ?? 'N/A'}',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                          Text(
                                            'Change 1h: ${crypto.priceChange24h?.toStringAsFixed(2) ?? 'N/A'}%',
                                            style: TextStyle(
                                              color: crypto.priceChange24h !=
                                                          null &&
                                                      crypto.priceChange24h! >=
                                                          0
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ],
        ),
      ),
    );
  }
}
