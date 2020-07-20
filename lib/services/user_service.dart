import 'package:path_provider/path_provider.dart';
import 'package:MunshiG/models/database_and_store.dart';
import 'package:MunshiG/models/user/user.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class UserService {
  UserService._();

  factory UserService() => UserService._();

  Future<DatabaseAndStore> getDatabaseAndStore() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database: await dbFactory.openDatabase(await _getDbPath('user.db')),
      store: intMapStoreFactory.store('user'),
    );
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future<void> addUser(User data) async {
    var dbStore = await getDatabaseAndStore();
    var d = await dbStore.store.add(dbStore.database, data.toJson());
  }

  Future<User> getAccounts() async {
    var dbStore = await getDatabaseAndStore();
    var snapshot = await dbStore.store.findFirst(dbStore.database);
    return (snapshot?.value != null) ? User.fromJson(snapshot.value) : User();
  }

  Future<void> updateUser(User user) async {
    var dbStore = await getDatabaseAndStore();
    var snapshot = await dbStore.store.update(dbStore.database, user.toJson(),
        finder: Finder(filter: Filter.equals('phonenumber', user.phonenumber)));
  }
}
