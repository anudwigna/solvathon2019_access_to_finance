import 'package:MunshiG/config/globals.dart' as globals;
import 'package:MunshiG/config/routes.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/screens/homepage.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/preference_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../config/configuration.dart';
import '../config/globals.dart';
import 'adaptive_text.dart';

class MyDrawer extends StatefulWidget {
  final HomePageState? homePageState;

  const MyDrawer({Key? key, this.homePageState}) : super(key: key);
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  TextStyle _style = TextStyle(
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
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                "assets/images/munshiji-logo.png",
                height: 60.0,
                color: Color(0xff2b2f8e),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            DropdownButton<String>(
                isDense: true,
                iconEnabledColor: Colors.black,
                iconDisabledColor: Colors.black,
                isExpanded: true,
                value: selectedSubSector.selectedSubSector,
                iconSize: 30,
                dropdownColor: Colors.white,
                items: [
                  for (String subSector in (globals.subSectors ?? []))
                    DropdownMenuItem(
                      child: AdaptiveText(
                        subSector,
                        style: TextStyle(
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
                    globals.incomeCategories = await CategoryService().getCategories(selectedSubSector.selectedSubSector!, CategoryType.INCOME);
                    globals.expenseCategories = await CategoryService().getCategories(selectedSubSector.selectedSubSector!, CategoryType.EXPENSE);
                    if (widget.homePageState != null) {
                      await widget.homePageState!.updateChartData();
                    }
                    setState(() {});
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      home,
                      ModalRoute.withName(home),
                    );
                  }
                }),
            SizedBox(
              height: 10,
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                dashboardIcon,
                allowDrawingOutsideViewBox: true,
                alignment: Alignment.bottomCenter,
              ),
              title: AdaptiveText(
                'Dashboard',
                style: _style,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                home,
                ModalRoute.withName(home),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              dense: true,
              leading: Icon(
                Icons.person_outline,
                color: Configuration.accountIconColor,
              ),
              title: AdaptiveText(
                'Profile',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                profilePage,
                ModalRoute.withName(home),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                categoriesIcon,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Categories',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                category,
                ModalRoute.withName(home),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                castOutflowIcon,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Cash Inflow Projection',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, budget, ModalRoute.withName(home), arguments: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                castOutflowIcon,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Cash Outflow Projection',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, budget, ModalRoute.withName(home), arguments: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                accountsIcon,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Accounts',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                account,
                ModalRoute.withName(home),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                categoriesIcon,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Report',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, report, ModalRoute.withName(home), arguments: selectedSubSector.selectedSubSector),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
              leading: SvgPicture.string(
                categoriesIcon,
                allowDrawingOutsideViewBox: true,
              ),
              title: AdaptiveText(
                'Backup',
                style: _style,
                textAlign: TextAlign.left,
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                backup,
                ModalRoute.withName(home),
              ),
            ),
            Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                  leading: SvgPicture.string(
                    settingsIcon,
                    allowDrawingOutsideViewBox: true,
                  ),
                  title: AdaptiveText(
                    'Settings',
                    style: _style,
                    textAlign: TextAlign.left,
                  ),
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, setting, ModalRoute.withName(home), arguments: 1),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                  leading: SvgPicture.string(
                    nepaliLanguageIcon,
                    allowDrawingOutsideViewBox: true,
                  ),
                  title: AdaptiveText(
                    'Nepali Language',
                    style: _style,
                    textAlign: TextAlign.left,
                  ),
                  trailing: Switch(
                    value: preferenceProvider.language == Lang.NP ? true : false,
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
