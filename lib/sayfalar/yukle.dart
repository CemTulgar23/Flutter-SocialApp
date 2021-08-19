import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/storageservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Yukle extends StatefulWidget {
  const Yukle({Key? key}) : super(key: key);

  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  late File? dosya; //Resim bilgilerini tutacak
  bool yukleniyor = false;

  TextEditingController aciklamaTextKumandasi = TextEditingController();
  TextEditingController konumTextKumandasi = TextEditingController();

  ///Text alanına girilen bilgileri kolay bir şekilde kullanabilmemizi sağlayan
  ///çeşitli özellikleri olan bir controller

  @override
  Widget build(BuildContext context) {
    return dosya == null ? yukleButonu() : gonderiFormu();
    //fotoğraf boşsa fotoğraf ekleme butonu gözükecek, boş değilse fotoğraf ve açıklamaları gözükecek
  }

  Widget yukleButonu() {
    //Bu sayfa geldiğinde dosya değişkeninin içinde resim bilgileri yoksa resim yükleme butonu ekrana gelecek
    return IconButton(
        onPressed: () {
          fotografSec();
        },
        icon: Icon(
          Icons.file_upload,
          size: 50,
        ));
  }

  Widget gonderiFormu() {
    ///Bu sayfa açıldığında eğer dosya değişkeninin içinde resim bilgileri
    ///varsa ekrana resmin, açıklamanın ve konumun olduğu alan gelecek
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Gönderi Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            //AppBar'da bulunan geri butonu
            onPressed: () {
              //Butona basıldığında dosya değişkeninin içindeki resim bilgilerini siliyoruz !!!!!!!
              setState(() {
                //Build metodu tekrar çalışır ve dosya niteliğinin null olduğunu gördüğünde tekrar çalışır
                dosya = null;
              });
            },
            icon: Icon(
              //Geri butonu
              Icons.arrow_back,
              color: Colors.black,
            )),
        actions: [
          IconButton(
              onPressed: _gonderiOlustur,
              icon: Icon(
                //Gönderme butonu
                Icons.send,
                color: Colors.black,
              ))
        ],
      ),
      body: ListView(
        children: [
          yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0),
          AspectRatio(
              //AspectRatio:En boy oranı
              aspectRatio: 16.0 / 9.0,
              child: Image.file(dosya!, fit: BoxFit.cover)),
          SizedBox(height: 20),
          TextFormField(
            controller:
                aciklamaTextKumandasi, //Text alanındaki bilgiye ulaşabilmek için
            decoration: InputDecoration(
              hintText: "Açıklama Ekle",
              contentPadding: EdgeInsets.only(
                  left: 15, right: 15), //Sağdan ve soldan 15 piksel boşluk
            ),
          ),
          TextFormField(
            controller:
                konumTextKumandasi, //Text alanındaki bilgiye ulaşabilmek için
            decoration: InputDecoration(
              hintText: "Fotoğraf Nerede Çekildi?",
              contentPadding: EdgeInsets.only(
                  left: 15, right: 15), //Sağdan ve soldan 15 piksel boşluk
            ),
          ),
        ],
      ),
    );
  }

  void _gonderiOlustur() async {
    if (!yukleniyor) {
      //yukleniyor değeri false ise, yani devam eden bir yükleme yoksa.
      setState(() {
        yukleniyor = true;
      });
      String resimUrl = await StorageServisi().gonderiResmiYukle(dosya!);

      ///dosya değişkenindeki Resim bilgilerini StorageServis'te tanımladığımız
      ///gondereiResmiYukle metoduna parametre olarak gönderiyoruz.
      ///Bu metot gönderdiğimiz bilgileri veritabanına (StorageServis) kaydediyor.
      String aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;

      await FirestorServisi().gonderiOlustur(
        //Veritabanında (cloud_firestore) verileri kaydetmek için
        gonderiResmiUrl: resimUrl,
        aciklama: aciklamaTextKumandasi.text,
        yayinlayaId: aktifKullaniciId,
        konum: konumTextKumandasi.text,
      );
      //YÜKLEME İŞLEMİ BİTMİŞ OLDU

      setState(() {
        //Yükleme sayfasından çıkmak için
        yukleniyor = false;
        aciklamaTextKumandasi.clear();
        konumTextKumandasi.clear();
        dosya = null;
      });
    }
  }

  fotografSec() {
    return showDialog(
      //Dialog ekranını döndürüyor
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Gönderi Oluştur"),
          children: [
            SimpleDialogOption(
              child: Text("Fotoğraf Çek"),
              onPressed: () {
                fotoCek();
              },
            ),
            SimpleDialogOption(
              child: Text("Galeriden Yükle"),
              onPressed: () {
                galeridenSec();
              },
            ),
            SimpleDialogOption(
              child: Text("İptal"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
        //Dialog ekranını döndürüyor
      },
    );
  }

  fotoCek() async {
    Navigator.pop(context); //Dialog penceresinin kapanması için
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80); //Source: kaynak
    //Kamera kullanarak fotoğraf yüklenmesni sağladık
    setState(() {
      //setState diyerek build metodunu haberdar ediyoruz. Yani build metodunun tekrar çalışmasını sağlıyoruz
      dosya = File(image.path);
      //image.path, string tipinde bir değişken iken onu File tipinde yaptık ve daha önceden oluşturduğumuz dosya değişkenine atadık
    });
  }

  galeridenSec() async {
    Navigator.pop(context); //Dialog penceresinin kapanması için
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80); //Source: kaynak
    //Galeriden fotoğraf yüklenmesni sağladık
    setState(() {
      //setState diyerek build metodunu haberdar ediyoruz. Yani build metodunun tekrar çalışmasını sağlıyoruz
      dosya = File(image.path);
      //image.path, string tipinde bir değişken iken onu File tipinde yaptık ve daha önceden oluşturduğumuz dosya değişkenine atadık
    });
  }
}
