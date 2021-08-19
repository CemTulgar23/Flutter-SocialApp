import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/duyuru.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/tekligonderi.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:timeago/timeago.dart' as timeago;

class Duyurular extends StatefulWidget {
  const Duyurular({Key? key}) : super(key: key);

  @override
  _DuyurularState createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  late List<Duyuru> _duyurular;
  late String _aktifKullaniciId;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context).aktifKullaniciId;
    duyurulariGeitr();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> duyurulariGeitr() async {
    List<Duyuru> duyurular =
        await FirestorServisi().duyurulariGetir(_aktifKullaniciId);
    if (mounted) {
      setState(() {
        _duyurular = duyurular;
        _yukleniyor = false;
      });
    }
  }

  duyurulariGoster() {
    if (_yukleniyor == true) {
      return Center(child: CircularProgressIndicator());
    }
    if (_duyurular.isEmpty) {
      return Center(child: Text("Hiç duyurunuz yok."));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: RefreshIndicator(
        onRefresh: duyurulariGeitr,
        //Yenilemek için kaydırdığımızda çalışacak metodlar
        child: ListView.builder(
          itemCount: _duyurular.length,
          itemBuilder: (context, index) {
            Duyuru duyuru =
                _duyurular[index]; //listenin her bir elemanına tek tek ulaştık
            return duyuruSatiri(duyuru);
          },
        ),
      ),
    );
  }

  duyuruSatiri(Duyuru duyuru) {
    String mesaj = mesajOlustur(duyuru.aktiviteTipi);
    return FutureBuilder(
      //Kullanıcı bilgilerini çekmek için
      future: FirestorServisi().kullaniciGetir(duyuru.aktiviteYapanId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: 0);
        }

        Kullanici aktiviteYapan = snapshot.data as Kullanici;

        return ListTile(
          leading: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Profil(profilSahibiId: duyuru.aktiviteYapanId)));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(aktiviteYapan.fotoUrl),
            ),
          ),
          title: RichText(
              text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profil(
                                  profilSahibiId: duyuru.aktiviteYapanId)));
                    },
                  //yazının üstüne tıklandığını recognizer ile algılarız.
                  text: "${aktiviteYapan.kullaniciAdi}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                TextSpan(
                    text: duyuru.yorum == null
                        ? " $mesaj"
                        : " $mesaj ${duyuru.yorum}",
                    style: TextStyle(fontWeight: FontWeight.normal))
              ])),
          subtitle: Text(
              timeago.format(duyuru.olusturulmaZamani.toDate(), locale: "tr")),
          trailing: gonderiGorsel(
              duyuru.aktiviteTipi, duyuru.gonderiFoto, duyuru.gonderiId),
        );
      },
    );
  }

  gonderiGorsel(String aktiviteTipi, String gonderiFoto, String gonderiId) {
    if (aktiviteTipi == "takip") {
      return null;
    } else if (aktiviteTipi == "begeni" || aktiviteTipi == "yorum") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TekliGonderi(
                      gonderiId: gonderiId,
                      gonderiSahibiId: _aktifKullaniciId)));

          ///Aktif kullanıcı id yazdık çünkü bu sayfada (duyurular sayfası) olan kullanıcı
          ///bir gönderiye tıkladığında kendi gönderisine gidecek ve bu sayfadaysa aktiftir.
        },
        child: Image.network(
          gonderiFoto,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  mesajOlustur(String aktiviteTipi) {
    if (aktiviteTipi == "begeni") {
      return "gönderini beğendi.";
    } else if (aktiviteTipi == "takip") {
      return "seni takip etti.";
    } else if (aktiviteTipi == "yorum") {
      return "gönderine yorum yaptı.";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Duyurular",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: duyurulariGoster(),
    );
  }
}
