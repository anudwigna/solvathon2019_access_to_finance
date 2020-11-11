import 'package:MunshiG/config/routegenerator.dart';
import 'package:MunshiG/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/screens/account_page.dart';
import 'package:MunshiG/screens/budget_page.dart';
import 'package:MunshiG/screens/category_page.dart';
import 'package:MunshiG/screens/homepage.dart';

import 'package:MunshiG/screens/splashscreen.dart';
import 'package:MunshiG/screens/userProfilepage.dart';
import 'package:MunshiG/services/preference_service.dart';

import 'config/globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  globals.language = (await PreferenceService.instance.getLanguage()) ?? 'en';
  //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MunshiG());
}

class MunshiG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PreferenceProvider>(
      builder: (context) => PreferenceProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MunshiG',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: MaterialColor(0xffffffff, {}),
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                color: Colors.transparent,
                elevation: 0,
              ),
          scaffoldBackgroundColor: Colors.transparent,
          canvasColor: Colors.white,
        ),
        routes: {
          '/': (context) => SplashScreen(),
          wrapper: (context) => WrapperPage(),
        },
      ),
    );
  }
}

class WrapperPage extends StatefulWidget {
  @override
  _WrapperPageState createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SubSectorProvider>(
      builder: (context) => SubSectorProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MunshiG',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: MaterialColor(0xffffffff, {}),
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                color: Colors.transparent,
                elevation: 0,
              ),
          scaffoldBackgroundColor: Colors.transparent,
          canvasColor: Configuration().appColor,
        ),
        onGenerateRoute: onGenerateRoute,
        routes: {
          '/': (context) => HomePage(),
          //   '/profilepage': (context) => UserProfilePage(),
          //   '/home': (context) => HomePage(),
          //   '/category': (context) => CategoryPage(),
          //   '/budget': (context) => BudgetPage(),
          //   '/account': (context) => AccountPage(),
          //   '/wrapper': (context) => WrapperPage(),
        },
      ),
    );
  }
}
