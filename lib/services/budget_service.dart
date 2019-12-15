import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sampatti/models/budget/budget.dart';
import 'package:sampatti/models/database_and_store.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class BudgetService {
  BudgetService._();

  factory BudgetService() => BudgetService._();

  Future<DatabaseAndStore> getDatabaseAndStore() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database: await dbFactory.openDatabase(await _getDbPath('budget.db')),
      store: intMapStoreFactory.store('budget'),
    );
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future<Budget> getBudget(int categoryId, int month) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals('month', month),
        Filter.equals('categoryId', categoryId),
      ]),
    );
    var snapshot = await dbStore.store.find(dbStore.database, finder: finder);
    if (snapshot.isEmpty) {
      return Budget();
    }
    return Budget.fromJson(snapshot[0].value);
  }

  /// Updates the budget
  ///
  /// Adds new budget record if record doesn't exist.
  Future updateBudget(Budget budget) async {
    print('Budget ${budget.toJson()}');
    if (budget.month != null && budget.categoryId != null) {
      var dbStore = await getDatabaseAndStore();
      Filter checkRecord = Filter.and([
        Filter.equals(
          'month',
          budget.month,
        ),
        Filter.equals(
          'categoryId',
          budget.categoryId,
        )
      ]);
      bool recordFound =
          (await dbStore.store.count(dbStore.database, filter: checkRecord)) !=
              0;
      if (recordFound) {
        await dbStore.store.update(
          dbStore.database,
          budget.toJson(),
          finder: Finder(
            filter: checkRecord,
          ),
        );
      } else {
        await dbStore.store.add(
          dbStore.database,
          budget.toJson(),
        );
      }
    }
  }

  Future clearBudget(Budget budget) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals(
          'month',
          budget.month,
        ),
        Filter.equals(
          'categoryId',
          budget.categoryId,
        )
      ]),
    );
    await dbStore.store.delete(dbStore.database, finder: finder);
  }

  Future deleteBudgetsForCategory(int categoryId) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.equals(
        'categoryId',
        categoryId,
      ),
    );
    await dbStore.store.delete(dbStore.database, finder: finder);
  }
}
