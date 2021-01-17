import 'dart:convert';

import 'package:MunshiG/services/app_page.dart';
import 'package:flutter/services.dart';

import '../services/category_service.dart';
import '../services/preference_service.dart';
import 'category_heading_service.dart';
import '../models/category/category.dart';

class VersionChanges {
  Future<void> v102Changes() async {
    final isTrue = await PreferenceService.instance.getV102ChangesFlag();
    if (isTrue) return;
    await Future.wait([
      _changeNepaliText(),
      CategoryHeadingService().getStockCategoryHeading(),
      _changeExpenseCategoryNames(),
      _loadv102Categories(),
      _loadv102appPages(),
    ]).then((value) async {
      print('done v102 chages');
      await PreferenceService.instance.setV102ChangesFlag();
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<void> _changeNepaliText() async {
    await Future.wait([
      CategoryService().changeNepaliCategoryName('Sales of goat fur',
          'बाख्राको उनको बिक्रि', 'goat', CategoryType.INCOME),
      CategoryService().changeNepaliCategoryName('Sales of goat manure',
          'बाख्राको मलको बिक्रि', 'goat', CategoryType.INCOME),
      CategoryService().changeNepaliCategoryName(
          'Sales of manure', 'सुली मलको बिक्रि', 'poultry', CategoryType.INCOME)
    ]);
  }

  Future<void> _changeExpenseCategoryNames() async {
    await Future.wait([
      CategoryService().changeCategoryName('Capital Investment',
          'Capital Expenditure', 'goat', CategoryType.EXPENSE,
          nepaliCatgeoryName: 'पूंजीगत व्यय'),
      CategoryService().changeCategoryName('Capital Investment',
          'Capital Expenditure', 'poultry', CategoryType.EXPENSE,
          nepaliCatgeoryName: 'पूंजीगत व्यय'),
      CategoryService().changeCategoryName('Capital Investment',
          'Capital Expenditure', 'vegetable', CategoryType.EXPENSE,
          nepaliCatgeoryName: 'पूंजीगत व्यय'),
    ]);
  }

  Future<void> _loadv102Categories() async {
    List<String> subSectorList = ['goat', 'poultry', 'vegetable', 'seed'];
    dynamic data =
        jsonDecode(await rootBundle.loadString('assets/v102NewCategory.json'));

    dynamic sourceInfo = data['categories'];
    for (int i = 0; i < subSectorList.length; i++) {
      final String _subSector = subSectorList[i];
      //individual subsectorsData
      dynamic subSectorsData = sourceInfo[_subSector];
      final List<dynamic> incomeCategories = subSectorsData['income'];
      for (int j = 0; j < incomeCategories.length; j++) {
        final incomeCategory = incomeCategories[j];
        await CategoryService().addUpdatedCategoryIfNotExists(
            _subSector,
            Category(
              categoryHeadingId: incomeCategory['categoryHeadingId'],
              en: incomeCategory['en'],
              np: incomeCategory['np'],
              iconName: 'hornbill',
            ),
            type: CategoryType.INCOME,
            isStockCategory: false);
      }
    }
  }

  Future<void> _loadv102appPages() async {
    dynamic data =
        jsonDecode(await rootBundle.loadString('assets/v102appPage.json'));
    for (int i = 0; i < data.length; i++) {
      final pageData = data[i];
      //individual subsectorsData
      await AppPage().addPages(pageData['id'], pageData['name']);
    }
  }
}
