import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MunshiG/models/account/account.dart';
import 'package:MunshiG/models/database_and_store.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:MunshiG/models/transaction/transaction.dart' as t;

import '../services/activity_tracking.dart';
import '../models/app_page_naming.dart';

class AccountService {
  AccountService._();

  factory AccountService() => AccountService._();

  Future<DatabaseAndStore> getDatabaseAndStore() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database: await dbFactory.openDatabase(await _getDbPath('accounts.db')),
      store: intMapStoreFactory.store('accounts'),
    );
  }

  Future<List<Account>> getAccounts() async {
    var dbStore = await getDatabaseAndStore();
    List<RecordSnapshot<int?, Map<String, dynamic>>> snapshot = await dbStore.store!.find(dbStore.database);
    return snapshot.map((record) => Account.fromJson(record.value)).toList();
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  ///if this function is invoked without user consent
  Future addAccount(Account account, bool isAutomated) async {
    var dbStore = await getDatabaseAndStore();
    await dbStore.store!.add(dbStore.database, account.toJson());
    if (!(isAutomated)) ActivityTracker().otherActivityOnPage(PageName.account, 'Add Account', 'Save', 'FlatButton');
  }

  Future deleteAccount(Account account, bool isAutomated) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals('name', account.name),
        Filter.equals('type', account.type),
      ]),
    );
    await dbStore.store!.delete(
      dbStore.database,
      finder: finder,
    );
    if (!(isAutomated)) ActivityTracker().otherActivityOnPage(PageName.account, 'Delete Account', 'Delete', 'FlatButton');
  }

  /// Name and Type should match in order to update
  Future updateAccount(Account account, bool isAutomated) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals('name', account.name),
        Filter.equals('type', account.type),
      ]),
    );
    await dbStore.store!.update(
      dbStore.database,
      account.toJson(),
      finder: finder,
    );
    if (!(isAutomated)) ActivityTracker().otherActivityOnPage(PageName.account, 'Update Account', 'Update', 'FlatButton');
  }

  Future<Account?> getAccountForTransaction(t.Transaction? transaction) async {
    Account? _account;
    var dbStore = await getDatabaseAndStore();
    List<RecordSnapshot<int?, Map<String, dynamic>>> snapshot = await dbStore.store!.find(dbStore.database);
    if (snapshot.length > 0) {
      snapshot.forEach(
        (record) {
          var account = Account.fromJson(record.value);
          if (account.transactionIds!.contains(transaction!.id)) {
            _account = account;
          }
        },
      );
    }
    return _account;
  }

  Future<bool> checkifAccountExists(Account account) async {
    var dbStore = await getDatabaseAndStore();
    Filter filter = Filter.and([
      Filter.equals('name', account.name),
      Filter.equals('type', account.type),
    ]);
    int zz = await dbStore.store!.count(dbStore.database, filter: filter);
    return zz > 0;
  }

  Future<void> closeDatabase(String subsector) async {
    final db = await getDatabaseAndStore();
    await db.database.close();
  }
}
