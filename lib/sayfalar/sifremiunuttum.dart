import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class SifremiUnuttum extends StatefulWidget {
  const SifremiUnuttum({Key? key}) : super(key: key);

  @override
  _SifremiUnuttumState createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  bool yukleniyor = false;
  final _formAnahtari = GlobalKey<FormState>(); //Formun statine ulaşmak için
  final _scaffoldAnahtari =
      GlobalKey<ScaffoldState>(); //Scaffoldun statine ulaşmak için
  late String email;
  //Hesap oluştururken girilen bilgileri tutmak için

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Şifremi Sıfırla"),
      ),
      body: ListView(
        children: [
          yukleniyor
              ? LinearProgressIndicator()
              : SizedBox(height: 0.0), //Yükleme animasyonu için (çizgisel)
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
                key: _formAnahtari,
                child: Column(
                  children: [
                    TextFormField(
                      //TextBox
                      decoration: InputDecoration(
                        hintText: "Email adresinizi girin", //ipucu
                        labelText: "Mail:", // Text yazılan kısmın başlığı
                        errorStyle: TextStyle(fontSize: 16),
                        prefixIcon: Icon(Icons.mail),
                      ),
                      validator: (girilenDeger) {
                        if (girilenDeger!.isEmpty) {
                          //Girilen değer boş mu?
                          return "Email alanı boş bırakılamaz";
                        } else if (!girilenDeger.contains("@")) {
                          //Girilen değerde @ sembolü var mı
                          return "Girilen değer mail formatında olmalı";
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) {
                        //String alır ama bir şey döndürmez
                        email = girilenDeger!;
                      },
                    ),
                    SizedBox(height: 50),
                    Container(
                      width: double.infinity,
                      //Yatay ekseni kaplamak için expanded ekleyemezdik
                      //Çünkü expanded colum içine eklenmez. Column'un ana ekseni dikey eksendir çünkü
                      //Expanded ile ana eksen yatay olarak kabul edilip enlemsine bütün alanı dolduruyoruz
                      child: FlatButton(
                        onPressed: _sifreyiSifirla,
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
                  ],
                )),
          )
        ],
      ),
    );
  }

  Future<void> _sifreyiSifirla() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formState = _formAnahtari.currentState;
    if (_formState!.validate()) {
      //Girilen bilgilerde sorun yoksa
      _formState.save();
      //_formAnahtari.currentState: formun statine ulaşmamızı sağlıyor

      setState(() {
        yukleniyor = true;
      });

      ///await _yetkilendirmeServisi.mailIleKayit(email, sifre);
      ///Navigator.pop(context);

      try {
        //Bu kodun hata verme ihtimali var
        await _yetkilendirmeServisi.sifremiSifirla(email);
        Navigator.pop(context);
      } catch (hata) {
        //Programın hata yakalaması durumunda yapması gerekenler
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.toString());
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji = "";

    if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz email geçersiz";
    } else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hataMesaji = "Girdiğiniz mail ile kayıt olunmuş";
    } else if (hataKodu == "ERROR_WEAK_PASSWORD") {
      hataMesaji = "Daha zor bir şifre tercih edin";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState!.showSnackBar(snackBar);
  }
}
