import 'package:cloud_firestore/cloud_firestore.dart';

class Duyuru {
  final String id;
  final String aktiviteYapanId;
  final String aktiviteTipi;
  final String gonderiId;
  final String gonderiFoto;
  final String yorum;
  final Timestamp olusturulmaZamani;

  Duyuru({
    required this.id,
    required this.aktiviteYapanId,
    required this.aktiviteTipi,
    required this.gonderiId,
    required this.gonderiFoto,
    required this.yorum,
    required this.olusturulmaZamani,
  });

  factory Duyuru.dokumandanUret(DocumentSnapshot doc) {
    //Veritabanından bilgileri çekiyoruz ve bu veriler DocumentSnapshot tipinde oluyor.
    //Bu fonksiyona da DoxumentSnapshot tipindeki o verileri parametre olarak gönderiyoruz
    //ve bir tane 'Duyuru' nesnesi oluşturuyoruz.
    return Duyuru(
      id: doc.documentID,
      aktiviteYapanId: doc['aktiviteYapanId'],
      aktiviteTipi: doc['aktiviteTipi'],
      gonderiId: doc['gonderiId'],
      gonderiFoto: doc['gonderiFoto'],
      yorum: doc['yorum'],
      olusturulmaZamani: doc['olusturulmaZamani'],
    );
  }
}
