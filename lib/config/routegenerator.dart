import 'package:MunshiG/config/routes.dart';
import 'package:MunshiG/main.dart';
import 'package:MunshiG/screens/account_page.dart';
import 'package:MunshiG/screens/budget_page.dart';
import 'package:MunshiG/screens/category_page.dart';
import 'package:MunshiG/screens/homepage.dart';
import 'package:MunshiG/screens/one.dart';
import 'package:MunshiG/screens/report_page.dart';
import 'package:MunshiG/screens/setting.dart';
import 'package:MunshiG/screens/userProfilepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  WidgetBuilder builder;
  switch (settings.name) {
    case '/':
      {
        builder = (BuildContext _) => HomePage();
        break;
      }
    case home:
      {
        builder = (BuildContext _) => HomePage();
        break;
      }
    case profilePage:
      {
        builder = (BuildContext _) => UserProfilePage();
        break;
      }
    case category:
      {
        builder = (BuildContext _) => CategoryPage();
        break;
      }
    case backup:
      {
        builder = (BuildContext _) => BackUpAndRestore();
        break;
      }
    case budget:
      {
        builder = (BuildContext _) => BudgetPage(
              isInflowProjection: settings.arguments,
            );
        break;
      }
    case account:
      {
        builder = (BuildContext _) => AccountPage();
        break;
      }
    case report:
      {
        builder = (BuildContext _) => ReportPage(
              selectedSubSector: settings.arguments,
            );
        break;
      }
    case wrapper:
      {
        builder = (BuildContext _) => WrapperPage();
        break;
      }
    case setting:
      {
        builder = (BuildContext _) => Settings(
              type: settings.arguments,
            );
        break;
      }
    default:
      {
        builder = (BuildContext _) => HomePage();
        break;
      }
  }
  return MaterialPageRoute(builder: builder, settings: settings);
}
