import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Cubit için
import 'package:idamobile_challenge/BlocCubit/TemaCubit.dart'; // TemaCubit importu
import 'package:idamobile_challenge/classlar/Favorilerim.dart';
import 'package:idamobile_challenge/veritabani_islemleri/VeritabaniDAO.dart';

class FavorilerSayfasi extends StatefulWidget {
  const FavorilerSayfasi({super.key});

  @override
  State<FavorilerSayfasi> createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavorilerSayfasi> {

  List<Favorilerim> favorilerimListe = [];

  @override
  void initState() {
    super.initState();
    EkranaGetirFavorilerim();
  }

  Future<void> EkranaGetirFavorilerim() async {
    var liste = await VeritabaniDAO().EkranaGetirFavoriler();
    setState(() {
      favorilerimListe = liste;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- RENK VE TEMA AYARLARI ---
    var tema = Theme.of(context);

    // TemaCubit'i dinliyoruz (Switch durumu için)
    bool isDarkMode = context.watch<TemaCubit>().state;

    Color arkaPlanRengi = tema.scaffoldBackgroundColor;
    Color kartRengi = tema.cardColor;

    // Yazı rengini temadan alıyoruz
    Color yaziRengi = tema.textTheme.bodyLarge?.color ?? Colors.black;

    // İkincil yazı rengi (Yazar adı vb.)
    Color ikincilYaziRengi = isDarkMode ? Colors.grey : const Color(0xFF9C9EAE);

    return Scaffold(
      backgroundColor: arkaPlanRengi,
      appBar: AppBar(
        backgroundColor: tema.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "FAVORİLERİM",
          style: TextStyle(color: yaziRengi, fontWeight: FontWeight.bold),
        ),
        //todo - SWITCH BUTONU -
        actions: [
          Row(
            children: [
              Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 20),
              Switch(
                value: isDarkMode,
                activeColor: Color(0xFF6C63FF),
                onChanged: (deger) {
                  context.read<TemaCubit>().temaDegistir();
                },
              ),
              const SizedBox(width: 8),
            ],
          )
        ],
      ),

      body: favorilerimListe.isEmpty
          ? Center(
          child: Text(
              "Henüz favori özlü sözün yok.",
              style: TextStyle(color: yaziRengi, fontSize: 25)
          )
      )
          : ListView.builder(
        itemCount: favorilerimListe.length,
        itemBuilder: (context, index) {
          var favorilerim = favorilerimListe[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kartRengi, // Dinamik Kart Rengi
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed:() async{
                              // Veritabanından sil
                              await VeritabaniDAO().veriSilFavoriler(favorilerim.favori_id);

                              //listeden sil(ekrandan da gitmiş oluyor)
                              setState(() {
                                favorilerimListe.removeAt(index);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Center(child: Text("Favorilerden kaldırıldı",style: TextStyle(color: Colors.red),)), duration: Duration(seconds: 1),)
                              );
                            },
                            icon: const Icon(Icons.star, size: 28, color: Colors.amber)
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      '"${favorilerim.favori_ad}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: yaziRengi, // Dinamik Renk
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "- ${favorilerim.favori_yazar}",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: ikincilYaziRengi, // Dinamik Renk
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}