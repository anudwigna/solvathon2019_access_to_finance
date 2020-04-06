import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saral_lekha/providers/preference_provider.dart';
import 'package:saral_lekha/screens/account_page.dart';
import 'package:saral_lekha/screens/budget_page.dart';
import 'package:saral_lekha/screens/category_page.dart';
import 'package:saral_lekha/screens/homepage.dart';
import 'package:saral_lekha/screens/language_selection_page.dart';
import 'package:saral_lekha/screens/login_page.dart';
import 'package:saral_lekha/screens/splashscreen.dart';
import 'package:saral_lekha/services/preference_service.dart';

import 'globals.dart' as globals;

void main() async {
  //WidgetFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  globals.language = (await PreferenceService.instance.getLanguage()) ?? 'en';
  //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(Sarallekha());
}

class Sarallekha extends StatelessWidget {
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
