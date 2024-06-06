import 'package:flutter/material.dart';
import 'package:kitap/logic/models/mysql.dart';
import 'package:kitap/pages/homepage.dart';
import 'package:kitap/pages/login.dart';
import 'package:kitap/pages/search.dart';

class Profile extends StatefulWidget {
  const Profile(
      {required this.loggedInUserId, Key? key, required int musteriId})
      : super(key: key);

  final int loggedInUserId;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final MySql db = MySql();

  bool _isObscure = true;

  int _selectedIndex =
      2; // Profil sayfası olduğu için başlangıçta bu indeksi seçili hale getiriyoruz

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Search(),
          ),
        );
        break;
      case 2:
        // Zaten profildeyiz, bu durumu kontrol etmek gerekebilir
        break;
      default:
        // Ekstra durumlar için gerekli işlemleri burada yapabiliriz
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMusteri();
  }

  Future<void> _loadMusteri() async {
    try {
      final musteri = await db.getMusteriById(widget.loggedInUserId);
      setState(() {
        firstNameController.text = musteri['musteriAdi'];
        lastNameController.text = musteri['musteriSoyadi'];
        phoneController.text = musteri['musteriTel'];
        addressController.text = musteri['musteriAdres'];
        userNameController.text = musteri['kullaniciAdi'];
        passwordController.text = musteri['kullaniciSifre'];
      });
    } catch (e) {
      // Error handling
      print("Hata: $e");
    }
  }

  Future<void> _updateMusteri() async {
    try {
      await db.updateMusteri(
        widget.loggedInUserId,
        firstNameController.text,
        lastNameController.text,
        phoneController.text,
        addressController.text,
        userNameController.text,
        passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Güncelleme başarılı'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      // Error handling
      print("Hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Güncelleme başarısız'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(key: ValueKey('login')),
                ),
              );
            },
            icon: Icon(Icons.exit_to_app, size: 35, color: Colors.red),
          )
        ],
      ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                'Adı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  hintText: 'Adınız',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Soyadı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  hintText: 'Soyadınız',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Telefon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: 'Telefon Numaranız',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Adres',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'Adresiniz',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Kullanıcı Adı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: userNameController,
                decoration: InputDecoration(
                  hintText: 'Kullanıcı Adınız',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Şifre',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Şifreniz',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                obscureText: _isObscure,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(350, 50),
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  onPressed: _updateMusteri,
                  child: Text(
                    'Bilgilerimi Güncelle',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
