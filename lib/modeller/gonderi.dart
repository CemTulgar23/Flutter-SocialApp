import 'package:cloud_firestore/cloud_firestore.dart';

class Gonderi {
  final String id;
  final String gonderiResmiUrl;
  final String aciklama;
  final String yayinlayaId;
  final int begeniSayisi;
  final String konum;

  Gonderi({
    required this.id,
    required this.gonderiResmiUrl,
    required this.aciklama,
    required this.yayinlayaId,
    required this.begeniSayisi,
    required this.konum,
  });

  factory Gonderi.dokumandanUret(DocumentSnapshot doc) {
    //Veritabanından bilgileri çekiyoruz ve bu veriler DocumentSnapshot tipinde oluyor.
    //Bu fonksiyona da DoxumentSnapshot tipindeki o verileri parametre olarak gönderiyoruz
    //ve bir tane 'Gönderi' nesnesi oluşturuyoruz.
    return Gonderi(
      id: doc.documentID,
      gonderiResmiUrl: doc['gonderiResmiUrl'],
      aciklama: doc['aciklama'],
      yayinlayaId: doc['yayinlayanId'],
      begeniSayisi: doc['begeniSayisi'],
      konum: doc['konum'],
      //soldakiler bu sınıfın özellikleri, sağdakiler ise veritabanındaki hücreler
    );
  }
}
