import 'package:MunshiG/config/routegenerator.dart';
import 'package:MunshiG/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/screens/homepage.dart';
import 'package:MunshiG/screens/splashscreen.dart';
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
  fontFamily: 'Poppins',
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
  buttonColor: Configuration().incomeColor,
  tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    color: Configuration().incomeColor,
  )),
  buttonTheme: ButtonThemeData(
      minWidth: double.maxFinite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      buttonColor: Configuration().incomeColor,
      height: 52,
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
      builder: (context) => SubSectorProvider(),
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
