import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  //Resim, video, ses dosyalarının veritabanında saklandığı yer Storage servisi.
  StorageReference _storage = FirebaseStorage.instance.ref();
  //Depolama alanımıza ulaşan objeyi oluşturduk.
  //StorageReference: Depolama referansı
  //Depolama alanımıza ulaşıp işlemler yapabilmemiz için
  String? resimId;

  ///GÖNDERİ RESMİNİ DEPOLAMA ALANINA KAYDETTİK.
  ///YANİ HER KULLANICIYI AUTHENTİCATİON SERVİSE KAYDETTİĞİMİZ GİBİ
  ///DAHA SONRA BU KAYDETTİKLERİMİZDEN FİRESTORESERVİSİ SINIFINI KULLANARAK NESNE ÜRETECEĞİZ.
  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    //Veritabanına resim eklemek için
    resimId = Uuid().v4(); //Her seferinde farklı id'ler vermesi için
    //Kamera ile çektiğimiz ya da galeriden getirdiğimiz dosyayı resimDosyasi atadık
    StorageUploadTask yuklemeYoneticisi = _storage //Dosyayı ekledik
        .child("resimler/gonderiler/gonderi_$resimId.jpg")
        .putFile(resimDosyasi);
    //Ekleyeceğimiz dosyayı storage içinde hangi dosyaya ekleyeceğimizi söyleyeceğiz
    //Dosyayı anadizine 'gonderi.jpg' olarak kaydettik
    //putFile: Dosyayı depolama alanına koy
    StorageTaskSnapshot snapshot =
        await yuklemeYoneticisi.onComplete; //Yükleme tamamlandığında
    String yuklenenResimUrl =
        await snapshot.ref.getDownloadURL(); //Resmin Url'sini aldık
    //Yüklenen dosyanın linkini istedik
    return yuklenenResimUrl;
  }

  Future<String> profilResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4(); //Her seferinde farklı id'ler vermesi için
    StorageUploadTask yuklemeYoneticisi = _storage //Dosyayı ekledik
        .child("resimler/profil/profil$resimId.jpg")
        .putFile(resimDosyasi);
    StorageTaskSnapshot snapshot =
        await yuklemeYoneticisi.onComplete; //Yükleme tamamlandığında
    String yuklenenResimUrl =
        await snapshot.ref.getDownloadURL(); //Resmin Url'sini aldık
    //Yüklenen dosyanın linkini istedik
    return yuklenenResimUrl;
  }

  gonderiResmiSil(String gonderiResmiUrl) {
    RegExp arama = RegExp(r"gonderi_.+\.jpg");
    var eslesme = arama.firstMatch(gonderiResmiUrl);
    //firstMatch: Tek eşleşmeyi getir.
    String? dosyaAdi = eslesme![0];

    if (dosyaAdi != null) {
      _storage.child("resimler/gonderiler/$dosyaAdi").delete();
    }
  }
}
