import 'package:flutter/foundation.dart';
import '../models/ciudad.dart';

/// Provider simple que mantiene la ciudad seleccionada en Home.
class CityProvider extends ChangeNotifier {
  CiudadEcuador _selected = CiudadesEcuadorData.ciudades.first;
  CiudadEcuador get selected => _selected;

  void select(CiudadEcuador ciudad) {
    _selected = ciudad;
    notifyListeners();
  }
}
