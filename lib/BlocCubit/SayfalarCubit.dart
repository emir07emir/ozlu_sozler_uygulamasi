import 'package:flutter_bloc/flutter_bloc.dart';

class SayfalarCubit extends Cubit<int>{
  SayfalarCubit():super(0);
  void changePage(int index){
    emit(index);
  }

}