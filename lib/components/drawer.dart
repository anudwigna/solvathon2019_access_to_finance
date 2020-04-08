import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saral_lekha/globals.dart' as globals;
import 'package:saral_lekha/providers/preference_provider.dart';
import 'package:saral_lekha/services/preference_service.dart';

import '../configuration.dart';
import 'adaptive_text.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var preferenceProvider = Provider.of<PreferenceProvider>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Configuration().gradientColors,
          begin: FractionalOffset.bottomRight,
          end: FractionalOffset.topLeft,
        ),
      ),
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Image.asset(
            "assets/saral_lekha_logo.png",
            fit: BoxFit.contain,
            height: 200,
          ),
          Configuration().drawerItemDivider,
          ListTile(
            leading: Icon(Icons.dashboard),
            title: AdaptiveText(
              'Dashboard',
              style: Configuration().whiteText,
            ),
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              ModalRoute.withName('/home'),
            ),
          ),
          Configuration().drawerItemDivider,
          ListTile(
            leading: Icon(Icons.category),
            title: AdaptiveText(
              'Categories',
              style: Configuration().whiteText,
            ),
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/category',
              ModalRoute.withName('/home'),
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.category),
          //   title: Text('Test Page'),
          //   onTap: () => Navigator.pushNamedAndRemoveUntil(
          //         context,
          //         '/test',
          //         ModalRoute.withName('/test'),
          //       ),
          // ),
          ListTile(
            leading: Icon(Icons.card_travel),
            title: AdaptiveText(
              'Budget',
              style: Configuration().whiteText,
            ),
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/budget',
              ModalRoute.withName('/home'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: AdaptiveText(
              'Accounts',
              style: Configuration().whiteText,
            ),
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/account',
              ModalRoute.withName('/home'),
            ),
          ),
          Configuration().drawerItemDivider,
          ListTile(
            leading: Icon(Icons.language),
            title: AdaptiveText(
              'Nepali Language',
              style: Configuration().whiteText,
            ),
            trailing: Switch(
              value: preferenceProvider.language == Lang.NP ? true : false,
              activeColor: Colors.white,
              onChanged: (nepaliSelected) {
                if (nepaliSelected) {
                  PreferenceService.instance.setLanguage('np');
                  globals.language = 'np';
                  preferenceProvider.language = Lang.NP;
                } else {
                  PreferenceService.instance.setLanguage('en');
                  globals.language = 'en';
                  preferenceProvider.language = Lang.EN;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
