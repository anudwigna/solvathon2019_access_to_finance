import 'package:flutter/material.dart';
import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/globals.dart' as globals;
import 'package:MunshiG/screens/setting.dart';
import 'package:MunshiG/screens/userinfoRegistrationPage.dart';

import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/preference_service.dart';

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
              Navigator.pushReplacementNamed(context, '/wrapper');
            }
          },
        );
      } else {
        await PreferenceService.instance.setLanguage('en');
        globals.language = 'en';
        await Future.delayed(Duration(seconds: 2));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => UserInfoRegistrationPage()));
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
                child: Text(
                  'Version 1.0',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: const Color(0xffffffff),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
