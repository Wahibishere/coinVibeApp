import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/coinListService.dart';
import '../modules/coinListModel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Crypto> _favoriteCryptos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _listenToFavorites();
  }

  /// Real-time listener for user's favorite coins
  void _listenToFavorites() {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).snapshots().listen(
        (snapshot) async {
          if (snapshot.exists) {
            List<dynamic> favorites = snapshot['favorites'] ?? [];
            await _loadCryptoData(favorites);
          }
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to fetch favorites: $error';
          });
        },
      );
    }
  }

  /// Load crypto data based on favorite IDs
  Future<void> _loadCryptoData(List<dynamic> favoriteIds) async {
    try {
      List<Crypto> favoriteCryptos = [];
      for (var id in favoriteIds) {
        final crypto = await FetchCoinService().fetchCryptoById(id.toString());
        if (crypto != null) {
          favoriteCryptos.add(crypto);
        }
      }

      setState(() {
        _favoriteCryptos = favoriteCryptos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load crypto data: $e';
      });
    }
  }

  /// Add a coin to the user's favorites
  Future<void> _addToFavorites(Crypto crypto) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'favorites': FieldValue.arrayUnion([crypto.id]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${crypto.name} added to favorites')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to favorites: ${e.toString()}')),
      );
    }
  }

  /// Remove a coin from the user's favorites
  Future<void> _removeFromFavorites(Crypto crypto) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'favorites': FieldValue.arrayRemove([crypto.id]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${crypto.name} removed from favorites')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to remove from favorites: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                )
              : ListView.builder(
                  itemCount: _favoriteCryptos.length,
                  itemBuilder: (context, index) {
                    final crypto = _favoriteCryptos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: crypto.iconUrl != null
                            ? Image.network(
                                crypto.iconUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : null,
                        title: Text(
                          '${crypto.name} (${crypto.symbol})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: \$${crypto.price?.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Market Cap: \$${crypto.marketCap?.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFromFavorites(crypto),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
