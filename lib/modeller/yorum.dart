import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  final String id;
  final String icerik;
  final String yayinlayaId;
  final Timestamp olusturulmaZamani;

  Yorum(
      {required this.id,
      required this.icerik,
      required this.yayinlayaId,
      required this.olusturulmaZamani});

  factory Yorum.dokumandanUret(DocumentSnapshot doc) {
    //Veritabanından bilgileri çekiyoruz ve bu veriler DocumentSnapshot tipinde oluyor.
    //Bu fonksiyona da DocumentSnapshot tipindeki o verileri parametre olarak gönderiyoruz
    //ve bir tane 'Yorum' nesnesi oluşturuyoruz.
    return Yorum(
      id: doc.documentID,
      icerik: doc["icerik"],
      yayinlayaId: doc['yayinlayanId'],
      olusturulmaZamani: doc["olusturulmaZamani"],
      //soldakiler bu sınıfın özellikleri, sağdaki ise veritabanındaki hücreler
    );
  }
}
