import 'dart:ffi';

import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/modeller/duyuru.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/duyurular.dart';
import 'package:socialapp/servisler/storageservisi.dart';

class FirestorServisi {
  final Firestore _firestore = Firestore.instance;
  //Firesore'a bağlantı için
  final DateTime zaman = DateTime.now();
  //Çalıştırıldığı andaki tarih ve zaman bilgisi

  Future<void> kullaniciOlustur({id, email, kullaniciAdi, fotoUrl = ""}) async {
    ///Biz kullanıcıyı Authentication servise ekledik ancak veritabanına eklemedik.
    ///Burada authentication'da üretilen kullanıcıyı veritabanındaki koleksiyona ekliyoruz
    await _firestore.collection("kullanicilar").document(id).setData({
      //Döküman ekliyoruz
      "kullaniciAdi": kullaniciAdi,
      "email": email,
      "fotoUrl": fotoUrl,
      "hakkinda": "",
      "olusturulmaZamani": zaman,
    });
  }

  Future<Kullanici?> kullaniciGetir(id) async {
    ///Kullanıcı daha önce kayıt olduysa giriş yaparken sürekli yeni kullanıcı eklemesin diye
    ///o kullanıcıdan başka var mı diye kontrol ediyoruz.
    DocumentSnapshot doc =
        await _firestore.collection("kullanicilar").document(id).get();
    //Gönderilen id'li kullanıcıyı getir
    if (doc.exists) {
      //Eğer böyle bir döküman varsa
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
      //Veritabanından aldığımız bilgilerle uygulamada kullanacağımız kullanıcı nesnesini oluşturuyoruz
      ///Kullanici.firebasedenUretr diyemezdik çünkü Cloud_Firestore'da bulunan kayıtlar DocumantSnapshot tipinde tutulur
    }
    return null;
  }

