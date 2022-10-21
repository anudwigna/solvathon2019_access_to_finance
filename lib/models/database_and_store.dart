import 'package:sembast/sembast.dart';

class DatabaseAndStore {
  final Database? database;
  final StoreRef<int?, Map<String, dynamic>>? store;

  DatabaseAndStore({
    this.database,
    this.store,
  });
}
