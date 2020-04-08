import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saral_lekha/models/account/account.dart';
import 'package:saral_lekha/models/budget/budget.dart';
import 'package:saral_lekha/models/database_and_store.dart';
import 'package:saral_lekha/models/transaction/transaction.dart' as t;
import 'package:saral_lekha/services/account_service.dart';
import 'package:saral_lekha/services/budget_service.dart';
import 'package:saral_lekha/services/preference_service.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class TransactionService {
  TransactionService._();

  factory TransactionService() => TransactionService._();

  Future<DatabaseAndStore> getDatabaseAndStore() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database:
          await dbFactory.openDatabase(await _getDbPath('transaction.db')),
      store: intMapStoreFactory.store('transaction'),
    );
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future<List<int>> getTotalIncomeExpense(int year, int month) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals('year', year),
        Filter.equals('month', month),
      ]),
    );
    var snapshot = await dbStore.store.find(dbStore.database, finder: finder);
    if (snapshot.isEmpty) {
      return [0, 0];
    }
    List<t.Transaction> transactions =
        snapshot.map((record) => t.Transaction.fromJson(record.value)).toList();
    int income = 0;
    int expense = 0;
    transactions.forEach(
      (transaction) {
        if (transaction.transactionType == 0) {
          income += int.parse(transaction.amount);
        } else {
          expense += int.parse(transaction.amount);
        }
      },
    );
    return [income, expense];
  }

  Future<bool> isBudgetEditable(int categoryId, int month, int year) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals('year', year),
        Filter.equals('month', month),
        Filter.equals('categoryId', categoryId)
      ]),
    );
    var snapshot = await dbStore.store.find(dbStore.database, finder: finder);
    if ((snapshot?.length ?? 0) > 0) {
      return true;
    }
    return false;
  }

  Future<List<t.Transaction>> getTransactions(int year, int month) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.and([
        Filter.equals('year', year),
        Filter.equals('month', month),
      ]),
    );
    var snapshot = await dbStore.store.find(dbStore.database, finder: finder);
    return snapshot
        .map((record) => t.Transaction.fromJson(record.value))
        .toList();
  }

  /// Updates the transaction
  ///
  /// Adds new transaction record if record doesn't exist. Returns TransactionId.
  Future<int> updateTransaction(t.Transaction transaction) async {
    int transactionId;
    var dbStore = await getDatabaseAndStore();
    Filter checkRecord = Filter.equals(
      'id',
      transaction.id,
    );
    bool recordFound =
        (await dbStore.store.count(dbStore.database, filter: checkRecord)) != 0;
    if (recordFound) {
      await dbStore.store.update(dbStore.database, transaction.toJson(),
          finder: Finder(
            filter: checkRecord,
          ));
      transactionId = transaction.id;
    } else {
      int currentIndex =
          await PreferenceService.instance.getCurrentTransactionIndex();
      transactionId = currentIndex;
      await dbStore.store.add(
        dbStore.database,
        {
          'id': currentIndex,
          'categoryId': transaction.categoryId,
          'transactionType': transaction.transactionType,
          'name': transaction.name,
          'memo': transaction.memo,
          'amount': transaction.amount,
          'year': transaction.year,
          'month': transaction.month,
          'timestamp': transaction.timestamp,
        },
      );
      await PreferenceService.instance
          .setCurrentTransactionIndex(currentIndex + 1);
    }
    return transactionId;
  }

  Future deleteTransaction(t.Transaction transaction) async {
    var dbStore = await getDatabaseAndStore();
    Finder finder = Finder(
      filter: Filter.equals(
        'id',
        transaction.id,
      ),
    );
    Account _associatedAccount =
        await AccountService().getAccountForTransaction(transaction);
    _associatedAccount.transactionIds.remove(transaction.id);
    if (transaction.transactionType == 0) {
      int newBalance =
          int.parse(_associatedAccount.balance) - int.parse(transaction.amount);
      print(newBalance);
      await AccountService().updateAccount(
        Account(
          name: _associatedAccount.name,
          type: _associatedAccount.type,
          transactionIds: _associatedAccount.transactionIds,
          balance: '$newBalance',
        ),
      );
    } else {
      int newBalance =
          int.parse(_associatedAccount.balance) + int.parse(transaction.amount);
      print(newBalance);
      await AccountService().updateAccount(
        Account(
          name: _associatedAccount.name,
          type: _associatedAccount.type,
          transactionIds: _associatedAccount.transactionIds,
          balance: '$newBalance',
        ),
      );
    }
    if (transaction.transactionType == 1) {
      Budget budget = await BudgetService()
          .getBudget(transaction.categoryId, transaction.month);
      print(budget.spent);
      int newSpent = int.parse(budget.spent) - int.parse(transaction.amount);
      await BudgetService().updateBudget(
        Budget(
          categoryId: budget.categoryId,
          month: budget.month,
          spent: '$newSpent',
          total: budget.total,
        ),
      );
    }
    await dbStore.store.delete(dbStore.database, finder: finder);
  }

  Future deleteAllTransactionsForCategory(int categoryId) async {
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
