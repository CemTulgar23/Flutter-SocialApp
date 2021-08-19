const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.takipGerceklesti = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onCreate(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenId;
    const takipEdenId = context.params.takipEdenKullaniciId;

   const gonderilerSnapshot = await admin.firestore().collection("gonderiler").doc(takipEdilenId).collection("kullaniciGonderileri").get();

   gonderilerSnapshot.forEach((doc)=>{
        if(doc.exists){
            const gonderiId = doc.id;
            const gonderiData = doc.data();

            admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(gonderiData);
        }
   });
});

exports.takiptenCikildi = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onDelete(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenId;
    const takipEdenId = context.params.takipEdenKullaniciId;

   const gonderilerSnapshot = await admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").where("yayinlayanId", "==", takipEdilenId).get();

   gonderilerSnapshot.forEach((doc)=>{
        if(doc.exists){
            doc.ref.delete();
        }
   });
});

exports.yeniGonderiEklendi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri/{gonderiId}').onCreate(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;
    const yeniGonderiData = snapshot.data();

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(yeniGonderiData);
    });
});

exports.gonderiGuncellendi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri/{gonderiId}').onUpdate(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;
    const guncellenmisGonderiData = snapshot.after.data();

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).update(guncellenmisGonderiData);
    });
});

exports.gonderiSilindi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri/{gonderiId}').onDelete(async (snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

    takipcilerSnapshot.forEach(doc=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).delete();
    });
});

/*
exports.kayitSilindi = functions.firestore.document('deneme/{docId}').onDelete((snapshot, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonundan kayıt silindi."
    });
});
exports.kayitGuncellendi = functions.firestore.document('deneme/{docId}').onUpdate((change, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonunda kayıt güncellendi."
    });
});
exports.yazmaGerceklesti = functions.firestore.document('deneme/{docId}').onWrite((change, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonunda veri ekleme, silme, güncelleme işlemlerinden biri gerçekleşti."
    });
});
*/
//////////----------//////////----------//////////----------//////////----------//////////
/*
const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

//Firebase functions, cloud fonksiyonları oluşturmamızı ve 
//bu fonksiyonların hangi durumlarda çalışacağını belirler

//Firebase admin, firebase servisindeki verileri yönetebilmemizi sağlar
//silme, güncelleme, ekleme işlemleri gibi...

exports.takipGerceklesti = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onCreate(async(snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenId;
    const takipEdenId = context.params.takipEdenKullaniniId;

    const gonderilerSnapshot = await admin.firestore().collection("gonderiler").doc(takipEdilenId).collection("kullaniciGonderileri").get();
    //Takip ettiğimiz kullanıcının bütün gönderilerini çektik

    gonderilerSnapshot.forEach((doc)=>{
        if (doc.exists) {
            const gonderiId = doc.id;
            const gonderiData = doc.data(); //Gönderi içeriği

            admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(gonderiData);
        }
    ///Takip edilen kullanıcının gönderilerini getirdik. 
    ///Bu gönderileri snapshot değişkenine atadık ve forEach'ta dönerek akişlar koleksiyonuna atadık    
    });
});

exports.takiptenCikildi = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onDelete(async(snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenId;
    const takipEdenId = context.params.takipEdenKullaniniId;

    const gonderilerSnapshot = await admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").where("yayinlayanId","==",takipEdilenId).get();
    ///Daha önce akışlar koleksiyonuna eklediğimiz gönderileri takip eden id'ye göre getirdik. 

    gonderilerSnapshot.forEach((doc)=>{
        if (doc.exists) {
            doc.ref.delete();
        }
    });
});

exports.yeniGonderiEklendi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri{gonderiId}').onCreate(async(snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;
    const yeniGonderiData = snapshot.data; //Yeni eklenen gönderinin içeriği

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();
    takipcilerSnapshot.forEach((doc)=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(yeniGonderiData);
    });
    ///Takip edilen kullanıcının takipçilerini getirdik. Bu takipçileri forEach'ta dönerek 
    ///id'lerini takipciId değişkenine atadık. Daha sonra da id'sini bildiğimiz kullanıcının gönderileri koleksiyonuna 
    ///takipedilen kullanıcının paylaştığı resmin id'sini ekledik. 
});

exports.gonderiGuncellendi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri{gonderiId}').onUpdate(async(snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;
    const guncellenmisGonderiData = snapshot.after.data; //Yeni eklenen gönderinin içeriği

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();
    takipcilerSnapshot.forEach((doc)=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).update(guncellenmisGonderiDataGonderiData);
    });
    ///Takip edilen kullanıcının takipçilerini getirdik. Bu takipçileri forEach'ta dönerek 
    ///id'lerini takipciId değişkenine atadık. Daha sonra da id'sini bildiğimiz kullanıcının gönderileri koleksiyonuna 
    ///takipedilen kullanıcının paylaştığı resmin id'sini ekledik. 
});

exports.gonderiSilindi = functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciGonderileri{gonderiId}').onDelete(async(snapshot, context) => {
    const takipEdilenId = context.params.takipEdilenKullaniciId;
    const gonderiId = context.params.gonderiId;

    const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();
    takipcilerSnapshot.forEach((doc)=>{
        const takipciId = doc.id;
        admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).delete(guncellenmisGonderiDataGonderiData);
    });
    ///Takip edilen kullanıcının takipçilerini getirdik. Bu takipçileri forEach'ta dönerek 
    ///id'lerini takipciId değişkenine atadık. Daha sonra da id'sini bildiğimiz kullanıcının gönderileri koleksiyonuna 
    ///takipedilen kullanıcının paylaştığı resmin id'sini ekledik. 
});

/*
exports.kayitSilindi = functions.firestore.document('deneme/{docId}').onDelete((snapshot, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonundan kayıt silindi"
    });
});

exports.kayitGuncellendi = functions.firestore.document('deneme/{docId}').onUpdate((change, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonundaki kayıt güncellendi"
    });
});

exports.yazmaGerceklesti = functions.firestore.document('deneme/{docId}').onWrite((change, context) => {
    admin.firestore().collection("gunluk").add({
        "aciklama":"Deneme koleksiyonunda veri; ekleme, silme, güncelleme işlemlerinden biri gerçekleşti"
    });
});
//exports.gunlukekle: diyerek adını belirledik
//onUpdate ve onWrite olaylarında verilerde bir değişiklik olduğu için snapshot yerine change yazdık
*/
