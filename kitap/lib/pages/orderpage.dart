import 'package:flutter/material.dart';
import 'package:kitap/logic/models/mysql.dart';

class OrderPage extends StatefulWidget {
  final Map<String, dynamic> kitap;

  const OrderPage({Key? key, required this.kitap}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  double fiyat = 0.0;
  int siparisAdedi = 1;

  @override
  void initState() {
    super.initState();
    fiyat = double.parse(widget.kitap['kitapFiyat']);
  }

  void sepeteEkle() async {
    MySql mySql = MySql();
    try {
      await mySql.addToCart(1, widget.kitap['kitapId'], siparisAdedi, fiyat * siparisAdedi);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kitap sepete eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sepete ekleme sırasında bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double toplamFiyat = fiyat * siparisAdedi; // Toplam fiyatı hesaplayalım
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(widget.kitap['kitapAdi']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.kitap['kitapResmi'],
                  fit: BoxFit.cover,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kitap Adı: ${widget.kitap['kitapAdi']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Yayınevi: ${widget.kitap['yayinevi']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Fiyat: ${widget.kitap['kitapFiyat']} TL',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Toplam Fiyat: $toplamFiyat TL',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    color: Colors.red,
                    iconSize: 32,
                    onPressed: () {
                      if (siparisAdedi > 1) {
                        setState(() {
                          siparisAdedi--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$siparisAdedi',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    color: Colors.green,
                    iconSize: 32,
                    onPressed: () {
                      setState(() {
                        siparisAdedi++;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: sepeteEkle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    "Sepete Ekle",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
