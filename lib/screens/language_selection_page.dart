import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/preference_service.dart';
import 'package:MunshiG/components/adaptive_text.dart';

import '../configuration.dart';

class LanguageSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Configuration().gradientDecoration,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(flex: 3, child: Container()),
            Image.asset(
              'assets/MunshiG_logo.png',
              height: 150.0,
              width: 150.0,
            ),
            SizedBox(height: 10.0),
            AdaptiveText(
              'MunshiG',
              style: TextStyle(
                fontWeight: FontWeight.w100,
                fontSize: 30.0,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            Flexible(flex: 2, child: Container()),
            Text(
              'Select Your Preferred Language',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            Flexible(flex: 1, child: Container()),
            Text(
              'ABC 123',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.w200,
              ),
              textAlign: TextAlign.center,
            ),
            Flexible(flex: 1, child: Container()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: MaterialButton(
                splashColor: Configuration().appColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                color: Colors.white,
                child: Text(
                  'ENGLISH',
                  style: TextStyle(
                    color: Configuration().redColor,
                  ),
                ),
                onPressed: () async {
                  await PreferenceService.instance.setLanguage('en');
                  Provider.of<PreferenceProvider>(context).language = Lang.EN;
                  PreferenceService.instance.setIsFirstStart(false);
                  _navigateToHome(context);
                },
              ),
            ),
            Flexible(flex: 2, child: Container()),
            Text(
              'तपाईंले इच्छाएको भाषा छनोट गर्नुहोस',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            Flexible(flex: 1, child: Container()),
            Text(
              'कखग १२३',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.w200,
              ),
              textAlign: TextAlign.center,
            ),
            Flexible(flex: 1, child: Container()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: MaterialButton(
                splashColor: Configuration().appColor,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                child: Text(
                  'नेपाली',
                  style: TextStyle(
                    color: Configuration().redColor,
                  ),
                ),
                onPressed: () async {
                  await PreferenceService.instance.setLanguage('np');
                  Provider.of<PreferenceProvider>(context).language = Lang.NP;
                  PreferenceService.instance.setIsFirstStart(false);
                  _navigateToHome(context);
                },
              ),
            ),
            Flexible(flex: 2, child: Container()),
          ],
        ),
      ),
    );
  }

  _navigateToHome(BuildContext context) =>
      Navigator.pushReplacementNamed(context, '/home');
}
