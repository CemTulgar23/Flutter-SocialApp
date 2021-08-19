import 'dart:io' as i;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/storageservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class ProfiliDuzenle extends StatefulWidget {
  final Kullanici profil;

  const ProfiliDuzenle({Key? key, required this.profil}) : super(key: key);
  @override
  _ProfiliDuzenleState createState() => _ProfiliDuzenleState();
}

class _ProfiliDuzenleState extends State<ProfiliDuzenle> {
  var _formKey = GlobalKey<FormState>();
  late String _kullaniciAdi;
  late String _hakkinda;
  late i.File _secilmisFoto;
  bool _yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.black)),
        actions: [
          IconButton(
              onPressed: _kaydet, icon: Icon(Icons.check, color: Colors.black)),
        ],
      ),
      body: ListView(
        children: [
          _yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0),
          _ProfilFoto(),
          _kullaniciBilgileri(),
        ],
      ),
    );
  }

  _kaydet() async {
    if (_formKey.currentState!.validate()) {
      //Eğer girilen bilgilerde sorun yoksa
      setState(() {
        _yukleniyor = true;
      });
      _formKey.currentState!.save();

      String profilFotoUrl;
      if (_secilmisFoto == Null) {
        profilFotoUrl = widget.profil.fotoUrl;
      } else {
        profilFotoUrl = await StorageServisi().profilResmiYukle(_secilmisFoto);
      }

      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      FirestorServisi().kullaniciGuncelle(
        kullaniciId: aktifKullaniciId,
        kullaniciAdi: _kullaniciAdi,
        hakkinda: _hakkinda,
        fotoUrl: "Butaya fotoğraf url'si gelecek",
      );

      setState(() {
        _yukleniyor = false;
      });
      Navigator.pop(context);
    }
  }

  _ProfilFoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      child: Center(
        child: InkWell(
          onTap: _galeridenSec,
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: _fotoDegistir(),
            radius: 55,
          ),
        ),
      ),
    );
  }

  _fotoDegistir() {
    if (_secilmisFoto == null) {
      return NetworkImage(widget.profil.fotoUrl);
    } else {
      return FileImage(_secilmisFoto);
    }
  }

  _galeridenSec() async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80); //Source: kaynak
    //Galeriden fotoğraf yüklenmesni sağladık
    setState(() {
      //setState diyerek build metodunu haberdar ediyoruz. Yani build metodunun tekrar çalışmasını sağlıyoruz

      String b = "";
      _secilmisFoto = i.File(image.path);
      //image.path, string tipinde bir değişken iken onu File tipinde yaptık ve daha önceden oluşturduğumuz dosya değişkenine atadık
    });
  }

  _kullaniciBilgileri() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      //sağdan ve soldan veya yukarıdan ve aşağıdan eşit
      //boşluklar bırakacaksak symetric kullanıyoruz
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              initialValue:
                  widget.profil.kullaniciAdi, //Otomatik gösterilecek veri
              decoration: InputDecoration(labelText: "Kullanıcı Adı"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length <= 3
                    ? "Kullanıcı adı en az 4 karakter olmalıdır."
                    : null;
              },
              onSaved: (girilenDeger) {
                girilenDeger = _kullaniciAdi;
              },
            ),
            TextFormField(
              initialValue: widget.profil.hakkinda, //Otomatik gösterilecek veri
              decoration: InputDecoration(labelText: "Hakkında"),
              validator: (girilenDeger) {
                return girilenDeger!.trim().length > 100
                    ? "Hakkında bölümü 100 karakterden fazla olmamalıdır."
                    : null;
              },
              onSaved: (girilenDeger) {
                girilenDeger = _hakkinda;
              },
            )
          ],
        ),
      ),
    );
  }
}
