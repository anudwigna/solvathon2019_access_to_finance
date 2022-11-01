import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/config/routegenerator.dart';
import 'package:MunshiG/config/routes.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/screens/homepage.dart';
import 'package:MunshiG/screens/splashscreen.dart';
import 'package:MunshiG/services/preference_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
      create: ((context) => PreferenceProvider()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MunshiG',
        theme: themeData,
        routes: {
          '/': (context) => SplashScreen(),
          wrapper: (context) => WrapperPage(),
        },
      ),
    );
  }
}

final ThemeData themeData = ThemeData(
  fontFamily: 'SourceSansPro',
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    errorStyle: TextStyle(fontSize: 12.0, color: Colors.red),
  ),
  scaffoldBackgroundColor: Colors.transparent,
  canvasColor: Colors.white,
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.resolveWith(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      textStyle: MaterialStateProperty.resolveWith((states) => TextStyle(color: Colors.white)),
      backgroundColor: MaterialStateProperty.resolveWith((states) => Configuration().incomeColor),
    ),
  ),
  tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
    borderRadius: BorderRadius.circular(100),
    color: Configuration().incomeColor,
  )),
  buttonTheme: ButtonThemeData(
      minWidth: double.maxFinite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      buttonColor: Configuration().incomeColor,
      height: 55,
      textTheme: ButtonTextTheme.normal),
);

class WrapperPage extends StatefulWidget {
  @override
  _WrapperPageState createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SubSectorProvider>(
      create: ((context) => SubSectorProvider()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MunshiG',
        theme: themeData,
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
