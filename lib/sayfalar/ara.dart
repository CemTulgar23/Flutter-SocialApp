import 'package:flutter/material.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';

class Ara extends StatefulWidget {
  const Ara({Key? key}) : super(key: key);

  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaController = TextEditingController();
  Future<List<Kullanici>>? _aramaSonucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      titleSpacing: 0, //Kenarlarda boşluk bırakmadık
      backgroundColor: Colors.grey,
      title: TextFormField(
          onFieldSubmitted: (girilenDeger) {
            //Text alanına girilen bilgiler gönderildiğinde çalış
            setState(() {
              _aramaSonucu = FirestorServisi().kullaniciAra(girilenDeger);
            });
          },
          controller: _aramaController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              //prefixIcon: textin önüne ikon eklememizi sağlar
              Icons.search,
              size: 30,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _aramaController.clear();
                setState(() {
                  _aramaSonucu = null;
                });
              },
              icon: Icon(Icons.clear),
            ),
            border: InputBorder.none, //Alttaki çizgiyi kaldırmak için
            fillColor: Colors.white, //İçini beyaz yaptık
            filled: true,
            hintText: "Kullanıcı Ara",
            contentPadding: EdgeInsets.only(top: 16),
          )),
    );
  }

  aramaYok() {
    return Center(child: Text("Kullanıcı Ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
        future: _aramaSonucu,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.length == 0) {
            return Center(child: Text("Bu arama için sonuç bulunamadı."));
          }
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Kullanici kullanici = snapshot.data![index];
                //snapshot içindeki farklı kullanıcılara index ile ulaştık
                return kullaniciSatiri(kullanici);
              });
        });
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profil(profilSahibiId: kullanici.id)));
      },
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(kullanici.fotoUrl),
          ),
          title: Text(kullanici.kullaniciAdi,
              style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
