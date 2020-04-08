import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saral_lekha/globals.dart' as globals;
import 'package:saral_lekha/models/account/account.dart';
import 'package:saral_lekha/providers/preference_provider.dart';
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
          await _loadCategories();
          await PreferenceService.instance.setLanguage('en');
          Provider.of<PreferenceProvider>(context).language = Lang.EN;
          PreferenceService.instance.setIsFirstStart(false);
          await Future.delayed(Duration(seconds: 2));
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          globals.incomeCategories =
              await CategoryService().getCategories(CategoryType.INCOME);
          globals.expenseCategories =
              await CategoryService().getCategories(CategoryType.EXPENSE);
          await Future.delayed(Duration(seconds: 2));
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
    );
  }

  // Loads categories from json file, first time the app is installed
  _loadCategories() async {
    //Reading categories.json file using assetBundle
    dynamic categories =
        jsonDecode(await rootBundle.loadString('assets/categories.json'));

    var incomeDbStore =
        await CategoryService().getDatabaseAndStore(CategoryType.INCOME);
    var expenseDbStore =
        await CategoryService().getDatabaseAndStore(CategoryType.EXPENSE);

    var _incomeCategories =
        await CategoryService().getStockCategories(CategoryType.INCOME);
    var _expenseCategories =
        await CategoryService().getStockCategories(CategoryType.EXPENSE);

    _incomeCategories.forEach(
      (category) async {
        await incomeDbStore.store.record(category.id).put(
              incomeDbStore.database,
              category.toJson(),
            );
      },
    );

    _expenseCategories.forEach(
      (category) async {
        await expenseDbStore.store.record(category.id).put(
              expenseDbStore.database,
              category.toJson(),
            );
      },
    );

    Future.delayed(Duration(seconds: 1), () async {
      globals.incomeCategories =
          await CategoryService().getCategories(CategoryType.INCOME);
      globals.expenseCategories =
          await CategoryService().getCategories(CategoryType.EXPENSE);
    });

    await PreferenceService.instance.setCurrentIncomeCategoryIndex(1000);
    await PreferenceService.instance.setCurrentExpenseCategoryIndex(10000);
    await PreferenceService.instance.setCurrentTransactionIndex(1);

    await AccountService().addAccount(
      Account(
        name: 'Cash',
        type: 2,
        balance: '0',
        transactionIds: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff263547),
      child: Center(
          child: Image.asset("assets/saral_lekha_logo.png", fit: BoxFit.cover)),
    );
  }
}
