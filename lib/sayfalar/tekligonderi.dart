import 'package:flutter/material.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/widgetler/gonderikarti.dart';

class TekliGonderi extends StatefulWidget {
  final String gonderiId;
  final String gonderiSahibiId;

  const TekliGonderi(
      {Key? key, required this.gonderiId, required this.gonderiSahibiId})
      : super(key: key);

  @override
  _TekliGonderiState createState() => _TekliGonderiState();
}

class _TekliGonderiState extends State<TekliGonderi> {
  late Gonderi _gonderi;
  late Kullanici _gonderiSahibi;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    gonderiGetir();
  }

  gonderiGetir() async {
    Gonderi gonderi = await FirestorServisi()
        .tekliGonderiGetir(widget.gonderiId, widget.gonderiSahibiId);
    if (gonderi != null) {
      Kullanici? gonderiSahibi =
          await FirestorServisi().kullaniciGetir(gonderi.yayinlayaId);
      setState(() {
        _gonderi = gonderi;
        _gonderiSahibi = gonderiSahibi!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text("Gönderi", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: !_yukleniyor
          ? GonderiKarti(gonderi: _gonderi, yayinlayan: _gonderiSahibi)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
