import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/anasayfa.dart';
import 'package:socialapp/sayfalar/hesapolustur.dart';
import 'package:socialapp/sayfalar/sifremiunuttum.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  //Formun statşne girebilmek için.
  //Formun statine girip bazı kontroller yapacağız
  bool yukleniyor = false;
  late String email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      body: Stack(
        children: [
          _sayfaElemanlari(),
          _yuklemeAnimasyonu(),
        ],
      ),
    );
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor == true) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center(); //Yükleme olmazsa hiçbir şey göstermesin diye Center ekledik
    }
  }

  Widget _sayfaElemanlari() {
    return Form(
      key: _formAnahtari, //Anahtar ile formun statine giriş yaptık
      child: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 60),
        children: [
          FlutterLogo(size: 90),
          SizedBox(height: 80),
          TextFormField(
            //Emailin girildiği yer
            //TextBox
            decoration: InputDecoration(
              hintText: "Email adresinizi girin", //ipucu
              errorStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.mail),
            ),
            validator: (girilenDeger) {
              //Formun statindeki bir özellik. Kontrol yapıyoruz
              if (girilenDeger!.isEmpty) {
                //Girilen değer boş mu?
                return "Email alanı boş bırakılamaz";
              } else if (!girilenDeger.contains("@")) {
                //Girilen değerde @ sembolü var mı
                return "Girilen değer mail formatında olmalı";
              }
              return null;
            },
            onSaved: (girilenDeger) => girilenDeger = email,
          ),
          SizedBox(height: 40),
          TextFormField(
            //Şifrenin girildiği yer
            //TextBox
            autocorrect: true,
            obscureText: true, //Yazıların görünmemesi için
            decoration: InputDecoration(
              hintText: "Şifrenizi girin", //ipucu
              errorStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (girilenDeger) {
              if (girilenDeger!.isEmpty) {
                //Girilen değer boş mu?
                return "Şifre alanı boş bırakılamaz";
              } else if (girilenDeger.trim().length < 4) {
                //Girilen değerin karakter sayısını getir ama boşluk karakterini sayma
                return "Şifre dört karakterden az olamaz";
              }
              return null;
            },
            onSaved: (girilenDeger) => girilenDeger = sifre,
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                //Butonun genişlik olarak bütün alanı doldurması için
                child: FlatButton(
                  //Hesap Oluştur Butonu
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HesapOlustur()));
                  },
                  child: Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                //Butonun genişlik olarak bütün alanı doldurması için
                child: FlatButton(
                  //Giriş Yap Butonu
                  onPressed: _girisYap,
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  color: Theme.of(context).primaryColorDark,
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Center(child: Text("Veya")),
          SizedBox(height: 20),
          Center(
              child: InkWell(
            onTap: _googleIleGiris,
            //Başka bir fonksiyonun içinde kullandığımız zaman parantez ekliyoruz
            child: Text(
              "Googgle İle Giriş Yap",
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
          )),
          SizedBox(height: 20),
          Center(
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SifremiUnuttum()));
                  },
                  child: Text("Şifremi Unuttum"))),
        ],
      ),
    );
  }

  void _girisYap() async {
    if (_formAnahtari.currentState!.validate()) {
      final _yetkilendirmeServisi =
          Provider.of<YetkilendirmeServisi>(context, listen: false);
      //girilen bilgiler kontrol ediliyor
      _formAnahtari.currentState!.save();
      setState(() {
        //Yapılan değişikliklerden build metodunun haberdar olabilmesi için
        yukleniyor = true;
      });

      try {
        await _yetkilendirmeServisi.mailIleGiris(email, sifre);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata);
      }
    }
    //Validate metodu form alanlarının kurallara uyup uymadığını kontrol ediyor
  }

  void _googleIleGiris() async {
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if (kullanici != null) {
        Kullanici? firestoreKullanici =
            await FirestorServisi().kullaniciGetir(kullanici.id);
        if (firestoreKullanici == null) {
          FirestorServisi().kullaniciOlustur(
            id: kullanici.id,
            kullaniciAdi: kullanici.kullaniciAdi,
            email: kullanici.email,
            fotoUrl: kullanici.fotoUrl,
          );
        }
      }
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata);
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji = "";

    if (hataKodu == "ERROR_USER_NOT_FOUND") {
      hataMesaji = "Böyle bir kullanıcı bulunamıyor";
    } else if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz email geçersiz";
    } else if (hataKodu == "ERROR_USER_DISABLED") {
      hataMesaji = "Kullanıcı engellenmiş";
    } else if (hataKodu == "ERROR_WRONG_PASSWORD") {
      hataMesaji = "Girilen şifre hatalı";
    } else {
      hataMesaji = "Tanımlanamayan bir hata oluştu";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState!.showSnackBar(snackBar);
  }
}
