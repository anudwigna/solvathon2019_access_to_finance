import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class PreferenceService {
  PreferenceService._();

  static PreferenceService get instance => PreferenceService._();

  Future<_SembastPreference> _init() async =>
      await _SembastPreference.getInstance();

  Future setIsFirstStart(bool value) async {
    var prefs = await _init();
    prefs.set('IS_FIRST_START', value);
  }

  Future<bool> getIsFirstStart() async {
    var prefs = await _init();
    return (await prefs.get('IS_FIRST_START')) as bool ?? true;
  }

  Future<bool> isUserRegistered() async {
    var prefs = await _init();
    return (await prefs.get('IS_USER_REGISTERED')) as bool ?? false;
  }

  Future setIsUserRegistered() async {
    var prefs = await _init();
    prefs.set('IS_USER_REGISTERED', true);
  }

  Future setLanguage(String value) async {
    var prefs = await _init();
    prefs.set('LANGUAGE', value);
  }

  Future<String> getLanguage() async {
    var prefs = await _init();
    return (await prefs.get('LANGUAGE')) as String;
  }

  Future setSelectedSubSector(String value) async {
    var prefs = await _init();
    prefs.set('SUBSECTOR', value);
  }

  Future<String> getSelectedSubSector() async {
    var prefs = await _init();
    return (await prefs.get('SUBSECTOR')) as String;
  }

  Future setCurrentIncomeCategoryIndex(int value) async {
    var prefs = await _init();
    prefs.set('CURRENT_INCOME_CATEGORY_INDEX', value);
  }

  Future<int> getCurrentIncomeCategoryIndex() async {
    var prefs = await _init();
    return (await prefs.get('CURRENT_INCOME_CATEGORY_INDEX') ?? 0) as int;
  }

  Future setV102ChangesFlag() async {
    var prefs = await _init();
    prefs.set('V102_CHANGES_FLAG', true);
  }

  Future<bool> getV102ChangesFlag() async {
    var prefs = await _init();
    return (await prefs.get('V102_CHANGES_FLAG') ?? false);
  }

  Future setCurrentExpenseCategoryIndex(int value) async {
    var prefs = await _init();
    prefs.set('CURRENT_EXPENSE_CATEGORY_INDEX', value);
  }

  Future<int> getCurrentExpenseCategoryIndex() async {
    var prefs = await _init();
    return (await prefs.get('CURRENT_EXPENSE_CATEGORY_INDEX') ?? 0) as int;
  }

  Future setCurrentTransactionIndex(int value) async {
    var prefs = await _init();
    prefs.set('CURRENT_TRANSACTION_INDEX', value);
  }

  Future<int> getCurrentTransactionIndex() async {
    var prefs = await _init();
    return (await prefs.get('CURRENT_TRANSACTION_INDEX') ?? 0) as int;
  }

  Future setSubSectors(List<dynamic> value) async {
    var prefs = await _init();
    prefs.set('SUBSECTORS', value);
  }

  Future<List<dynamic>> getSubSectors() async {
    var prefs = await _init();
    return (await prefs.get('SUBSECTORS') ?? []) as List<dynamic>;
  }

  Future setPageTrackCountIndex(int value) async {
    var prefs = await _init();
    prefs.set('PAGE_TRACK_COUNT_INDEX', value);
  }

  Future<int> getPageTrackCountIndex() async {
    var prefs = await _init();
    return (await prefs.get('PAGE_TRACK_COUNT_INDEX') ?? 0) as int;
  }

  Future setLastBackUpDate() async {
    var prefs = await _init();
    prefs.set('LAST_BACK_UP_DATE', DateTime.now().toIso8601String());
  }

  Future<String> getLastBackUpDate() async {
    var prefs = await _init();
    return await prefs.get('LAST_BACK_UP_DATE');
  }
}

class _SembastPreference {
  _SembastPreference._(this.db);

  static _SembastPreference _instance;

  static Future<_SembastPreference> getInstance() async {
    if (_instance == null) {
      DatabaseFactory dbFactory = databaseFactoryIo;
      Database database =
          await dbFactory.openDatabase(await _getDbPath('preference.db'));
      _instance = _SembastPreference._(database);
    }
    return _instance;
  }

  Database db;

  static Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future set(String key, dynamic value) async => await db.put(value, key);

  Future<dynamic> get(String key) async => await db.get(key);
}
