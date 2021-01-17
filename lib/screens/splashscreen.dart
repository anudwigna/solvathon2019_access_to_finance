import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/config/routes.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:flutter/material.dart';
import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/config/globals.dart' as globals;
import 'package:MunshiG/screens/setting.dart';
import 'package:MunshiG/screens/userinfoRegistrationPage.dart';
import 'package:provider/provider.dart';
import '../config/resource_map.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/preference_service.dart';
import 'package:package_info/package_info.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    PreferenceService.instance.isUserRegistered().then((value) async {
      if (value) {
        PreferenceService.instance.getIsFirstStart().then(
          (isFirstStart) async {
            if (isFirstStart) {
              await Future.delayed(Duration(seconds: 2));
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Settings(
                        type: 0,
                      )));
            } else {
              globals.subSectors =
                  await PreferenceService.instance.getSubSectors();
              globals.selectedSubSector =
                  await PreferenceService.instance.getSelectedSubSector();
              globals.incomeCategories = await CategoryService().getCategories(
                  globals.selectedSubSector, CategoryType.INCOME);
              globals.expenseCategories = await CategoryService().getCategories(
                  globals.selectedSubSector, CategoryType.EXPENSE);
              await Future.delayed(Duration(seconds: 2));
              Navigator.pushReplacementNamed(context, wrapper);
            }
          },
        );
      } else {
        await Future.delayed(Duration(seconds: 1));
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LanguagePreferencePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenSizeConfig().init(context);
    return Scaffold(
      backgroundColor: const Color(0xff2b2f8e),
      body: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/splash.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: SizedBox(
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.hasData
                          ? 'Version' + ' ' + snapshot.data.version
                          : '',
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: const Color(0xffffffff),
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguagePreferencePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2b2f8e),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Choose Your Language',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              'भाषा छान्नुहोस्',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(
              height: 40,
            ),
            RaisedButton(
              elevation: 8,
              color: const Color(0xff2b2f8e),
              onPressed: () async {
                final preferenceProvider =
                    Provider.of<PreferenceProvider>(context, listen: false);
                preferenceProvider.language = Lang.NP;
                await PreferenceService.instance.setLanguage('np');
                globals.language = 'np';
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserInfoRegistrationPage()));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      'नेपाली',
                      style: TextStyle(fontSize: 16),
                    )),
                    Image.asset(
                      'assets/language/nepali.png',
                      height: 35,
                      width: 35,
                      fit: BoxFit.contain,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            RaisedButton(
              elevation: 8,
              color: const Color(0xff2b2f8e),
              onPressed: () async {
                await PreferenceService.instance.setLanguage('en');
                globals.language = 'en';
                final preferenceProvider =
                    Provider.of<PreferenceProvider>(context, listen: false);
                preferenceProvider.language = Lang.EN;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserInfoRegistrationPage()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      'English',
                      style: TextStyle(fontSize: 16),
                    )),
                    Image.asset(
                      'assets/language/english.png',
                      height: 45,
                      width: 35,
                      fit: BoxFit.contain,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
