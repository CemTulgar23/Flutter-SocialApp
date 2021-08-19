import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Kullanici {
  final String id;
  final String kullaniciAdi;
  final String fotoUrl;
  final String email;
  final String hakkinda;

  Kullanici({
    required this.id,
    required this.kullaniciAdi,
    required this.fotoUrl,
    required this.email,
    required this.hakkinda,
  });

  factory Kullanici.firebasedenUret(FirebaseUser kullanici) {
    ///Firebase Authentication serivste veriler FirebaseUser olarak tutulur.
    ///Biz bu metodun içinde FirebaseUser tiipindeki değerleri Kullanici tipinde çeviriyoruz.
    return Kullanici(
      id: kullanici.uid,
      kullaniciAdi: kullanici.displayName,
      fotoUrl: kullanici.photoUrl,
      email: kullanici.email,
      hakkinda: "",
    );
  }

  factory Kullanici.dokumandanUret(DocumentSnapshot doc) {
    ///Cloud_Firestore (Yani verilerin koleksiyonlar halinde kaydedildiği yerde) veriler DocumantSnapshot olarak gelir.
    ///Biz de bunları programımızdaki Kullanici nesnesiine dönüştürüyoruz
    return Kullanici(
      id: doc.documentID,
      kullaniciAdi: doc.data['kullaniciAdi'],
      email: doc.data['email'],
      fotoUrl: doc.data['fotoUrl'],
      hakkinda: doc.data['hakkinda'],
    );
  }
}
