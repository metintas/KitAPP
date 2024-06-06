import 'package:flutter/material.dart';
import 'package:kitap/logic/models/mysql.dart';
import 'package:kitap/pages/login.dart';

class CartPage extends StatefulWidget {
  final int musteriId;

  const CartPage({Key? key, required this.musteriId}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> sepetItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    MySql mySql = MySql();
    List<Map<String, dynamic>> fetchedItems =
        await mySql.getCartItems(widget.musteriId);
    for (var item in fetchedItems) {
      if (item['kitap_id'] == null) {
      }
      if (item['adet'] == null) {
        item['adet'] = 1;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        sepetItems =
            fetchedItems;
      });
    }
  }

  void removeItemFromCart(int sepetId) async {
    MySql mySql = MySql();
    await mySql.removeFromCart(sepetId);
    fetchCartItems();
  }

  void completeOrder() async {
  if (Global.loggedInUserId != null) {
    MySql mySql = MySql();
    try {
      for (var item in sepetItems) {
        int kitapId = item['kitap_id'];
        if (kitapId == null || kitapId == 0) {
          print('Geçersiz kitapId: $kitapId');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Geçersiz kitap ID ile sipariş oluşturulamaz.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        print('Sipariş ekleniyor: kitapId = $kitapId');

        int siparisAdedi = item['adet'] ?? 1;

        await mySql.addOrder(
          DateTime.now(),
          item['toplam_fiyat'],
          kitapId,
          Global.loggedInUserId!,
          siparisAdedi,
        );
      }
      await mySql.clearCart(Global.loggedInUserId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sipariş başarıyla tamamlandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sipariş sırasında hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) {
      fetchCartItems();
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Önce giriş yapmalısınız'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    double toplamFiyat =
        sepetItems.fold(0, (sum, item) => sum + (item['toplam_fiyat'] ?? 0.0));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sepet"),
        backgroundColor: Colors.amber,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : sepetItems.isEmpty
              ? const Center(child: Text("Sepetiniz boş"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: sepetItems.length,
                        itemBuilder: (context, index) {
                          var item = sepetItems[index];
                          var kitapResmi = item['kitapResmi'] ?? '';
                          var kitapAdi = item['kitapAdi'] ?? 'Bilinmeyen Kitap';
                          var adet = item['adet'] ?? 0;
                          var toplamFiyat = item['toplam_fiyat'] ?? 0.0;

                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            elevation: 4.0,
                            child: ListTile(
                              leading: kitapResmi.isNotEmpty
                                  ? Image.network(
                                      kitapResmi,
                                      fit: BoxFit.cover,
                                      height: 60,
                                      width: 60,
                                    )
                                  : const Icon(Icons.book, size: 60),
                              title: Text(kitapAdi),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Adet: $adet"),
                                  Text("Fiyat: $toplamFiyat TL"),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  removeItemFromCart(item['sepet_id']);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Toplam Fiyat: $toplamFiyat TL",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: completeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Siparişi Tamamla",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
    );
  }
}
