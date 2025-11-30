import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idamobile_challenge/BildirimVePaylasServisleri/BildirimServisi.dart';
import 'package:idamobile_challenge/BlocCubit/TemaCubit.dart';
import 'package:idamobile_challenge/classlar/OzluSozler.dart';
import 'package:idamobile_challenge/veritabani_islemleri/VeritabaniDAO.dart';
import 'package:share_plus/share_plus.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {

  var bildirimServisi = BildirimServisi();
  List<OzluSozler> ozluSozlerListe = [];
  OzluSozler? gununSozu;
  bool begenildiMi = false;

    //todo SÖZ PAYLAŞ KISMI
  void sozuPaylas() {
    if(gununSozu != null){
      String paylasilacakSoz = '"${gununSozu!.ozlu_soz_ad}" - ${gununSozu!.ozlu_soz_yazar}';

      Share.share(paylasilacakSoz);
    }
  }



  //todo BİLDİRİM OLUŞTUR KISMI
  Future<void> bildirimOlustur() async{
    TimeOfDay? secilenSaat = await showTimePicker(
        context: context, 
        initialTime: TimeOfDay.now(),
        helpText: "Hatırlatma Saatini Seç"
    );
    
    if(secilenSaat != null) {
      await bildirimServisi.bildirimZamanla(
          "Günün Sözü Hazır", "İlham Almak İçin Dokun", secilenSaat);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Her gün ${secilenSaat.hour} : ${secilenSaat
              .minute} saatinde hatırlatma yapılacak:)"),
            backgroundColor: Colors.green,
          )
      );
    }
  }



  //todo EKRANA GETİR FONKSİYONU(ÖZLÜ SÖZLER)
  Future<void> ekranaGetir() async{
    var liste =await VeritabaniDAO().EkranaGetir();

    if(liste.isNotEmpty){
      int index = gunlukIndexBul(liste.length);
      var secilenSoz = liste[index];

      var favoriler = await VeritabaniDAO().EkranaGetirFavoriler();
      bool veritabanindaVarMi = favoriler.any((e) => e.favori_ad == secilenSoz.ozlu_soz_ad);

      setState(() {
        ozluSozlerListe = liste;
        gununSozu = secilenSoz;
        begenildiMi = veritabanindaVarMi;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    ekranaGetir();
    bildirimServisi.kurulumuYap();
    bildirimServisi.IzinIste();
  }
  //todo KONSOLA YAZDIR (KONTROL AMAÇLI)
  Future<void> konsolaYazdir() async{
    var liste =await VeritabaniDAO().EkranaGetir();
    for(var ozluSoz in liste){
      print("soz id : ${ozluSoz.ozlu_soz_id}");
      print("soz ad : ${ozluSoz.ozlu_soz_ad}");
      print("soz yazarı : ${ozluSoz.ozlu_soz_yazar}");
      print("******");
    }
  }
//todo GÜNE GÖRE EKRANDA SÖZ GÖSTERME
  int gunlukIndexBul(int listeUzunlugu){
    DateTime bugun = DateTime.now();
    DateTime baslangicTarihi = DateTime(2025,11,27); //rastgele bir tarih verdim
    int gecenGunSayisi = bugun.difference(baslangicTarihi).inDays; // günlere göre fark al

    return gecenGunSayisi.abs() % listeUzunlugu;
  }





  @override
  Widget build(BuildContext context) {
    var tema = Theme.of(context);
    
    bool isDarkMode = context.watch<TemaCubit>().state;
    Color arkaPlanRengi = tema.scaffoldBackgroundColor;
    Color kartRengi = tema.cardColor;
    Color yaziRengi = tema.textTheme.bodyLarge?.color ?? Colors.black;
    Color ikincilYaziRengi = isDarkMode ? Colors.grey : const Color(0xFF9C9EAE);
    
    return Scaffold(
      backgroundColor: arkaPlanRengi,
        appBar: AppBar(
          actions: [
            Row(
              children: [
                Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 20),
                Switch(
                    value: isDarkMode,
                    activeColor: Color(0xFF6C63FF),
                    onChanged:(value){
                      context.read<TemaCubit>().temaDegistir();
                    }),
                SizedBox(width: 8,),
              ],
            )
          ],
            backgroundColor: arkaPlanRengi,
            centerTitle: true,
          title: Text("ÖZLÜ SÖZLER",style: TextStyle(color: yaziRengi,fontWeight: FontWeight.bold),),
        ),
        body: gununSozu == null ? Center(child: CircularProgressIndicator()) :
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
              width: double.infinity,
            decoration: BoxDecoration(
              color: kartRengi,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Günün Sözü",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: ikincilYaziRengi,letterSpacing: 1.5),),
                          IconButton(
                              onPressed:() async{
                                setState(() {
                                  begenildiMi = !begenildiMi;
                                });
                                if(begenildiMi==true){
                                  await VeritabaniDAO().veriEkleFavoriler(gununSozu!.ozlu_soz_ad, gununSozu!.ozlu_soz_yazar);
                                  setState(() {
                                    VeritabaniDAO().EkranaGetirFavoriler();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Center(child: Text("Favorilere Eklendi",style: TextStyle(color: Colors.green),)),duration: Duration(seconds: 2),));
                                }
                                else{
                                  var favorilerListesi = await VeritabaniDAO().EkranaGetirFavoriler();
                                  for(var i in favorilerListesi){
                                    if(i.favori_ad == gununSozu!.ozlu_soz_ad){
                                      await VeritabaniDAO().veriSilFavoriler(i.favori_id);
                                      break;
                                    }
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Center(child: Text("Favorilerden kaldırıldı",style: TextStyle(color: Colors.red),)),duration: Duration(seconds: 2),));
                                }

                              },
                              icon:begenildiMi ? Icon(Icons.star,size: 28,color: Colors.amber,):Icon(Icons.star_border,size: 28)
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Text('"${gununSozu!.ozlu_soz_ad}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        fontSize: 24,
                          height: 1.3, // satırarası boşluklar
                          fontWeight: FontWeight.w600,
                          color: yaziRengi,
                      ),),
                      SizedBox(height: 20,),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("~${gununSozu!.ozlu_soz_yazar}~",style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: ikincilYaziRengi,
                        ),),
                      ),
                    ],
                  ),
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () async{
                        await bildirimOlustur();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: kartRengi,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.notifications_outlined, color: const Color(0xFF6C63FF), size: 28), // Modern bir mor/mavi tonu
                            const SizedBox(height: 8),
                            Text(
                              "Bildirim Oluştur",
                              style: TextStyle(
                                color: yaziRengi,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: (){
                          print("Paylaş Butonuna Basıldı");
                          sozuPaylas();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: kartRengi,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.share_outlined,color:Color(0xFF6C63FF),size: 28,),
                              SizedBox(height: 8),
                              Text("Paylaş",style: TextStyle(
                                color: yaziRengi,
                                fontWeight: FontWeight.w500,
                              ),),
                            ],
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),

          ],
        ),
      ),
    );
  }
}
