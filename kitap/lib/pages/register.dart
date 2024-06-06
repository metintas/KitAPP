import 'package:flutter/material.dart';
import 'package:kitap/pages/login.dart';
import 'package:kitap/logic/models/mysql.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();

  var db = MySql();

  void _getCustomer() {
    db.addCustomer(
      firstName.text,
      lastName.text,
      userName.text,
      password.text,
      phone.text,
      address.text,
    ).then((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kayıt Başarılı'),
          content: const Text('Kaydınız başarılı bir şekilde oluşturuldu.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
      firstName.clear();
      lastName.clear();
      userName.clear();
      password.clear();
      phone.clear();
      address.clear();
    }).catchError((e) {
      String errorMessage = "Kayıt yapılamadı";
      if (e.toString().contains('1062')) {
        errorMessage = "Bu kullanıcı adı zaten alınmış. Lütfen başka bir kullanıcı adı seçin.";
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hata'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
      print("Kayıt yapılamadı: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text("Kayıt Ol"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/logo.png", width: 150, height: 150,),
                    TextFormField(
                      controller: firstName,
                      decoration: const InputDecoration(
                        labelText: 'Adı',
                        hintText: 'Adı',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: lastName,
                      decoration: const InputDecoration(
                        labelText: 'Soyadı',
                        hintText: 'Soyadı',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      controller: userName,
                      decoration: const InputDecoration(
                        labelText: 'Kullanıcı Adı',
                        hintText: 'Kullanıcı Adı',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Şifre',
                        hintText: 'Yeni Şifre',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefon Numarası',
                        hintText: 'Telefon numarası',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: address,
                      decoration: const InputDecoration(
                        labelText: 'Adres',
                        hintText: 'Adres',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              )
                        ),
                        onPressed: () {
                          if (firstName.text.isEmpty ||
                              lastName.text.isEmpty ||
                              phone.text.isEmpty ||
                              address.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Uyarı'),
                                content:
                                    const Text('Lütfen tüm alanları doldurunuz.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            _getCustomer();
                          }
                        },
                        child: const Text("Kayıt ol"),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              )
                        ),
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (BuildContext context) => Login(key: GlobalKey()),
                            )
                          );
                        },
                        child: const Text("Giriş Yap"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
