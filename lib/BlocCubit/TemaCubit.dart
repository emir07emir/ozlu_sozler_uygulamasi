import 'package:flutter_bloc/flutter_bloc.dart';

class TemaCubit extends Cubit<bool>{
  TemaCubit() : super(false);

  void temaDegistir() {
    emit(!state);
  }
}