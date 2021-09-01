import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profiliduzenle.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/widgetler/gonderikarti.dart';

class Profil extends StatefulWidget {
  final String profilSahibiId;

  ///Bu değişken yet.serviste oluşturulan aktifKullaniciId'ye eşitlenecek
  ///Ve Profil sayfasına her kullanıcının kendi id'sine göre bilgileri gösterilecek

  const Profil({Key? key, required this.profilSahibiId}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";
  late String _aktifKullaniciId;
  late Kullanici _profilSahibi;
  bool _takipEdildi = false;

  _takipciSayisiGetir() async {
    int takipciSayisi =
        await FirestorServisi().takipciSayisi(widget.profilSahibiId);

    ///FirestoreServisi'ne giderek kullanıcı id'sini
    ///parameter olarak atadığımız kullanıcının takipçiler
    ///koleksiyonundan takipçilerini geitrdik
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;

        ///Eğer bu widget hala varssa
        ///takipçi sayısını _takipci değişkenine eşitledik
      });
    }
  }

  _takipEdilenSayisiGetir() async {
    int takipEdilenSayisi =
        await FirestorServisi().takipEdilenSayisi(widget.profilSahibiId);

    ///Buradaki de yine _takipciSayisiGeitr metoduyla aynı.
    ///FirestoreServise gidip oradan veritabanına ulaşıp
    ///kullanıcı id'si verilen kullanıcının takip ettiği kişilerin sayısına
    ///ulaştık ve onu burada bir değişkene aktardık
    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilenSayisi;

        ///Eğer bu widget hala varssa
        ///takip edilen sayısını _takipEdilen değişkenine eşitledik
      });
    }
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler =
        await FirestorServisi().gonderileriGetir(widget.profilSahibiId);

    ///Takiplere çok benzeye bir mantık var burada da.
    ///kullaniciId'sini verdiğimiz kullanıcının fotoğraflarına ulaşıyor
    ///ve döküman halindeki o verileri nesneye dönüştürüp gönderiyor.
    ///Biz de o nesneleri gonderiler Listesine atadık.
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayisi = _gonderiler.length;
        //Eğer bu widget hala varsa gönderileri ve sayısını değişkenlere ata
      });
    }
  }

  _takipKontrol() async {
    bool takipVarMi = await FirestorServisi().takipKontrol(
        profilSahibiId: widget.profilSahibiId,
        aktifKullaniciId: _aktifKullaniciId);
    setState(() {
      _takipEdildi = takipVarMi;
    });

    ///Program açılıdğında takip durumuna göre butonun otomaik görünmesi için
    ///takip olup olmadığını sorguladık.
    ///_takipEdildi değişkenini if içerisinde konrol ettirdik ve duruma göre buton gösterdik
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _takipKontrol();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[100],
        actions: [
          widget.profilSahibiId == _aktifKullaniciId
              //Kullanıcı sadece kendi profil sayfasına girdiğinde çkış yap butonu çalışacak
              ? IconButton(
                  onPressed: _cikisYap,
                  icon: Icon(Icons.exit_to_app),
                  color: Colors.black)
              : SizedBox(height: 0)
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<Kullanici?>(
          future: FirestorServisi().kullaniciGetir(widget.profilSahibiId),

          ///FirestoreServisi'nden kullanıcıid'si ile getirdiğimiz kullanıcı bilgisi snapshot değişkenine atanır
          ///profilSahibiId kullaniciGetir metodunun id parametresine gönderiliyor.
          ///Bu id'li bir kullanıcı var mı diye bakılıyor ve DocumentSnapshot tipinde
          ///doc adında bir değişkene atanıyor.
          ///Eğer bu id'li bir kullanıcı varsa bunu Kullanici.dokumandanUret metodu ile kullanici nesnesine dönüştürüyor
          ///Ve son olarak döndürüyor. Kullanıcı yoksa null döndürüyor.
          builder: (context, snapshot) {
            print("Builder'e girildi");
            //SNAPSHOT DATA PRODİL SAHİBİNİN BİLGİLERİNİ TUTUYOR
            if (!snapshot.hasData) {
              //Eğer kullanıcı yoksa yani veritabanından henüz kullanıcı nesnesi oluşturulup gönderilmediyse
              return Center(child: CircularProgressIndicator.adaptive());
            }
            _profilSahibi = snapshot.data!;

            return ListView(
              children: [
                _profilDetaylari(snapshot.data),
                _gonderileriGoster(snapshot.data),
              ],
            );
          }),
    );
  }

  Widget _gonderileriGoster(Kullanici? profilData) {
    if (gonderiStili == "liste") {
      return ListView.builder(
          //İstediğimiz sayıda ve istediğimiz içerikte elemanları alt alta ekliyoruz
          //Yani widget listesi gibi düşünebiliriz galiba.
          shrinkWrap: true, //Sadece ihtiyacın kadar alan kapla
          itemCount: _gonderiler.length,
          itemBuilder: (context, index) {
            return GonderiKarti(
              gonderi: _gonderiler[index],
              yayinlayan: profilData,
            );
          });
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        fayanslar.add(_fayansOlustur(gonderi));
      });
      return GridView.count(
        //Gönderileri ızgara görünümünde göstermek için
        crossAxisCount: 3, //yatay eksende üç eleman
        shrinkWrap: true, //Sadece ihtiyacın kadar alanı kapla
        primary: false,
        //Kaydırılmaya gerek yoksa kaydırma (zaten en baştaki ListView kaydırılıyor)
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1, //Eni boyuna eşit
        physics: NeverScrollableScrollPhysics(),

        ///GridView, ListView içinde tanımlandı. İkisinin de kaydırma özelliği var
        ///ve bu nedenle kaydırmada bir sorun oluyor.
        children: fayanslar,
      );
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    return GridTile(
        child: Image.network(
      gonderi.gonderiResmiUrl,
      fit: BoxFit.cover,
    ));
  }

  _profilDetaylari(Kullanici? profilData) {
    //Fotoğraf, takipçi, gönderi vb.
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //içindeki elemanları sola hizalamasını sağladık
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(

                  //Profil fotoğrafı
                  backgroundColor: Colors.grey[300],
                  radius: 50,
                  backgroundImage: _profilResmiGoster(profilData!)

                  ///Eğer profilData'nın fotoğrafı boş değilse internetten profilData'nın
                  ///fotoğraf url'sini kopyala getir. Eğer boşsa programdaki standart profil resmini getir
                  ),
              Expanded(
                child: Row(
                  //Sayaçların eşit boşluklar bırakarak fotoğraftan farklı olarak
                  //yayılmasını istediğimiz için bir tane daha row ekledik
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //Sayaçların eşit aralıklarla tamamen yayılması için
                  children: [
                    _sosyalSayac(baslik: "Gönderi", sayi: _gonderiSayisi),
                    _sosyalSayac(baslik: "Takipçi", sayi: _takipci),
                    _sosyalSayac(baslik: "Takip", sayi: _takipEdilen),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Text(
            //Kullanını adı
            profilData.kullaniciAdi,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(profilData.hakkinda), //Hakkında bölümü
          SizedBox(height: 25),
          widget.profilSahibiId == _aktifKullaniciId
              ? _profiliDuzenleButonu()
              : _takipButonu(),
        ],
      ),
    );
  }

  Widget _takipButonu() {
    return _takipEdildi ? _takiptenCikButonu() : _takipEtButonu();
  }

  _takipEtButonu() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        //OutLine butonun içi boş olduğu için renk eklenmiyor. Biz de faltbutton yaptık
        color: Theme.of(context).primaryColor,
        onPressed: () {
          FirestorServisi().takipEt(
            profilSahibiId: widget.profilSahibiId,
            aktifKullaniciId: _aktifKullaniciId,
          );
          setState(() {
            _takipEdildi = true;
            _takipci = _takipci + 1;
          });
        },
        child: Text("Takip Et",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  _takiptenCikButonu() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          FirestorServisi().takiptenCik(
            profilSahibiId: widget.profilSahibiId,
            aktifKullaniciId: _aktifKullaniciId,
          );
          setState(() {
            _takipEdildi = false;
            _takipci = _takipci - 1;
          });
        },
        child: Text("Takibi Bırak",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  _profiliDuzenleButonu() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfiliDuzenle(
                        profil: _profilSahibi,
                      )));
        },
        child: Text("Profili Düzenle"),
      ),
    );
  }

  _sosyalSayac({required String baslik, required int sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      //kolon içindeki elemanları dikey olarak ortaladık
      crossAxisAlignment: CrossAxisAlignment.center,
      //kolon içindeli elemanları yatay olarak ortaladık
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          baslik,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  _profilResmiGoster(Kullanici _profilData) {
    if (_profilData.fotoUrl.isNotEmpty) {
      return NetworkImage(_profilData.fotoUrl);
    } else {
      return AssetImage("assets/images/profil.png");
    }
  }

  void _cikisYap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
