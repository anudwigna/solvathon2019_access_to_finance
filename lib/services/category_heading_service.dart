import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MunshiG/models/database_and_store.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import '../models/categoryHeading/categoryHeading.dart';
import 'category_service.dart';

class CategoryHeadingService {
  CategoryHeadingService._();

  factory CategoryHeadingService() => CategoryHeadingService._();

  Future<DatabaseAndStore> getDatabaseAndStore(CategoryType type) async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    return DatabaseAndStore(
      database: await dbFactory.openDatabase(await _getDbPath('categoryHeading.db')),
      store: intMapStoreFactory.store(type == CategoryType.INCOME ? 'in_categoryHeading' : 'ex_categoryHeading'),
    );
  }

  Future<List<CategoryHeading>> getAllCategoryHeadings(CategoryType type) async {
    var dbStore = await getDatabaseAndStore(type);
    List<RecordSnapshot<int?, Map<String, dynamic>>> snapshot = await dbStore.store!.find(dbStore.database);
    return snapshot.map((record) => CategoryHeading.fromJson(record.value)).toList();
  }

  Future<CategoryHeading?> getCategoryHeadingById(CategoryType type, int? id) async {
    var dbStore = await getDatabaseAndStore(type);
    Finder finder = Finder(filter: Filter.equals('id', id));
    RecordSnapshot<int?, Map<String, dynamic>>? snapshot = await dbStore.store!.findFirst(dbStore.database, finder: finder);

    if (snapshot == null) return null;
    return CategoryHeading.fromJson(snapshot.value);
  }

  Future<String> _getDbPath(String dbName) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    return join(appDocumentDir.path, dbName);
  }

  // Future<Category> getCategoryById(String subSector, int id, int type) async {
  //   var dbStore = await getDatabaseAndStore(
  //       subSector, type == 0 ? CategoryType.INCOME : CategoryType.EXPENSE);
  //   Finder finder = Finder(filter: Filter.equals('id', id));
  //   var snapshot = await dbStore.store.find(dbStore.database, finder: finder);
  //   if (snapshot.length == 0) {
  //     return Category();
  //   }
  //   return Category.fromJson(snapshot[0].value);
  // }

  // Future addCategory(CategoryHeading category,
  //     {@required CategoryType type, bool isStockCategory = false}) async {
  //   var dbStore = await getDatabaseAndStore();
  //   // int currentIndex = type == CategoryType.EXPENSE
  //   //     ? await PreferenceService.instance.getCurrentExpenseCategoryIndex()
  //   //     : await PreferenceService.instance.getCurrentIncomeCategoryIndex();
  //   await dbStore.store.add(dbStore.database, {
  //     'id': isStockCategory ? category.id : category.id,
  //     'en': category.en,
  //     'np': category.np,
  //     'iconName': category.iconName,
  //   });
  //   // type == CategoryType.EXPENSE
  //   //     ?
  //   //  globals.categoryHeading.add(category)
  //   // :
  //   globals.categoryHeading.add(category);
  //   // type == CategoryType.EXPENSE
  //   //     ? await PreferenceService.instance
  //   //         .setCurrentExpenseCategoryIndex(currentIndex + 1)
  //   //     : await PreferenceService.instance
  //   //         .setCurrentIncomeCategoryIndex(currentIndex + 1);
  // }

  // Future deleteCategory(
  //     String subSector, int categoryId, CategoryType type) async {
  //   var dbStore = await getDatabaseAndStore(subSector, type);
  //   Finder finder = Finder(filter: Filter.equals('id', categoryId));
  //   await TransactionService()
  //       .deleteAllTransactionsForCategory(subSector, categoryId);
  //   await BudgetService().deleteBudgetsForCategory(subSector, categoryId);
  //   await dbStore.store.delete(dbStore.database, finder: finder);
  //   if (type == CategoryType.EXPENSE) {
  //     globals.expenseCategories = await getCategories(subSector, type);
  //   } else {
  //     globals.incomeCategories = await getCategories(subSector, type);
  //   }
  // }

  // Future refreshCategories(String subSector, List<Category> categories,
  //     {@required CategoryType type}) async {
  //   var dbStore = await getDatabaseAndStore(subSector, type);
  //   await dbStore.store.delete(dbStore.database);
  //   categories.forEach(
  //     (category) async {
  //       await dbStore.store.add(dbStore.database, category.toJson());
  //     },
  //   );
  // }

  Future<void> getStockCategoryHeading() async {
    //Reading categoryHeading.json file using assetBundle
    dynamic categories = jsonDecode(await rootBundle.loadString('assets/categoryHeading.json'));
    List<dynamic> _incomeCategoriesheading = categories['income'];
    List<dynamic> _expenseCategoriesheading = categories['expense'];
    final incomeCategoryHeadings = _incomeCategoriesheading
        .map(
          (category) => CategoryHeading.fromJson(category),
        )
        .toList();
    final expenseCategoryHeadings = _expenseCategoriesheading
        .map(
          (category) => CategoryHeading.fromJson(category),
        )
        .toList();
    var dbStore = await getDatabaseAndStore(CategoryType.INCOME);
    incomeCategoryHeadings.forEach(
      (category) async {
        await dbStore.store!.record(category.id).put(
              dbStore.database,
              category.toJson(),
            );
      },
    );
    dbStore = await getDatabaseAndStore(CategoryType.EXPENSE);
    expenseCategoryHeadings.forEach(
      (category) async {
        await dbStore.store!.record(category.id).put(
              dbStore.database,
              category.toJson(),
            );
      },
    );
  }

  Future<void> closeDatabase(String subsector) async {
    final db = await getDatabaseAndStore(CategoryType.INCOME);
    await db.database.close();
  }
}
