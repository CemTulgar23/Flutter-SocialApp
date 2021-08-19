//Kullanıcının hangi sayfaya yönlendirileceği bu widget içinde belirlenecek
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/anasayfa.dart';
import 'package:socialapp/sayfalar/girissayfasi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Yonlendirme extends StatelessWidget {
  const Yonlendirme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    return StreamBuilder(

        ///BURASI ÇOK ÖNEMLİ!!!
        ///Kullanıcı kayıt olurken veya giriş yaparken yetkilendirme servisi çalışır.
        ///Mail ile giriş yaparken veya kayıt olurken maililegiris ve maililekayıt metodları çalışır.
        ///Bu metodlar giriş sayfası veya hesap oluştur sayfasından gelen değerleri kontrol eder
        ///ve firebase komutlarıyla veritabanında nesne oluşturur. Oluşturulan bu nesneler Yönlendirme servisinin _kullaniciOlustur
        ///metoduna gönderilir ve Kullanici class'ının özelliklerini taşıyan bir kullanıcı oluşturulur.
        ///_kullaniciOlustur metodu bu kullanıcıyı yansıtır. durumGoster metodu da _kullaniciOlusturun yansıttığı
        ///kullanıcıyı dinler ve programa duyurur. Bu class'ın içinde de biz durumTkipcisinin yaptığı yayını stream diyerek alıyoruz ve kullanıyoruz
        ///Bu elimizdeki kayıt aktif olan kullanıcının kayıdı. Ya az önce giriş yaptı ya da kayıt oldu.
        ///kayıdı aktif kullanıcı değişkenine atayarak data olup olmadığına bakıyoruz. Data varsa anasayfa yoksa girişsayfasını getiriyoruz.
        //İstediğimiz yayını dinleriz ve build işlemi yaparız
        stream: _yetkilendirmeServisi.durumTakipcisi,
        //YetkilendirmeServisi'nin durumTakipcisi metodunun yaptığı yayını dinledik
        //Uygulamayı açan bir kullanıcıyı görüntüledik yani
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Eğer bağlantı bekleme durumundaysa
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            //Eğer data varsa
            Kullanici? aktifKullanici = snapshot.data
                as Kullanici?; //Datayı kullancı sınıfından üretilmiş bir kullanıcıya atıyoruz
            _yetkilendirmeServisi.aktifKullaniciId = aktifKullanici!.id;
            return AnaSayfa(); //Eğer data varsa anasayfayı getir
          } else {
            return GirisSayfasi(); //Eğer kullancı yoksa giriş sayfasını getir
          }
        });
  }
}
