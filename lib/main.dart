import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sampatti/providers/preference_provider.dart';
import 'package:sampatti/screens/account_page.dart';
import 'package:sampatti/screens/budget_page.dart';
import 'package:sampatti/screens/category_page.dart';
import 'package:sampatti/screens/homepage.dart';
import 'package:sampatti/screens/language_selection_page.dart';
import 'package:sampatti/screens/login_page.dart';
import 'package:sampatti/screens/splashscreen.dart';
import 'package:sampatti/screens/test_screen.dart';
import 'package:sampatti/services/preference_service.dart';

import 'globals.dart' as globals;

void main() async {
  //WidgetFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  globals.language = (await PreferenceService.instance.getLanguage()) ?? 'en';
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(Sampatti());
}

class Sampatti extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PreferenceProvider>(
      builder: (context) => PreferenceProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Finance Manager APP',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: MaterialColor(0xffffffff, {}),
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                color: Colors.transparent,
                elevation: 0,
              ),
          scaffoldBackgroundColor: Colors.transparent,
          canvasColor: Colors.transparent,
        ),
        routes: {
          '/': (context) => SplashScreen(),
          '/language': (context) => LanguageSelectionPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/category': (context) => CategoryPage(),
          '/budget': (context) => BudgetPage(),
          '/account': (context) => AccountPage(),
          //'/test': (context) => TestScreen()
        },
      ),
    );
  }
}
