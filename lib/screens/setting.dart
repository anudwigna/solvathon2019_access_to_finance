import 'dart:convert';

import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/config/globals.dart' as globals;
import 'package:MunshiG/models/account/account.dart';
import 'package:MunshiG/services/account_service.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/preference_service.dart';

class Settings extends StatefulWidget {
//0=First time page , 1= Settings page from inapp
  final int type;

  const Settings({Key key, this.type}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<dynamic> _subSectorsData = globals.subSectors ?? [];
  List<dynamic> _newSelectedSubSectors = [];
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final Color selectedColor = Configuration().expenseColor;
  final Color unSelectedColor = Configuration().incomeColor.withOpacity(0.8);
  //Color(0xff7133BF);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.type == 1,
        title: AdaptiveText("Select your preferences"),
      ),
      drawer: (widget.type == 0) ? Container() : MyDrawer(),
      backgroundColor: Configuration().appColor,
      key: _key,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50))),
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                (widget.type == 0)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: AdaptiveText(
                            "Select your preferences",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: FutureBuilder(
                    future: _loadSubSectors(),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: (widget.type == 1)
                              ? const EdgeInsets.all(8.0)
                              : const EdgeInsets.all(20),
                          child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 1.35,
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 10,
                                      crossAxisCount: 2),
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: (_subSectorsData
                                                              .contains(
                                                                  snapshot.data[
                                                                      index]) ||
                                                          _newSelectedSubSectors
                                                              .contains(snapshot
                                                                  .data[index]))
                                                      ? selectedColor
                                                      : unSelectedColor,
                                                  width: 2)),
                                          child: Center(
                                            child: Image.asset(
                                              'assets/${snapshot.data[index].toString().toLowerCase()}_logo.png',
                                              fit: BoxFit.contain,
                                              width: ScreenSizeConfig
                                                      .blockSizeHorizontal *
                                                  16,
                                              color: (_subSectorsData.contains(
                                                          snapshot
                                                              .data[index]) ||
                                                      _newSelectedSubSectors
                                                          .contains(snapshot
                                                              .data[index]))
                                                  ? selectedColor
                                                  : unSelectedColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        snapshot.data[(index)],
                                        style: TextStyle(
                                          color: (_subSectorsData.contains(
                                                      snapshot.data[index]) ||
                                                  _newSelectedSubSectors
                                                      .contains(
                                                          snapshot.data[index]))
                                              ? selectedColor
                                              : unSelectedColor,
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    if (widget.type == 0) {
                                      if (_subSectorsData
                                          .contains(snapshot.data[index])) {
                                        _subSectorsData
                                            .remove(snapshot.data[index]);
                                      } else {
                                        _subSectorsData
                                            .add(snapshot.data[index]);
                                      }

                                      setState(() {});
                                    } else {
                                      if (!_newSelectedSubSectors
                                          .contains(snapshot.data[index])) {
                                        if (_subSectorsData
                                            .contains(snapshot.data[index])) {
                                          _key.currentState.showSnackBar(SnackBar(
                                              content: Text(
                                                  "Selected Sub Sectors cannot be removed")));
                                        } else {
                                          _newSelectedSubSectors
                                              .add(snapshot.data[index]);
                                        }
                                      } else {
                                        _newSelectedSubSectors
                                            .remove(snapshot.data[index]);
                                      }

                                      setState(() {});
                                    }
                                  },
                                );
                              }),
                        );
                      }

                      return CircularProgressIndicator();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      color: Configuration().incomeColor,
                      onPressed: () async {
                        if (widget.type == 0) {
                          if (_subSectorsData.length > 0) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                });
                            PreferenceService.instance.setIsFirstStart(false);
                            await PreferenceService.instance
                                .setSelectedSubSector(_subSectorsData[0]);
                            await PreferenceService.instance
                                .setSubSectors(_subSectorsData);
                            globals.subSectors = _subSectorsData;
                            globals.selectedSubSector = _subSectorsData[0];
                            Future.delayed(Duration(seconds: 1), () async {
                              globals.incomeCategories = await CategoryService()
                                  .getCategories(globals.selectedSubSector,
                                      CategoryType.INCOME);
                              globals.expenseCategories =
                                  await CategoryService().getCategories(
                                      globals.selectedSubSector,
                                      CategoryType.EXPENSE);
                            });
                            await _loadCategories(_subSectorsData);
                            await Future.delayed(Duration(seconds: 2));
                            Navigator.pushNamedAndRemoveUntil(context, wrapper,
                                (Route<dynamic> route) => false);
                          } else {
                            _key.currentState.showSnackBar(SnackBar(
                              content:
                                  Text('At least one options must be selected'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        } else if (widget.type == 1) {
                          _key.currentState.removeCurrentSnackBar();
                          if (_newSelectedSubSectors.length > 0) {
                            globals.subSectors.addAll(_newSelectedSubSectors);
                            await PreferenceService.instance
                                .setSubSectors(globals.subSectors);
                            await _loadCategories(_newSelectedSubSectors);
                            _newSelectedSubSectors.clear();
                            _key.currentState.showSnackBar(SnackBar(
                              content:
                                  AdaptiveText('New Preference has been added'),
                              backgroundColor: Colors.green,
                            ));
                          } else {
                            _key.currentState.showSnackBar(SnackBar(
                              content: AdaptiveText('No Changes has been made'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                      child: Container(
                        width: double.maxFinite,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: AdaptiveText(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> _loadSubSectors() async {
    dynamic categories =
        jsonDecode(await rootBundle.loadString('assets/subsector.json'));
    List<dynamic> _subSectors = categories['subSectors'];
    return _subSectors;
  }

  Future<void> _loadCategories(List<dynamic> _subSectors) async {
    // for (String _subSector in _subSectors) {
    for (int i = 0; i < _subSectors.length; i++) {
      String _subSector = _subSectors[i];
      var incomeDbStore = await CategoryService()
          .getDatabaseAndStore(_subSector, CategoryType.INCOME);
      var expenseDbStore = await CategoryService()
          .getDatabaseAndStore(_subSector, CategoryType.EXPENSE);
      var _incomeCategories = await CategoryService()
          .getStockCategories(_subSector, CategoryType.INCOME);
      var _expenseCategories = await CategoryService()
          .getStockCategories(_subSector, CategoryType.EXPENSE);
      _incomeCategories.forEach(
        (category) async {
          await incomeDbStore.store.record(category.id).put(
                incomeDbStore.database,
                category.toJson(),
              );
        },
      );

      _expenseCategories.forEach(
        (category) async {
          await expenseDbStore.store.record(category.id).put(
                expenseDbStore.database,
                category.toJson(),
              );
        },
      );
    }

    if (widget.type == 0) {
      // globals.selectedSubSector = _subSectors[0];
      if (await PreferenceService.instance.getCurrentIncomeCategoryIndex() == 0)
        await PreferenceService.instance.setCurrentIncomeCategoryIndex(1000);
      if (await PreferenceService.instance.getCurrentExpenseCategoryIndex() ==
          0)
        await PreferenceService.instance.setCurrentExpenseCategoryIndex(10000);

      if (await PreferenceService.instance.getCurrentTransactionIndex() == 0)
        await PreferenceService.instance.setCurrentTransactionIndex(1);
      final ll = await AccountService().checkifAccountExists(
        Account(
          name: 'Cash',
          type: 2,
          balance: '0',
          transactionIds: [],
        ),
      );
      if ((!ll) ?? false)
        await AccountService().addAccount(
          Account(
            name: 'Cash',
            type: 2,
            balance: '0',
            transactionIds: [],
          ),
        );
    }
  }
}
