import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MunshiG/config/globals.dart' as globals;
import 'package:MunshiG/models/category/category.dart';
import 'package:MunshiG/models/database_and_store.dart';
import 'package:MunshiG/services/budget_service.dart';
import 'package:MunshiG/services/preference_service.dart';
import 'package:MunshiG/services/transaction_service.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import '../services/activity_tracking.dart';
import '../models/app_page_naming.dart';

enum CategoryType { INCOME, EXPENSE }

class CategoryService {
  CategoryService._();

  factory CategoryService() => CategoryService._();

  Future<DatabaseAndStore> getDatabaseAndStore(String subSector, CategoryType type) async {
    DatabaseFactory dbFactory = databaseFactoryIo;

    return DatabaseAndStore(
      database: await dbFactory.openDatabase(await _getDbPath('${subSector.toLowerCase()}Categories.db')),
      store: intMapStoreFactory.store(type == CategoryType.INCOME ? 'in_categories' : 'ex_categories'),
    );
  }

  Future<List<Category>> getCategories(String subSector, CategoryType type) async {
    var dbStore = await getDatabaseAndStore(subSector, type);
    List<RecordSnapshot<int?, Map<String, dynamic>>> snapshot = await dbStore.store!.find(dbStore.database!);
    return snapshot.map((record) => Category.fromJson(record.value)).toList();
  }

