import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saral_lekha/globals.dart' as globals;
import 'package:saral_lekha/main.dart';
import 'package:saral_lekha/models/account/account.dart';
import 'package:saral_lekha/providers/preference_provider.dart';
import 'package:saral_lekha/screens/homepage.dart';
import 'package:saral_lekha/screens/setting.dart';
import 'package:saral_lekha/services/account_service.dart';
import 'package:saral_lekha/services/category_service.dart';
import 'package:saral_lekha/services/preference_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    PreferenceService.instance.getIsFirstStart().then(
      (isFirstStart) async {
        if (isFirstStart) {
          //  await _loadCategories();
          await PreferenceService.instance.setLanguage('en');
          globals.language = 'en';
          //  PreferenceService.instance.setIsFirstStart(false);
          //    await PreferenceService.instance.setSelectedSubSector('Goat');
        await  Future.delayed(Duration(seconds:2));
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Settings(
                    type: 0,
                  )));
        } else {
          globals.subSectors = await PreferenceService.instance.getSubSectors();
          globals.selectedSubSector =
              await PreferenceService.instance.getSelectedSubSector();
          globals.incomeCategories = await CategoryService()
              .getCategories(globals.selectedSubSector, CategoryType.INCOME);
          globals.expenseCategories = await CategoryService()
              .getCategories(globals.selectedSubSector, CategoryType.EXPENSE);
             await  Future.delayed(Duration(seconds:2));
          Navigator.pushReplacementNamed(context, '/wrapper');
        }
      },
    );
  }

  // Loads categories from json file, first time the app is installed
  // _loadCategories() async {
  //   dynamic categories =
  //       jsonDecode(await rootBundle.loadString('assets/subsector.json'));
  //   List<dynamic> _subSectors = categories['subSectors'];
  //   for (String _subSector in _subSectors) {
  //     globals.selectedSubSector = _subSector;
  //     var incomeDbStore = await CategoryService()
  //         .getDatabaseAndStore(_subSector, CategoryType.INCOME);
  //     var expenseDbStore = await CategoryService()
  //         .getDatabaseAndStore(_subSector, CategoryType.EXPENSE);

  //     var _incomeCategories = await CategoryService()
  //         .getStockCategories(_subSector, CategoryType.INCOME);
  //     var _expenseCategories = await CategoryService()
  //         .getStockCategories(_subSector, CategoryType.EXPENSE);

  //     _incomeCategories.forEach(
  //       (category) async {
  //         await incomeDbStore.store.record(category.id).put(
  //               incomeDbStore.database,
  //               category.toJson(),
  //             );
  //       },
  //     );

  //     _expenseCategories.forEach(
  //       (category) async {
  //         await expenseDbStore.store.record(category.id).put(
  //               expenseDbStore.database,
  //               category.toJson(),
  //             );
  //       },
  //     );
  //   }
  //   await PreferenceService.instance.setCurrentIncomeCategoryIndex(1000);
  //   await PreferenceService.instance.setCurrentExpenseCategoryIndex(10000);
  //   await PreferenceService.instance.setCurrentTransactionIndex(1);

  //   await AccountService().addAccount(
  //     Account(
  //       name: 'Cash',
  //       type: 2,
  //       balance: '0',
  //       transactionIds: [],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff263547),
      child: Center(
          child: Image.asset("assets/saral_lekha_logo.png", fit: BoxFit.cover)),
    );
  }
}