  void kullaniciGuncelle(
      {required String kullaniciId,
      required String kullaniciAdi,
      String fotoUrl = "",
      required String hakkinda}) {
    _firestore.collection("kullanicilar").document(kullaniciId).updateData({
      "kullaniciAdi": kullaniciAdi,
      "hakkinda": hakkinda,
      "fotoUrl": fotoUrl,
    });
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("kullanicilar")
        .where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .getDocuments();
    //Kullanıcı adı aradığımız kelimeye eşit olan kullanıcıları getir
    List<Kullanici> kullanicilar =
        snapshot.documents.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  void takipEt(
      {required String aktifKullaniciId, required String profilSahibiId}) {
    _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .document(aktifKullaniciId)
        .setData({});
    //profil sahibinin tüm takipçilerini içeren koleksiyonun dökümanına ulaştık
    //ve takip etmek isteyen kullanıcının id'sini aktifKullanıcıId olarak gönderip veritaban ekledik

    _firestore
        .collection("takipedilenler")
        .document(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .document(profilSahibiId)
        .setData({});

    duyuruEkle(
        aktiviteYapanId: aktifKullaniciId,
        profilSahibiId: profilSahibiId,
        aktiviteTipi: "takip");
  }

  void takiptenCik({String? aktifKullaniciId, required String profilSahibiId}) {
    _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .document(aktifKullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      //İçine girilen fonksiyonu future tamamlandıktan hemen sonra çalştırır
      //tamamkanan future'nin döndürdüğü değeri fonksiyona parametre olarak gönderir
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //takipten çıkmak istediğimiz profil sahibinin veritabanındaki takipçiler koleksiyonunda
    //takipren çıkmak isteyen kullanıcının id'sini getiridk

    _firestore
        .collection("takipedilenler")
        .document(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .document(profilSahibiId)
        .get()
        .then((DocumentSnapshot doc) {
      //İçine girilen fonksiyonu future tamamlandıktan hemen sonra çalştırır
      //tamamkanan future'nin döndürdüğü değeri fonksiyona parametre olarak gönderir
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //takipten çıkan kullanıcının takip ettiklerinin arasından sildik
  }

  Future<bool> takipKontrol(
      {String? aktifKullaniciId, required String profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipciler")
        .document(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .document(aktifKullaniciId)
        .get();
    if (doc.exists) {
      return true;
    }
    return false;

    ///profil sahibini, bu metoda parametre olarak gönderdiğimiz kullaniciId'li kullanıcının takip
    ///edip etmediğine baktıkve soc adında değişkene atadık.
    ///Eğer doc'da döküman varsa true döndür yoksa false döndür dedik
  }

  Future<int> takipciSayisi(kullaniciId) async {
    //id'si verilen kullanıcıların takipçilerine ulaşmak istiyoruz
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .document(kullaniciId)
        .collection("kullanicininTakipcileri")
        .getDocuments();
    //Kullanıcı id'si gönderilen kullanıcının takipçileerine ulaştık
    return snapshot.documents.length; //takipçi sayısını döndürüyor
    //snapshot'ta takipçilerin bütün bilgileri var. Biz sadece sayısını istiyoruz
  }

  Future<int> takipEdilenSayisi(kullaniciId) async {
    //id'si verilen kullanıcıların takip ettiği kullanıcılara ulaşmak istiyoruz
    QuerySnapshot snapshot = await _firestore
        .collection("takipedilenler")
        .document(kullaniciId)
        .collection("kullanicininTakipleri")
        .getDocuments();
    //Kullanıcı id'si gönderilen kullanıcının takip ettiği kullanıcılara ulaştık
    return snapshot.documents.length; //takip edilen sayısını döndürüyor
  }

  void duyuruEkle(
      {required String aktiviteYapanId,
      required String profilSahibiId,
      required String aktiviteTipi,
      String? yorum,
      Gonderi? gonderi}) {
    if (aktiviteYapanId == profilSahibiId) {
      return;
      //Kullanıcı kendi kendine duyuru göndermesin diye
    }
    _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kulanicininDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteTipi": aktiviteTipi,
      "gonderiId": gonderi?.id,
      "gonderiFoto": gonderi?.gonderiResmiUrl,
      "yorum": yorum,
      "olusturulmaZamani": zaman,
    });
  }

  Future<List<Duyuru>> duyurulariGetir(String profilSahibiId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("duyurular")
        .document(profilSahibiId)
        .collection("kulanicininDuyurulari")
        .orderBy("olusturulmaZamani", descending: true)
        .limit(20) //son 20 dökümanın getirilmesini sağlıyoruz
        .getDocuments();

    List<Duyuru> duyurular = [];

    snapshot.documents.forEach((DocumentSnapshot doc) {
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });
    return duyurular;
  }

  Future<void> gonderiOlustur(
      {gonderiResmiUrl, aciklama, yayinlayaId, konum}) async {
    ///Storage serviste her oluşturduğumuz gönderi için cloud_firestore'a da kaydediyoruz
    ///Veritabanında oluşturduğumuz koleksiyondaki hücrelere Yukle sayfasından aldığımız
    ///verileri gönderiyoruz
    await Firestore()
        .collection("gonderiler")
        .document(yayinlayaId)
        .collection("kullaniciGonderileri")
        .add({
      "gonderiResimUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayaId,
      "begeniSayisi": 0,
      "konum": konum,
      "olusturulmaZamani": zaman,
    });

    ///yayinlayanId'sini verdiğimiz kullanıcının gönderileri bölümünü
    ///gönderiler koleksiyonunun içinden buluyoru.
    ///Bizim verdiğimiz değerleri ekliyor.
  }

  Future<List<Gonderi>> gonderileriGetir(kullaniciId) async {
    //kullaniciId: kimin gönderisini getireceğimize karar vereceğiz
    QuerySnapshot snapshot = await Firestore()
        .collection("gonderiler")
        .document(kullaniciId)
        .collection("kullaniciGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        //en son gönderilen gönderinin ilk başta sıralanmasını sağladık
        .getDocuments();
    List<Gonderi> gonderiler =
        snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    //toList: Liste döndürmesi için
    //Her bir gönderi dökümanını gönderi nesnesine dönüştürmek için map kullanıyoruz
    ///snapshot içindeki veriler tek tek doc değişkenine atanıyor
    ///oradan da Gonderi.documandanUret fonksiyonuna gidip gönderi nesnei oluşuyor
    ///Takipçi sayısı ve Takip Edilen sayısını gösterirken nesneye dönüştürmemize
    ///gerek yok. Çünkü biz veritabanıdaki takp ile ilgili bilgilerin
    ///sayısını elde etmek istiyorduk .Yani kendileirinin bir önemi yoktu.
    ///Zaten veritabanında da saedce kullanıcıların id2leri tutuluyor takip için.
    ///Ancak gönderilerde biraz farklı. Gönderi oluşturuyoruz ve bunları daha sonra
    ///tamamen uygulamaya çekip nesne oluşturuyoruz ki kullanabilelim.
    return gonderiler;
  }

  Future<List<Gonderi>> akisGonderileriniGetir(kullaniciId) async {
    //kullaniciId: kimin gönderisini getireceğimize karar vereceğiz
    QuerySnapshot snapshot = await Firestore()
        .collection("akislar")
        .document(kullaniciId)
        .collection("kullaniciAkisGonderileri")
        .orderBy("olusturulmaZamani", descending: true)
        //en son gönderilen gönderinin ilk başta sıralanmasını sağladık
        .getDocuments();
    List<Gonderi> gonderiler =
        snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    //toList: Liste döndürmesi için
    //Her bir gönderi dökümanını gönderi nesnesine dönüştürmek için map kullanıyoruz
    ///snapshot içindeki veriler tek tek doc değişkenine atanıyor
    ///oradan da Gonderi.documandanUret fonksiyonuna gidip gönderi nesnei oluşuyor
    ///Takipçi sayısı ve Takip Edilen sayısını gösterirken nesneye dönüştürmemize
    ///gerek yok. Çünkü biz veritabanıdaki takp ile ilgili bilgilerin
    ///sayısını elde etmek istiyorduk .Yani kendileirinin bir önemi yoktu.
    ///Zaten veritabanında da saedce kullanıcıların id2leri tutuluyor takip için.
    ///Ancak gönderilerde biraz farklı. Gönderi oluşturuyoruz ve bunları daha sonra
    ///tamamen uygulamaya çekip nesne oluşturuyoruz ki kullanabilelim.
    return gonderiler;
  }

  gonderiSil(String aktifKullaniciId, Gonderi gonderi) async {
    _firestore
        .collection("gonderiler")
        .document(aktifKullaniciId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
        //Gönderiyi sildik
      }
    });
    //then: veritabanından bilgi çekme işlemi tamamlandığı anda çalışacak komutlar

    //Gönderiye ait yorumları sildik
    QuerySnapshot yorumlarSnapshot = await _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .getDocuments();
    yorumlarSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
        //Gonderiye ait yorumlari veritabanından çektik ve forEach'te tek tek döndük ve sildik
      }
    });

    //Gönderiye ait duyuruları sildik
    QuerySnapshot duyurularSnapshot = await _firestore
        .collection("duyurular")
        .document(gonderi.yayinlayaId)
        .collection("kulanicininDuyurulari")
        .where("gonderiId", isEqualTo: gonderi.id)
        .getDocuments();
    duyurularSnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
        //Gonderiye ait yorumlari veritabanından çektik ve forEach'te tek tek döndük ve sildik
      }
    });

