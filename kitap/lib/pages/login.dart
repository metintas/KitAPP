import 'package:flutter/material.dart';
import 'package:kitap/logic/models/mysql.dart';
import 'package:kitap/pages/homepage.dart';
import 'package:kitap/pages/register.dart';

class Global {
  static String? savedUsername;
  static String? savedPassword;
  static int? loggedInUserId;
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();

  var db = MySql();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Yap"),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.png"),
                  TextFormField(
                    controller: userName,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      hintText: 'Kullanıcı Adı',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      hintText: 'Şifre',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        shape:const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                        )
                      ),
                      onPressed: () async {
                        bool isLoggedIn = await db.login(userName.text, password.text);
                        if (isLoggedIn) {
                          Global.savedUsername = userName.text;
                          Global.savedPassword = password.text;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => const HomePage(),
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Giriş Başarısız."),
                              content: const Text(
                                  "Kullanıcı adı veya şifre hatalı. Lütfen Tekrar deneyin"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Tamam'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text("Giriş Yap"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        shape:const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                        )
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const Register(),
                          )
                        );
                      },
                      child: const Text("Kayıt Ol"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
