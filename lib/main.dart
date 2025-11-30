import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idamobile_challenge/BlocCubit/SayfalarCubit.dart';
import 'package:idamobile_challenge/BlocCubit/TemaCubit.dart';
import 'package:idamobile_challenge/views/NavigatorButtonSayfasi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SayfalarCubit()),
        BlocProvider(create: (context) => TemaCubit()),
      ],
      //todo BLOCCUBİT YAPISI İLE HABERLEŞTİRİYORUZ
      child: BlocBuilder<TemaCubit, bool>(
        builder: (context, darkModMu) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Özlü Sözler',

            //todo 1. AYDINLIK TEMA (LIGHT MODE)
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF2F5F9),
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF2F5F9),
                elevation: 0,
                // AppBar ikonları koyu renk olsun
                iconTheme: IconThemeData(color: Color(0xFF2D3142)),
                titleTextStyle: TextStyle(color: Color(0xFF2D3142), fontSize: 20, fontWeight: FontWeight.bold),
              ),
              textTheme: GoogleFonts.outfitTextTheme().apply(
                bodyColor: const Color(0xFF2D3142),
                displayColor: const Color(0xFF2D3142),
              ),
            ),

            //todo 2. KARANLIK TEMA (DARK MODE)
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              // Göz yormayan koyu renkler:
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                elevation: 0,
                // AppBar ikonları beyaz olsun
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Fontları beyaza çeviriyoruz
              textTheme: GoogleFonts.outfitTextTheme().apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),

            //todo 3. KONROL MEKANİZMASI
            // Cubit true ise Dark, false ise Light oluyor
            themeMode: darkModMu ? ThemeMode.dark : ThemeMode.light,

            home: NavigatorButtonSayfasi(),
          );
        },
      ),
    );
  }
}