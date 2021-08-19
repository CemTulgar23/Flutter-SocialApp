import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/yorumlar.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

///PROFİL SAYFASINDA KULLANICI BİLGİLERİNİN ALTINDA HER KULLANICININ KENDİ GÖNDERİLERİNİ GÖRECEĞİ KART
///ANASAYFADA KULLANICININ TAKİP ETTİKLERİNİN GÖNDERİLERİNİ GÖRECEĞİ KART
class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici? yayinlayan;

  const GonderiKarti(
      {Key? key, required this.gonderi, required this.yayinlayan})
      : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  late String _aktifKullaniciId;

  @override
  void initState() {
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context).aktifKullaniciId;
    //Gönderi lartının hangi kullanıcıya ait olduğunu belirlemek için id kullandık
    _begeniSayisi = widget.gonderi.begeniSayisi as int;
    //Bu kart kullanılırken gönderi ve kullanıcı bilgileri gönderilecek biz de ona göe
    //kartta yazan bilgileri göstereceğiz
    begeniVarMi();
  }

  begeniVarMi() async {
    bool begeniVarMi =
        await FirestorServisi().begeniVarMi(widget.gonderi, _aktifKullaniciId);
    //Veritabanından gönderiyi beğenip beğenmediğimize baktık.
    //FirestoreServisi.begeniVarMi metodu beğeni olup olmamasına bakarak bool döndürdü
    //dönen değeri begeniVarMi değişkenine atadık
    //Bunu da if bloğunda çalıştırarak _begendinn değişkenini true yaptık
    if (begeniVarMi = true) {
      //Kullanıcı gönderiyi beğenmiş demektir
      if (mounted) {
        //mounted yani içinde bulunduğumuz Widget hala widget ağacında
        setState(() {
          _begendin = true;
          //Beğeni ikonunun içi dolu kırmızı kap ikonuna dönüşmesini sağladık
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        //Gönderi kartının bölümlerini ayrı metodlar içinde tanımlayacağız
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            _gonderiBasligi(),
            _gonderiResmi(),
            _gonderiAlt(),
          ],
        ));
  }

  gonderiSecenekleri() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Seçiminiz Nedir ?"),
          children: [
            SimpleDialogOption(
              child: Text("Gönderiyi Sil"),
              onPressed: () {
                FirestorServisi().gonderiSil(_aktifKullaniciId, widget.gonderi);
                Navigator.pop(context);
                //Dialog penceresini kapattık
              },
            ),
            SimpleDialogOption(
              child: Text("Vazgeç", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                //Dialog penceresini kapattık
              },
            )
          ],
        );
      },
    );
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Profil(profilSahibiId: widget.gonderi.yayinlayaId)));
          },
          child: CircleAvatar(
            //Profil resmi
            backgroundColor: Colors.blue,
            backgroundImage: _profilFotografiGetir(),
          ),
        ),
      ),
      //leading: ListTile'nin solu
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Profil(profilSahibiId: widget.gonderi.yayinlayaId)));
        },
        child: Text(widget.yayinlayan!.kullaniciAdi,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      trailing: _aktifKullaniciId == widget.gonderi.yayinlayaId
          ? IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
          : gonderiSecenekleri(),
      //trailing: ListTile'nin sağı
      contentPadding: EdgeInsets.all(0),
      //ListTile'nin kendi paddingini kapattık
    );
  }

  ImageProvider<Object> _profilFotografiGetir() {
    if (widget.yayinlayan!.fotoUrl.isNotEmpty) {
      return NetworkImage(widget.yayinlayan!.fotoUrl);
    } else {
      return AssetImage("assets/images/profil.png");
    }
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      //gönderi resmini tıklanabilir yaptık
      onDoubleTap: _begeniDegistir,

      ///_begeniDegistir ile gönderinin beğeni sayısını değiştirdik
      ///daha önce beğenmemişsek veritabanına beğenimizi kaydettik
      ///beğeni varsa var olan beğeniyi sildik
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width, //Eni = Cihazın eni
        height: MediaQuery.of(context).size.width, //Boy = Cihazın eni
        fit: BoxFit.cover,
      ),
    );
  }

  _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              //Beğeni Butonu
              onPressed: _begeniDegistir,

              ///_begeniDegistir ile gönderinin beğeni sayısını değiştirdik
              ///daha önce beğenmemişsek veritabanına beğenimizi kaydettik
              ///beğeni varsa var olan beğeniyi sildik
              icon: !_begendin
                  ? Icon(Icons.favorite_border, size: 35)
                  : Icon(
                      Icons.favorite,
                      size: 35,
                      color: Colors.red,

                      ///_begendin değişkenine bakarak beğeni durumuna göre
                      ///beğeni butnunun rengini değiştirdik.
                      ///_begendin değişkeninin değeri _begeniVarMi metoduyla değişti
                    ),
            ),
            IconButton(
              //Yorum Butonu
              onPressed: () {
                ///Yorumlar widgetine parametre olarak verdiğimiz
                ///gönderinin yorumlarına ulaşıyoruz
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Yorumlar(gonderi: widget.gonderi)));
              },
              icon: Icon(Icons.comment, size: 35),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text("$_begeniSayisi beğeni",
              //Beğeni sayısını gösteriyor
              ///Biz veritabanından beğeni oluşturup veya beğeni kaldırındca gönderinin de
              ///beğeni sayısı değişkeninin değerini değiştirmiştik
              ///Bu değişiklik otomatik olarak güncelleniyor ve _begeniSayisi değişkenine aktarılıyor
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 2),
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: RichText(
                    //Tek bir textin içinde birden fazla yazı tipi kullanmak için
                    text: TextSpan(
                        text: widget.yayinlayan!.kullaniciAdi + " ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                      TextSpan(
                          text: widget.gonderi.aciklama,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 14))
                    ])),
              )
            : SizedBox(
                height: 0,
              ),
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendin) {
      //_begendin değişkeninin değerini veritabanından çektiğimiz bilgiyle kontrol etmiştik
      //Kullanıcı gönderiyi beğenmiş durumda. Bu nedenle beğeniyi kaldıracak kodları çalıştıracağız.
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      FirestorServisi().gonderiBegeniKaldir(widget.gonderi, _aktifKullaniciId);

      ///FirestoreServisi'ne gittik gonderiBegeniKaldir metodu ile gönderinin
      ///beğeni sayısını güncelledik ve veritabanından gönderiyi sildik
    } else {
      //Kullanıcı gönderiyi beğenmemiş durumda. Bu nedenle beğeni ekleyecek kodları çalıştıracağız.
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FirestorServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);

      ///FirestoreServisi'ne gittik gonderiBegen metodu ile gönderinin
      ///beğeni sayısını güncelledik ve veritabanına gönderi ekledik

      ///Biz uygulamada görünecek olan beğeni sayısının değereini belirlemiştik
      ///ama bu beğeni sayısı değiştiğinde değişiklikler veritabanına da kaydedilecek
    }
  }
}
