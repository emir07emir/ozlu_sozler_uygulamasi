import 'package:idamobile_challenge/classlar/Favorilerim.dart';
import 'package:idamobile_challenge/classlar/OzluSozler.dart';
import 'package:idamobile_challenge/veritabani_islemleri/VeritabaniYardimcisi.dart';

class VeritabaniDAO{
  Future<List<OzluSozler>> EkranaGetir() async{

    //todo veritabanına bağlandık
    var db=await VeritabaniYardimcisi.veritabaniErisim();

    //todo veritabanından veri çektik
    List<Map<String,dynamic>> maps =await db.rawQuery("SELECT * FROM ozlusozler");

    //todo verileri listeyi kullanabileceğimiz hale getirdik
    return List.generate(maps.length, (index) {


      var satir = maps[index];
      return OzluSozler(satir["ozlu_soz_id"], satir["ozlu_soz_ad"], satir["ozlu_soz_yazar"]);
    });

  }

  Future<List<Favorilerim>> EkranaGetirFavoriler() async{

    //todo veritabanına bağlandık
    var db=await VeritabaniYardimcisi.veritabaniErisimFavoriler();

    //todo veritabanından veri çektik
    List<Map<String,dynamic>> maps =await db.rawQuery("SELECT * FROM favorilerim");

    //todo verileri listeyi kullanabileceğimiz hale getirdik
    return List.generate(maps.length, (index) {
      var satir = maps[index];
      return Favorilerim(satir["favori_id"], satir["favori_ad"], satir["favori_yazar"]);
    });

  }

    Future<void> veriEkleFavoriler(String favori_ad, String favori_yazar) async {
      var db = await VeritabaniYardimcisi.veritabaniErisimFavoriler();
      var bilgiler=Map<String,dynamic>();
      bilgiler["favori_ad"]=favori_ad;
      bilgiler["favori_yazar"] = favori_yazar;
      await db.insert("favorilerim", bilgiler);
    }

    Future<void> veriSilFavoriler(int favori_id) async{
    var db = await VeritabaniYardimcisi.veritabaniErisimFavoriler();
    await db.delete("favorilerim",where: "favori_id=?",whereArgs: [favori_id]);

    }








}