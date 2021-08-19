import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/yorum.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;

  const Yorumlar({Key? key, required this.gonderi}) : super(key: key);

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController _yorumKontrolcusu = TextEditingController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    ///Yorumun ne kadar zaman önce yapıldığını gösteriyor
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text("Yorumlar", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _yorumlariGoster(),
          _yorumEkle(),
        ],
      ),
    );
  }

  _yorumlariGoster() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirestorServisi().yorumlariGeitr(widget.gonderi.id),
            //stream: hangi canlıyayını dinleyeceğimizi söyledik
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                //Eğer data yoksa Yorum gelene kadar yükleniyor işareti döndğr
                return Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                ///Her gönderide farklı sayıda ListView oluşturabilmek için
                ///ListView.builder kullandık
                itemCount: snapshot.data!.documents.length,
                itemBuilder: (context, index) {
                  ///index aldığımız verilerin sırasını tutar.
                  ///Galiba yani bir liste düşünelim. Olistede veritabanından aldığımız
                  ///DocumanSnapshot tipinde yorumnlar var biz de onları index ile liste numaralarına göre
                  ///Yorum sınıfına gönderip yorum nesnesi oluşturuyoruz
                  Yorum yorum =
                      Yorum.dokumandanUret(snapshot.data!.documents[index]);
                  return _yorumSatiri(yorum);
                  //yorumu getiriyoruz
                },
              );
            }));
  }

  _yorumSatiri(Yorum yorum) {
    return FutureBuilder<Kullanici?>(
        future: FirestorServisi().kullaniciGetir(yorum.yayinlayaId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(height: 0);
          }
          Kullanici? yayinlayan = snapshot.data;
          //yorumun sahibi olan kullanıcıyı yayinlayan değişkenine atadık
          return ListTile(
            //Yorumların olduğu bölümü oluşturuyoruz
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(yayinlayan!.fotoUrl),
            ),
            title: RichText(
                //Tek bir textin içinde birden fazla yazı tipi kullanmak için
                text: TextSpan(
                    text: yayinlayan.kullaniciAdi + " ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                  TextSpan(
                      text: yorum.icerik,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14))
                ])),
            subtitle: Text(
                timeago.format(yorum.olusturulmaZamani.toDate(), locale: "tr")),
          );
        });
  }

  _yorumEkle() {
    return ListTile(
      title: TextFormField(
        controller: _yorumKontrolcusu,
        //textin içine yazılanı tutuyor
        decoration: InputDecoration(
          hintText: "Yorumu buraya yazın.",
        ),
      ),
      trailing: IconButton(
        onPressed: _yorumGonder,
        icon: Icon(Icons.send),
      ),
    );
  }

  void _yorumGonder() {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    FirestorServisi().yorumEkle(
        aktifKullaniciId: aktifKullaniciId,
        gonderi: widget.gonderi,
        icerik: _yorumKontrolcusu.text);
    _yorumKontrolcusu.clear();
  }
}
