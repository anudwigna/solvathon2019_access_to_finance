import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:munshiji/globals.dart' as globals;
import 'package:munshiji/providers/preference_provider.dart';
import 'package:munshiji/screens/homepage.dart';
import 'package:munshiji/screens/setting.dart';
import 'package:munshiji/services/category_service.dart';
import 'package:munshiji/services/preference_service.dart';
import '../configuration.dart';
import '../globals.dart';
import 'adaptive_text.dart';

class MyDrawer extends StatefulWidget {
  final HomePageState homePageState;

  const MyDrawer({Key key, this.homePageState}) : super(key: key);
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  TextStyle _style = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    color: const Color(0xff1e1e1e),
  );
  @override
  Widget build(BuildContext context) {
    var preferenceProvider = Provider.of<PreferenceProvider>(context);
    var selectedSubSector = Provider.of<SubSectorProvider>(context);
    return Container(
      color: const Color(0xffffffff),
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Padding(
        padding: MediaQuery.of(context).viewPadding,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                "assets/images/munshiji-logo.png",
                height: 60.0,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Theme(
              data: ThemeData(
                textTheme: TextTheme(
                  subhead: TextStyle(fontSize: 18),
                ),
                canvasColor: Configuration().appColor,
                brightness: Brightness.dark,
                primarySwatch: MaterialColor(0xffffffff, {}),
              ),
              child: DropdownButton<String>(
                  isDense: true,
                  iconEnabledColor: Colors.black,
                  iconDisabledColor: Colors.black,
                  isExpanded: true,
                  value: selectedSubSector.selectedSubSector,
                  iconSize: 30,
                  dropdownColor: Colors.white,
                  items: [
                    for (String subSector in globals.subSectors)
                      DropdownMenuItem(
                        child: Text(
                          subSector,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: const Color(0xff1e1e1e),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                        await widget.homePageState.updateChartData();
                      }
                      setState(() {});
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        ModalRoute.withName('/home'),
                      );
                    }
                  }),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                dashboard,
                allowDrawingOutsideViewBox: true,
                alignment: Alignment.bottomCenter,
              ),
              title: AdaptiveText(
                'Dashboard',
                style: _style,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                ModalRoute.withName('/home'),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              dense: true,
              leading: Icon(
                Icons.person,
                color: Colors.blue,
              ),
              title: AdaptiveText(
                'Profile',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/profilepage',
                ModalRoute.withName('/home'),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                categories,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Categories',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/category',
                ModalRoute.withName('/home'),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                castOutflow,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Cash Outflow Projection',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/budget',
                ModalRoute.withName('/home'),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                accounts,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Accounts',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/account',
                ModalRoute.withName('/home'),
              ),
            ),
            Expanded(child: Container()),
            Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                  leading: SvgPicture.string(
                    settings,
                    allowDrawingOutsideViewBox: true,
                  ),
                  title: AdaptiveText(
                    'Settings',
                    style: _style,
                    textAlign: TextAlign.left,
                  ),
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => Settings(
                                type: 1,
                              )),
                      (Route<dynamic> route) => false),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                  leading: SvgPicture.string(
                    nepaliLanguage,
                    allowDrawingOutsideViewBox: true,
                  ),
                  title: AdaptiveText(
                    'Nepali Language',
                    style: _style,
                    textAlign: TextAlign.left,
                  ),
                  trailing: Switch(
                    value:
                        preferenceProvider.language == Lang.NP ? true : false,
                    activeColor: Colors.white,
                    inactiveTrackColor: Colors.black,
                    inactiveThumbColor: Colors.white,
                    activeTrackColor: Configuration().incomeColor,
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
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
