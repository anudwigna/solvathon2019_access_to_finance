import 'package:flutter/foundation.dart';
import 'package:MunshiG/config/globals.dart' as globals;

enum Lang { EN, NP }

class PreferenceProvider extends ChangeNotifier {
  Lang _language = globals.language == 'en' ? Lang.EN : Lang.NP;

  Lang get language => _language;

  set language(Lang lang) {
    _language = lang;
    notifyListeners();
  }
}

class SubSectorProvider extends ChangeNotifier {
  String _selectedSubSector = globals.selectedSubSector;

  String get selectedSubSector => _selectedSubSector;

  set selectedSubSector(String subSector) {
    _selectedSubSector = subSector;
    notifyListeners();
  }
}
