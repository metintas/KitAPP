import 'package:kitap/pages/login.dart';
import 'package:mysql1/mysql1.dart';

class MySql {
  static String host = '10.57.48.61',
      user = 'root',
      password = '',
      db = 'kitapsatis';
  static int port = 3306;

  MySql();

  Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    );
    return await MySqlConnection.connect(settings);
  }

  Future<List<Map<String, dynamic>>> getKitaplar() async {
    final conn = await getConnection();
    List<Map<String, dynamic>> kitaplar = [];
    Results results = await conn.query('CALL GetKitaplar()');
    for (var row in results) {
      final kitap = Map<String, dynamic>.from(row.fields);
      kitap['kitapFiyat'] = kitap['kitapFiyat']?.toString() ?? '0';
      kitap['kitapYazari'] = kitap['kitapYazari']?.toString() ?? 'Bilinmiyor';
      kitaplar.add(kitap);
    }

    await conn.close();
    return kitaplar;
  }

  Future<List<Map<String, dynamic>>> searchBooks(String searchQuery) async {
    final conn = await getConnection();
    List<Map<String, dynamic>> kitaplar = [];
    Results results = await conn.query('CALL SearchBooks(?)', [searchQuery]);
    for (var row in results) {
      final kitap = Map<String, dynamic>.from(row.fields);
      kitap['kitapFiyat'] = kitap['kitapFiyat']?.toString() ?? '0';
      kitap['kitapYazari'] = kitap['kitapYazari']?.toString() ?? 'Bilinmiyor';
      kitap['kitapYayinevi'] = kitap['yayinevi']?.toString() ?? 'Bilinmiyor';
      kitaplar.add(kitap);
    }

    await conn.close();
    return kitaplar;
  }

  Future<bool> login(String username, String password) async {
  final conn = await getConnection();
  try {
    await conn.query('CALL MusteriGirisi(?, ?, @success_flag, @musteri_id)', [username, password]);
    var results = await conn.query('SELECT @success_flag, @musteri_id');
    var row = results.first;
    int successFlag = row['@success_flag'];
    int musteriId = row['@musteri_id'];

    if (successFlag == 1) {
      Global.loggedInUserId = musteriId; // Başarılı giriş yapıldığında kullanıcı ID'sini kaydet
    }

    return successFlag == 1;
  } finally {
    await conn.close();
  }
}


  Future<void> addOrder(DateTime siparisTarihi, double? toplamFiyat,
      int? kitapId, int musteriId, int siparisAdedi) async {
    final conn = await getConnection();
    try {
      await conn.query('CALL SiparisOnaylama(?, ?, ?, ?, ?)', [
        siparisTarihi.toIso8601String().split('T').first,
        toplamFiyat ?? 0.0, // Eğer toplamFiyat null ise 0.0 olarak kullan
        kitapId ?? 978,
        musteriId,
        siparisAdedi
      ]);
    } finally {
      await conn.close();
    }
  }

  Future<void> addCustomer(String firstName, String lastName, String userName,
      String password, String phone, String address) async {
    final conn = await getConnection();
    try {
      await conn.query('CALL MusteriKaydi(?, ?, ?, ?, ?, ?)', [
        firstName,
        lastName,
        phone,
        address,
        userName,
        password,
      ]);
    } finally {
      await conn.close();
    }
  }

  Future<Map<String, dynamic>> getMusteriById(int musteriId) async {
    final conn = await getConnection();
    var results = await conn.query('CALL GetMusteriById(?)', [musteriId]);
    await conn.close();
    if (results.isNotEmpty) {
      return results.first.fields;
    } else {
      throw Exception("Kullanıcı bulunamadı");
    }
  }

  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final conn = await getConnection();
    var results = await conn.query('CALL GetMusteriByUsername(?)', [username]);
    await conn.close();
    if (results.isNotEmpty) {
      return results.first.fields;
    } else {
      throw Exception("Kullanıcı bulunamadı");
    }
  }

  Future<void> updateMusteri(
      int musteriId,
      String musteriAdi,
      String musteriSoyadi,
      String musteriTel,
      String musteriAdres,
      String kullaniciAdi,
      String sifre) async {
    final conn = await getConnection();
    await conn.query('CALL UpdateMusteri(?, ?, ?, ?, ?, ?, ?)', [
      musteriId,
      musteriAdi,
      musteriSoyadi,
      musteriTel,
      musteriAdres,
      kullaniciAdi,
      sifre,
    ]);
    await conn.close();
  }

  Future<void> addToCart(
      int musteriId, int kitapId, int adet, double toplamFiyat) async {
    final conn = await getConnection();
    try {
      await conn.query('CALL AddToCart(?, ?, ?, ?)',
          [musteriId, kitapId, adet, toplamFiyat]);
    } finally {
      await conn.close();
    }
  }

  Future<void> removeFromCart(int sepetId) async {
    final conn = await getConnection();
    try {
      await conn.query('CALL RemoveFromCart(?)', [sepetId]);
    } finally {
      await conn.close();
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(int musteriId) async {
    final conn = await getConnection();
    List<Map<String, dynamic>> sepetItems = [];
    Results results = await conn.query('CALL GetCartItems(?)', [musteriId]);
    for (var row in results) {
      final item = Map<String, dynamic>.from(row.fields);
      sepetItems.add(item);
    }
    await conn.close();
    return sepetItems;
  }

  Future<void> clearCart(int musteriId) async {
    final conn = await getConnection();
    try {
      await conn.query('CALL ClearCart(?)', [musteriId]);
    } finally {
      await conn.close();
    }
  }
}
