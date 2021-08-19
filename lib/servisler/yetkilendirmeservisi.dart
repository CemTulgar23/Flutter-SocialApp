import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp/modeller/kullanici.dart';

class YetkilendirmeServisi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //Firebase Authentication servis tipinde bir değişken tanımladık
  late String aktifKullaniciId;
  //YetkilendirmeServisi provider yani her widgette istendiği zaman kullanılabiliyor

  Kullanici _kullaniciOlustur(FirebaseUser kullanici) {
    // ignore: unnecessary_null_comparison
    return Kullanici.firebasedenUret(kullanici);
    //Kullanıcı oluşturmak için Kullanıcı sayfasına yönlendiriliyor
    //Bir tane kullanıcı oluşturuyor ve bunu döndürüyor
    //Veritabanındaki verilerden kullanıcı 'Dökümanı' oluşturuyoruz
  }

  Stream<Kullanici> get durumTakipcisi {
    return _firebaseAuth.onAuthStateChanged.map(_kullaniciOlustur);
    //Yapılan yayınları dinlemek için
    //_kullaniciOlustur'un döndürdüğü kullanıcı değerini onAuthStateChanged.map(_kullaniciOlustur)
    //diyerek dinliyor ve Stream<Kullanici> -yani üretilen kullanıcıyı yayın yamış oluyor- olarak döndürüyor
    //Olan biteni dinliyor ve dinletiyor
  }

  Future<Kullanici> mailIleKayit(String eposta, String sifre) async {
    var girisKarti = await _firebaseAuth.createUserWithEmailAndPassword(
        email: eposta, password: sifre); //email ve şifre ile kullanıcı oluştur
    //Gönderdiğimiz eposta ve sifre ile kullanıcı oluşturuyor
    return _kullaniciOlustur(girisKarti.user);
    //FirebaseUser tipinde olan ürettiğimiz kullanıcıyı kendi programımızdaki kullanıcı tipinde dönüştürmemiz lazım.
  }

  Future<Kullanici> mailIleGiris(String eposta, String sifre) async {
    var girisKarti = await _firebaseAuth.signInWithEmailAndPassword(
        email: eposta, password: sifre);
    //email ve şifre ile kullanıcı oluştur
    //Gönderdiğimiz eposta ve sifre ile kullanıcı oluşturuyor
    return _kullaniciOlustur(girisKarti.user);
    //FirebaseUser tipinde olan ürettiğimiz kullanıcıyı kendi programımızdaki kullanıcı tipinde dönüştürmemiz lazım.
  }

  Future<void> cikisYap() {
    return _firebaseAuth.signOut();
  }

  Future sifremiSifirla(String eposta) async {
    await _firebaseAuth.sendPasswordResetEmail(email: eposta);
  }

  googleIleGiris() async {
    GoogleSignInAccount googleHesabi = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleYetkiKartim =
        await googleHesabi.authentication;
    //Artık kayıtlı google kullanıcısı olduğumu kanıtlayan bir kartım var
    AuthCredential sifresizGirisBelgesi = GoogleAuthProvider.getCredential(
        idToken: googleYetkiKartim.idToken,
        accessToken: googleYetkiKartim.accessToken);
    //Bu kartı güvenlik servisine okutmamız gerekiyor.
    //Böylece şifresiz giriş belgesi alıyoruz
    AuthResult girisKarti =
        await _firebaseAuth.signInWithCredential(sifresizGirisBelgesi);
    print(girisKarti.user.uid);
    print(girisKarti.user.displayName);
    print(girisKarti.user.photoUrl);
    print(girisKarti.user.email);
    return _kullaniciOlustur(girisKarti.user);
  }
}
