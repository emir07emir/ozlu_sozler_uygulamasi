import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idamobile_challenge/BlocCubit/SayfalarCubit.dart';
import 'package:idamobile_challenge/views/AnaEkran.dart';
import 'package:idamobile_challenge/views/FavorilerSayfasi.dart';

class NavigatorButtonSayfasi extends StatefulWidget {
  const NavigatorButtonSayfasi({super.key});

  @override
  State<NavigatorButtonSayfasi> createState() => _NavigatorButtonSayfasiState();
}

class _NavigatorButtonSayfasiState extends State<NavigatorButtonSayfasi> {
  int currentIndex = 0;
  final List<Widget> sayfalar = [
    AnaEkran(),
    FavorilerSayfasi(),
  ];



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SayfalarCubit,int>(
      builder: (context,currentIndex){
        return Scaffold(
          body:sayfalar[currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => context.read<SayfalarCubit>().changePage(index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor:const Color(0xFF6C63FF),
            selectedFontSize: 15,
            unselectedFontSize: 14,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Ana Sayfa",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_border_outlined),
                activeIcon: Icon(Icons.star),
                label: "Favorilerim",
              ),
            ],
          ),
        );
      },
    );
  }
}
