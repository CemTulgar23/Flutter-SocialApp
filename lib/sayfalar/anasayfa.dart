import 'package:flutter/src/rendering/sliver_multi_box_adaptor.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/sayfalar/akis.dart';
import 'package:socialapp/sayfalar/ara.dart';
import 'package:socialapp/sayfalar/duyurular.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/yukle.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

///BURADA PAGEVIEW OLUŞTURDUK. YANİ ANASAYFADA BİRDEN FAZLA SAYFA GÖSTERİLEBİLMESİNİ SAĞLADIK.
///PAGEVIEW'İN ELEMANLARINA SAYFALAR BÖLÜMÜNDE OLUŞTURDUĞUMUZ İLGİLİ WIDGETLERİ EKLEDİK
class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _aktifSayfaNo = 0;
  late PageController sayfaKumandasi;

  @override
  void initState() {
    super.initState();
    sayfaKumandasi = PageController();
  }

  @override
  void dispose() {
    //Program performans kaybetmesin diye anasayfadan çıkarken kapatıyoruz
    sayfaKumandasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context).aktifKullaniciId;
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(), //Ekran sağa/sola kaydırılmasın
        onPageChanged: (acilanSayfaNo) {
          setState(() {
            _aktifSayfaNo = acilanSayfaNo;
          });
        },
        controller: sayfaKumandasi,
        children: <Widget>[
          Ara(),
          Yukle(),
          Duyurular(),
          Profil(
            profilSahibiId: aktifKullaniciId,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        //En altta duran araç çubuğu
        currentIndex: _aktifSayfaNo, //Otomatik seçili olacak kısım
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Akış")),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), title: Text("Keşfet")),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), title: Text("Yükle")),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), title: Text("Duyurular")),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text("Profil")),
        ],
        onTap: (secilenSayfaNo) {
          setState(() {
            ///secilenSayfaNo değişkenine hangi sayfadaysak otomatik olarak o sayfanın numarası atanıyor.
            ///sayfaKumandasi nesnesi de sayfalar arası geçiş yapmamızı sağlıyor.
            ///jumpToPage metoduna secilenSayfaNo parametre olarak geliyor ve sayfa değişiyor
            sayfaKumandasi.jumpToPage(secilenSayfaNo);
          });
        },
      ),
    );
  }
}