    //Storage servisten gönderinin resmini sildik
    StorageServisi().gonderiResmiSil(gonderi.gonderiResmiUrl);
  }

  Future<Gonderi> tekliGonderiGetir(
      String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection("gonderiler")
        .document(gonderiSahibiId)
        .collection("kullaniciGonderileri")
        .document(gonderiId)
        .get();

    ///Gönderiler koleksiyonuna gidip gönderiyi yayınlayan kullanıcının id'sini verdik
    ///kullanicininGonderileri koleksiyonunda id'si verilen kullanıcının gönderilerine gittik
    ///ve gönderi id'sini vererek hangi gönderiyi almak istiyorsak aldık.
    ///Bu DocumetnSnapshot tipindeki veriyi gönderi nesnesine dönüştürüp uygulamada göstermemiz gerekiyor.
    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  Future<void> gonderiBegen(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayaId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id);
    DocumentSnapshot doc = await docRef.get();

    ///gonderiler koleksiyonundaki yayinlayanId'si verilen kullanıcının
    ///gönderilerinin içinden id'si belirtilen gönderiyi getirdik.

    if (doc.exists) {
      //Eğer data varsa
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi + 1;
      docRef.updateData({"begeniSayisi": yeniBegeniSayisi});

      _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifKullaniciId)
          .setData({});

      duyuruEkle(
          aktiviteYapanId: aktifKullaniciId,
          profilSahibiId: gonderi.yayinlayaId,
          aktiviteTipi: "beğeni",
          gonderi: gonderi);
    }

    ///Gönderiyi veritabanından çektik
    ///Gönderinin beğeni sayısını 1 arttırdık.
    ///Yeni gönderi sayısını güncelledik
  }

  Future<void> gonderiBegeniKaldir(
      Gonderi gonderi, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore
        .collection("gonderiler")
        .document(gonderi.yayinlayaId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id);
    DocumentSnapshot doc = await docRef.get();

    ///gonderiler koleksiyonundaki yayinlayanId'si verilen kullanıcının
    ///gönderilerinin içinden id'si belirtilen gönderiyi getirdik.
    ///Bunu da docRef değişkenine atadık.
    ///docRef içindeki gönderiyi get() metodu ile getirip doc değişkenine atadık

    if (doc.exists) {
      //Eğer data varsa
      Gonderi gonderi = Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi = gonderi.begeniSayisi - 1;
      docRef.updateData({"begeniSayisi": yeniBegeniSayisi});

      ///doc'un içinde data olup olmadığını kontrol ettik.
      ///Eğer data varsa, bu datayı Gonderi sınıfının dokumandanUret metoduna gönderdik
      ///Bir gönderi nesnesi oluşturduk. Çünkü beğeni sayısını değiştirmek için.
      ///Daha sonra yeni beğeni sayısını değişkene atadık ve onu docRef'in içindeki beğeni sayısıyla değiştirdik
      ///Veritabanına kaydettik

      DocumentSnapshot docBegeni = await _firestore
          .collection("begeniler")
          .document(gonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifKullaniciId)
          .get();
      //Kaydettiğimiz beğeniyi getirdik

      if (docBegeni.exists) {
        docBegeni.reference.delete();

        ///Gönderiyi veritabanından çektik
        ///Gönderinin beğeni sayısını 1 azalttık.
        ///Yeni gönderi sayısını güncelledik
        ///Son olarak da beğeniyi veritabanından sildik
      }
    }
  }

  Future<bool> begeniVarMi(Gonderi gonderi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection("begeniler")
        .document(gonderi.id)
        .collection("gonderiBegenileri")
        .document(aktifKullaniciId)
        .get();
    //Beğeni bilgisini kontrol edeceğimiz gönderiyi getirdik

    if (docBegeni.exists) {
      //Akrif kullanıcınıb, bu kayda sahip gönderiyi beğendiğine dair bir bilgi varsa
      return true;
    }
    return false;
  }

  void yorumEkle(
      {required String aktifKullaniciId,
      required Gonderi gonderi,
      required String icerik}) {
    _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .add({
      "iceerik": icerik,
      "yayinlayanId": aktifKullaniciId,
      "olusturulmaZamani": zaman,
    });
    duyuruEkle(
      aktiviteYapanId: aktifKullaniciId,
      profilSahibiId: gonderi.yayinlayaId,
      aktiviteTipi: "yorum",
      gonderi: gonderi,
      yorum: icerik,
    );
  }

  Stream<QuerySnapshot> yorumlariGeitr(String gonderiId) {
    return _firestore
        .collection("yorumlar")
        .document(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturlmaZamani", descending: true)
        .snapshots();
    //snapshots diyerek canlı yayına ulaştık
  }
}
