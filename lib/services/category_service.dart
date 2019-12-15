import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sampatti/globals.dart' as globals;
import 'package:sampatti/models/category/category.dart';
import 'package:sampatti/models/database_and_store.dart';
import 'package:sampatti/services/budget_service.dart';
import 'package:sampatti/services/preference_service.dart';
import 'package:sampatti/services/transaction_service.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

enum CategoryType { INCOME, EXPENSE }

class CategoryService {
  CategoryService._();

  factory CategoryService() => CategoryService._();

  Future<DatabaseAndStore> getDatabaseAndStore(CategoryType type) async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database: await dbFactory.openDatabase(await _getDbPath('categories.db')),
      store: intMapStoreFactory.store(
          type == CategoryType.INCOME ? 'in_categories' : 'ex_categories'),
    );
  }

  Future<List<Category>> getCategories(CategoryType type) async {
    var dbStore = await getDatabaseAndStore(type);
    var snapshot = await dbStore.store.find(dbStore.database);
    return snapshot.map((record) => Category.fromJson(record.value)).toList();
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future<Category> getCategoryById(int id, int type) async {
    var dbStore = await getDatabaseAndStore(
        type == 0 ? CategoryType.INCOME : CategoryType.EXPENSE);
    Finder finder = Finder(filter: Filter.equals('id', id));
    var snapshot = await dbStore.store.find(dbStore.database, finder: finder);
    if (snapshot.length == 0) {
      return Category();
    }
    return Category.fromJson(snapshot[0].value);
  }

  Future addCategory(Category category,
      {@required CategoryType type, bool isStockCategory = false}) async {
    var dbStore = await getDatabaseAndStore(type);
    int currentIndex = type == CategoryType.EXPENSE
        ? await PreferenceService.instance.getCurrentExpenseCategoryIndex()
        : await PreferenceService.instance.getCurrentIncomeCategoryIndex();
    await dbStore.store.add(dbStore.database, {
      'id': isStockCategory ? category.id : currentIndex,
      'en': category.en,
      'np': category.np,
      'iconName': category.iconName,
    });
    type == CategoryType.EXPENSE
        ? globals.expenseCategories.add(category)
        : globals.incomeCategories.add(category);
    type == CategoryType.EXPENSE
        ? await PreferenceService.instance
            .setCurrentExpenseCategoryIndex(currentIndex + 1)
        : await PreferenceService.instance
            .setCurrentIncomeCategoryIndex(currentIndex + 1);
  }

  Future deleteCategory(int categoryId, CategoryType type) async {
    var dbStore = await getDatabaseAndStore(type);
    Finder finder = Finder(filter: Filter.equals('id', categoryId));
    await TransactionService().deleteAllTransactionsForCategory(categoryId);
    await BudgetService().deleteBudgetsForCategory(categoryId);
    await dbStore.store.delete(dbStore.database, finder: finder);
    if (type == CategoryType.EXPENSE) {
      globals.expenseCategories = await getCategories(type);
    } else {
      globals.incomeCategories = await getCategories(type);
    }
  }

  Future refreshCategories(List<Category> categories,
      {@required CategoryType type}) async {
    var dbStore = await getDatabaseAndStore(type);
    await dbStore.store.delete(dbStore.database);
    categories.forEach(
      (category) async {
        await dbStore.store.add(dbStore.database, category.toJson());
      },
    );
  }

  Future<List<Category>> getStockCategories(CategoryType type) async {
    //Reading categories.json file using assetBundle
    dynamic categories =
        jsonDecode(await rootBundle.loadString('assets/categories.json'));
    List<dynamic> _categories =
        categories[type == CategoryType.INCOME ? 'income' : 'expense'];
    return _categories
        .map(
          (category) => Category.fromJson(category),
        )
        .toList();
  }
}
