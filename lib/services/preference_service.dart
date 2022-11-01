import 'package:MunshiG/models/database_and_store.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class PreferenceService {
  PreferenceService._();

  static PreferenceService get instance => PreferenceService._();

  Future<_SembastPreference> _init() async => await _SembastPreference.getInstance();

  Future setIsFirstStart(bool value) async {
    var prefs = await (_init());
    await prefs.set<bool>('IS_FIRST_START', value);
  }

  Future<bool> getIsFirstStart() async {
    var prefs = await (_init());
    return (await prefs.get<bool?>('IS_FIRST_START')) ?? true;
  }

//
  Future setIsUserRegistered() async {
    var prefs = await (_init());
    await prefs.set<bool>('IS_USER_REGISTERED', true);
  }

  Future<bool> isUserRegistered() async {
    var prefs = await (_init());
    return (await prefs.get<bool?>('IS_USER_REGISTERED')) ?? false;
  }

//
  Future setLanguage(String value) async {
    var prefs = await (_init());
    await prefs.set<String>('LANGUAGE', value);
  }

  Future<String?> getLanguage() async {
    var prefs = await (_init());

    return (await prefs.get<String?>('LANGUAGE'));
  }

//
  Future setSelectedSubSector(String? value) async {
    var prefs = await (_init());
    await prefs.set<String?>('SUBSECTOR', value);
  }

  Future<String?> getSelectedSubSector() async {
    var prefs = await (_init());
    return (await prefs.get<String?>('SUBSECTOR'));
  }

//
  Future setCurrentIncomeCategoryIndex(int value) async {
    var prefs = await (_init());
    await prefs.set<int>('CURRENT_INCOME_CATEGORY_INDEX', value);
  }

  Future<int> getCurrentIncomeCategoryIndex() async {
    var prefs = await (_init());
    return (await prefs.get<int?>('CURRENT_INCOME_CATEGORY_INDEX') ?? 0);
  }

//
  Future setV102ChangesFlag() async {
    var prefs = await (_init());
    await prefs.set<bool>('V102_CHANGES_FLAG', true);
  }

  Future<bool> getV102ChangesFlag() async {
    var prefs = await (_init());
    return (await prefs.get<bool?>('V102_CHANGES_FLAG')) ?? false;
  }

//
  Future setCurrentExpenseCategoryIndex(int value) async {
    var prefs = await (_init());
    await prefs.set<int>('CURRENT_EXPENSE_CATEGORY_INDEX', value);
  }

  Future<int> getCurrentExpenseCategoryIndex() async {
    var prefs = await (_init());
    return (await prefs.get<int?>('CURRENT_EXPENSE_CATEGORY_INDEX')) ?? 0;
  }

  Future setCurrentTransactionIndex(int value) async {
    var prefs = await (_init());
    await prefs.set<int>('CURRENT_TRANSACTION_INDEX', value);
  }

  Future<int> getCurrentTransactionIndex() async {
    var prefs = await (_init());
    return (await prefs.get<int?>('CURRENT_TRANSACTION_INDEX')) ?? 0;
  }

  Future setSubSectors(List<dynamic> value) async {
    var prefs = await (_init());
    await prefs.set<List<dynamic>>('SUBSECTORS', value);
  }

  Future<List<dynamic>> getSubSectors() async {
    var prefs = await (_init());
    return (await prefs.get<List<dynamic>?>('SUBSECTORS')) ?? [];
  }

  Future setPageTrackCountIndex(int value) async {
    var prefs = await (_init());
    await prefs.set<int>('PAGE_TRACK_COUNT_INDEX', value);
  }

  Future<int> getPageTrackCountIndex() async {
    var prefs = await (_init());
    return (await prefs.get<int?>('PAGE_TRACK_COUNT_INDEX')) ?? 0;
  }

  Future setLastBackUpDate() async {
    var prefs = await (_init());
    await prefs.set<String>('LAST_BACK_UP_DATE', DateTime.now().toIso8601String());
  }

  Future<String?> getLastBackUpDate() async {
    var prefs = await (_init());
    return await prefs.get<String?>('LAST_BACK_UP_DATE');
  }
}

class _SembastPreference {
  _SembastPreference._(this.db);

  static _SembastPreference? _instance;

  static Future<_SembastPreference> getInstance() async {
    if (_instance == null) {
      DatabaseFactory dbFactory = databaseFactoryIo;
      Database database = (await dbFactory.openDatabase(await _getDbPath('preference.db')));
      _instance = _SembastPreference._(database);
    }

    return _instance!;
  }

  final StoreRef _storeReference = StoreRef.main();
  Database db;

  static Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future set<T>(String key, T value) async {
    final checkValue = await _storeReference.find(db, finder: Finder(filter: Filter.byKey(key)));
    if (checkValue.isEmpty)
      await _storeReference.add(db, {key: value});
    else {
      await _storeReference.update(db, {key: value}, finder: Finder(filter: Filter.byKey(key)));
    }
  }

  Future<T?> get<T>(String key) async {
    final value = await _storeReference.find(db, finder: Finder(filter: Filter.byKey(key)));
    if (value.isEmpty) return null;
    return value.first.value as T;
  }
}
