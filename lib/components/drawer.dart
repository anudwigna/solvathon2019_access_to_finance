import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saral_lekha/globals.dart' as globals;
import 'package:saral_lekha/providers/preference_provider.dart';
import 'package:saral_lekha/screens/homepage.dart';
import 'package:saral_lekha/screens/setting.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:saral_lekha/services/category_service.dart';
import 'package:saral_lekha/services/preference_service.dart';

import '../configuration.dart';
import 'adaptive_text.dart';

class MyDrawer extends StatefulWidget {
  final HomePageState homePageState;

  const MyDrawer({Key key, this.homePageState}) : super(key: key);
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    var preferenceProvider = Provider.of<PreferenceProvider>(context);
    var selectedSubSector = Provider.of<SubSectorProvider>(context);
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
          Padding(
            padding: EdgeInsets.only(
                bottom: 10,
                left: (MediaQuery.of(context).size.width * 0.04),
                right: (MediaQuery.of(context).size.width * 0.04)),
            child: Theme(
              data: ThemeData(
                textTheme: TextTheme(
                  subhead: TextStyle(fontSize: 18),
                ),
                canvasColor: Configuration().yellowColor,
                brightness: Brightness.dark,
                primarySwatch: MaterialColor(0xffffffff, {}),
              ),
              child: DropdownButton<String>(
                  isDense: true,
                  isExpanded: true,
                  value: selectedSubSector.selectedSubSector,
                  items: [
                    for (String subSector in globals.subSectors)
                      DropdownMenuItem(
                        child: Text(subSector),
                        value: subSector,
                      )
                  ],
                  onChanged: (onValue) async {
                    if (onValue != selectedSubSector.selectedSubSector) {
                      globals.selectedSubSector = onValue;
                      selectedSubSector.selectedSubSector = onValue;
                      PreferenceService.instance.setSelectedSubSector(onValue);
                      globals.incomeCategories = await CategoryService()
                          .getCategories(selectedSubSector.selectedSubSector,
                              CategoryType.INCOME);
                      globals.expenseCategories = await CategoryService()
                          .getCategories(selectedSubSector.selectedSubSector,
                              CategoryType.EXPENSE);
                      if (widget.homePageState != null) {
                        widget.homePageState
                            .updateChartData(NepaliDateTime.now());
                      }
                      setState(() {});
                    }
                  }),
            ),
          ),
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
          ListTile(
            leading: Icon(Icons.card_travel),
            title: AdaptiveText(
              'Expense Projection',
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
          ListTile(
            leading: Icon(Icons.settings),
            title: AdaptiveText(
              'Settings',
              style: Configuration().whiteText,
            ),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Settings(
                          type: 1,
                        )),
                (Route<dynamic> route) => false),
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