  Future<List<int>> getCategoriesID(String subSector, CategoryType type) async {
    var dbStore = await getDatabaseAndStore(subSector, type);
    List<RecordSnapshot<int?, Map<String, dynamic>>> snapshot = await dbStore.store!.find(dbStore.database!);
    return snapshot.map((record) => int.tryParse(record.value['id']?.toString() ?? '') ?? 0).toList();
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  Future<Category> getCategoryById(String subSector, int? id, int? type) async {
    var dbStore = await getDatabaseAndStore(subSector, type == 0 ? CategoryType.INCOME : CategoryType.EXPENSE);
    Finder finder = Finder(filter: Filter.equals('id', id));
    List<RecordSnapshot<int?, Map<String, dynamic>>> snapshot = await dbStore.store!.find(dbStore.database!, finder: finder);
    if (snapshot.length == 0) {
      return Category();
    }
    return Category.fromJson(snapshot[0].value);
  }

  Future addCategory(String subSector, Category category, {required CategoryType type, bool isStockCategory = false}) async {
    var dbStore = await getDatabaseAndStore(subSector, type);
    int currentIndex = type == CategoryType.EXPENSE ? await PreferenceService.instance.getCurrentExpenseCategoryIndex() : await PreferenceService.instance.getCurrentIncomeCategoryIndex();
    await dbStore.store!.add(dbStore.database!, {
      'id': isStockCategory ? category.id : currentIndex,
      'en': category.en,
      'np': category.np,
      'categoryHeadingId': category.categoryHeadingId,
      'iconName': category.iconName,
    });
    type == CategoryType.EXPENSE ? globals.expenseCategories!.add(category) : globals.incomeCategories!.add(category);
    type == CategoryType.EXPENSE ? await PreferenceService.instance.setCurrentExpenseCategoryIndex(currentIndex + 1) : await PreferenceService.instance.setCurrentIncomeCategoryIndex(currentIndex + 1);
  }

  Future deleteCategory(String subSector, int? categoryId, CategoryType type, bool isAutomated) async {
    var dbStore = await getDatabaseAndStore(subSector, type);
    Finder finder = Finder(filter: Filter.equals('id', categoryId));
    await TransactionService().deleteAllTransactionsForCategory(subSector, categoryId);
    await BudgetService().deleteBudgetsForCategory(subSector, categoryId);
    int v = await dbStore.store!.delete(dbStore.database!, finder: finder);
    if (type == CategoryType.EXPENSE) {
      globals.expenseCategories = await getCategories(subSector, type);
    } else {
      globals.incomeCategories = await getCategories(subSector, type);
    }
    if (!(isAutomated)) ActivityTracker().otherActivityOnPage(PageName.categories, 'Delete ${type.toString()} Category For $subSector', 'Delete', 'FlatButton');
  }

  Future refreshCategories(String subSector, List<Category> categories, {required CategoryType type}) async {
    var dbStore = await getDatabaseAndStore(subSector, type);
    await dbStore.store!.delete(dbStore.database!);
    categories.forEach(
      (category) async {
        await dbStore.store!.add(dbStore.database!, category.toJson());
      },
    );
  }

  Future<List<Category>> getStockCategories(String subSector, CategoryType type) async {
    //Reading categories.json file using assetBundle
    dynamic categories = jsonDecode(await rootBundle.loadString('assets/${subSector.toLowerCase()}Categories.json'));
    List<dynamic> _categories = categories[type == CategoryType.INCOME ? 'income' : 'expense'];
    return _categories
        .map(
          (category) => Category.fromJson(category),
        )
        .toList();
  }

  Future<void> changeNepaliCategoryName(String oldCategoryName, String nepaliCatgeoryName, String subSector, CategoryType type) async {
    var dbStore = await getDatabaseAndStore(subSector, type);
    Finder finder = Finder(filter: Filter.equals('en', oldCategoryName));
    RecordSnapshot<int?, Map<String, dynamic>>? snapshot = await dbStore.store!.findFirst(dbStore.database!, finder: finder);
    if (snapshot == null) return;
    final Category categoryService =
        Category(id: snapshot.value['id'], en: snapshot.value['en'], categoryHeadingId: snapshot.value['categoryHeadingId'], iconName: snapshot.value['iconName'], np: nepaliCatgeoryName);
    await dbStore.store!.update(dbStore.database!, categoryService.toJson(), finder: finder);
    await dbStore.store!.findFirst(dbStore.database!, finder: finder);
  }

  Future addUpdatedCategoryIfNotExists(String subSector, Category category, {required CategoryType type, bool isStockCategory = false}) async {
    var dbStore = await getDatabaseAndStore(subSector, type);
    int isDatabasePopulated = (await dbStore.store!.find(dbStore.database!)).length;
    if (isDatabasePopulated < 1) {
      print('database not poulated $subSector' + category.en!);
      return;
    }
    print('database populated $subSector');
    int currentIndex = type == CategoryType.EXPENSE ? await PreferenceService.instance.getCurrentExpenseCategoryIndex() : await PreferenceService.instance.getCurrentIncomeCategoryIndex();

    Filter filter = Filter.and([
      Filter.equals('categoryHeadingId', category.categoryHeadingId),
      Filter.equals('en', category.en),
      Filter.equals('np', category.np),
    ]);
    final checkExists = await dbStore.store!.count(dbStore.database!, filter: filter);
    if (checkExists > 0) return;
    await dbStore.store!.add(dbStore.database!, {
      'id': isStockCategory ? category.id : currentIndex,
      'en': category.en,
      'np': category.np,
      'categoryHeadingId': category.categoryHeadingId,
      'iconName': category.iconName,
    });
    type == CategoryType.EXPENSE ? globals.expenseCategories!.add(category) : globals.incomeCategories!.add(category);
    type == CategoryType.EXPENSE ? await PreferenceService.instance.setCurrentExpenseCategoryIndex(currentIndex + 1) : await PreferenceService.instance.setCurrentIncomeCategoryIndex(currentIndex + 1);
  }

  Future<void> changeCategoryName(
    String oldCategoryName,
    String newCategoryName,
    String subSector,
    CategoryType type, {
    String? nepaliCatgeoryName,
  }) async {
    var dbStore = await getDatabaseAndStore(subSector, type);
    Finder finder = Finder(filter: Filter.equals('en', oldCategoryName));
    RecordSnapshot<int?, Map<String, dynamic>>? snapshot = await dbStore.store!.findFirst(dbStore.database!, finder: finder);
    if (snapshot == null) return;
    final Category categoryService = Category(
        id: snapshot.value['id'], en: newCategoryName, categoryHeadingId: snapshot.value['categoryHeadingId'], iconName: snapshot.value['iconName'], np: nepaliCatgeoryName ?? snapshot.value['np']);
    await dbStore.store!.update(dbStore.database!, categoryService.toJson(), finder: finder);
    await dbStore.store!.findFirst(dbStore.database!, finder: finder);
  }

  Future<void> closeDatabase(String subsector) async {
    final db = await getDatabaseAndStore(subsector, CategoryType.INCOME);
    await db.database!.close();
  }
}
