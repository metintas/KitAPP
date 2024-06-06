import 'package:flutter/material.dart';
import 'package:kitap/logic/models/mysql.dart';
import 'package:kitap/pages/homepage.dart';
import 'package:kitap/pages/login.dart';
import 'package:kitap/pages/orderpage.dart';
import 'package:kitap/pages/profile.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final MySql _mySql = MySql(); 

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(loggedInUserId: Global.loggedInUserId!, musteriId: 1),
          ),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Search(),
          ),
        );
    }
  }

  void _searchBooks(String query) async {
    try {
      List<Map<String, dynamic>> kitaplar = await _mySql.searchBooks(query);
      setState(() {
        _searchResults = kitaplar;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber,
        title: const Text('Kitap Arama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Kitap Adı veya Yazar Adı',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final String query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      _searchBooks(query);
                    }
                  },
                ),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  _searchBooks(query);
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> book = _searchResults[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(kitap: book),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              width: 70,
                              child: Image.network(
                                book['kitapResmi'] ?? 'https://via.placeholder.com/70x100',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book['kitapAdi'] ?? 'Bilinmiyor',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fiyat: ${book['kitapFiyat'] ?? '0'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Yayınevi: ${book['yayinevi'] ?? 'Bilinmiyor'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
