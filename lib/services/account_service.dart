import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sampatti/models/account/account.dart';
import 'package:sampatti/models/database_and_store.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sampatti/models/transaction/transaction.dart' as t;

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
    var snapshot = await dbStore.store.find(dbStore.database);
    return snapshot.map((record) => Account.fromJson(record.value)).toList();
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future addAccount(Account account) async {
    var dbStore = await getDatabaseAndStore();
    await dbStore.store.add(dbStore.database, account.toJson());
  }

  Future deleteAccount(Account account) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals('name', account.name),
        Filter.equals('type', account.type),
      ]),
    );
    await dbStore.store.delete(
      dbStore.database,
      finder: finder,
    );
  }

  /// Name and Type should match in order to update
  Future updateAccount(Account account) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals('name', account.name),
        Filter.equals('type', account.type),
      ]),
    );
    await dbStore.store.update(
      dbStore.database,
      account.toJson(),
      finder: finder,
    );
  }

  Future<Account> getAccountForTransaction(t.Transaction transaction) async {
    Account _account;
    var dbStore = await getDatabaseAndStore();
    var snapshot = await dbStore.store.find(dbStore.database);
    if (snapshot.length > 0) {
      snapshot.forEach(
        (record) {
          var account = Account.fromJson(record.value);
          if (account.transactionIds.contains(transaction.id)) {
            _account = account;
          }
        },
      );
    }
    return _account;
  }
}
