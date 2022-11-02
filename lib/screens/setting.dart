import 'dart:convert';

import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/config/routes.dart';
import 'package:MunshiG/models/database_and_store.dart';
import 'package:sembast/sembast.dart';
import '../services/transaction_service.dart';
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
import '../models/app_page_naming.dart';
import '../services/activity_tracking.dart';

class Settings extends StatefulWidget {
//0=First time page , 1= Settings page from inapp
  final int? type;

  const Settings({Key? key, this.type}) : super(key: key);
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
  void initState() {
    if (widget.type == 1) {
      ActivityTracker().pageTransactionActivity(PageName.setting, action: 'Opened');
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.type == 1) {
      ActivityTracker().pageTransactionActivity(PageName.setting, action: 'Closed');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.type == 1,
        title: AdaptiveText(
          "Select your preferences",
          style: TextStyle(fontSize: 17),
        ),
      ),
      drawer: (widget.type == 0) ? Container() : MyDrawer(),
      backgroundColor: Configuration().appColor,
      key: _key,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))),
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
                    builder: (context, AsyncSnapshot<List<dynamic>?> snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: (widget.type == 1) ? const EdgeInsets.all(8.0) : const EdgeInsets.all(20),
                          child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 1.4, mainAxisSpacing: 20, crossAxisSpacing: 10, crossAxisCount: MediaQuery.of(context).size.width < 550 ? 2 : 3),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: (_subSectorsData.contains(snapshot.data![index]) || _newSelectedSubSectors.contains(snapshot.data![index])) ? selectedColor : unSelectedColor,
                                                  width: 2)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/${snapshot.data![index].toString().toLowerCase()}_logo.png',
                                                // fit: BoxFit.fill,
                                                // width: ScreenSizeConfig
                                                //         .blockSizeHorizontal *
                                                //     16,
                                                color: (_subSectorsData.contains(snapshot.data![index]) || _newSelectedSubSectors.contains(snapshot.data![index])) ? selectedColor : unSelectedColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      AdaptiveText(
                                        snapshot.data![(index)],
                                        style: TextStyle(
                                          color: (_subSectorsData.contains(snapshot.data![index]) || _newSelectedSubSectors.contains(snapshot.data![index])) ? selectedColor : unSelectedColor,
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    if (widget.type == 0) {
                                      if (_subSectorsData.contains(snapshot.data![index])) {
                                        _subSectorsData.remove(snapshot.data![index]);
                                      } else {
                                        _subSectorsData.add(snapshot.data![index]);
                                      }

                                      setState(() {});
                                    } else {
                                      if (!_newSelectedSubSectors.contains(snapshot.data![index])) {
                                        if (_subSectorsData.contains(snapshot.data![index])) {
                                          ScaffoldMessenger.of(_key.currentState!.context).showSnackBar(SnackBar(content: AdaptiveText("Selected Sub Sectors cannot be removed")));
                                        } else {
                                          _newSelectedSubSectors.add(snapshot.data![index]);
                                        }
                                      } else {
                                        _newSelectedSubSectors.remove(snapshot.data![index]);
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
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) => Configuration().incomeColor),
                        minimumSize: MaterialStateProperty.resolveWith((states) => Size(160, 46)),
                      ),
                      onPressed: () async {
                        try {
                          if (widget.type == 0) {
                            if (_subSectorsData.length > 0) {
                              showFullBodyLoader(context);
                              await PreferenceService.instance.setSelectedSubSector(_subSectorsData[0]);
                              await PreferenceService.instance.setSubSectors(_subSectorsData);
                              globals.subSectors = _subSectorsData;
                              globals.selectedSubSector = _subSectorsData[0];
                              Future.delayed(Duration(seconds: 1), () async {
                                globals.incomeCategories = await CategoryService().getCategories(globals.selectedSubSector!, CategoryType.INCOME);
                                globals.expenseCategories = await CategoryService().getCategories(globals.selectedSubSector!, CategoryType.EXPENSE);
                              });
                              await _loadCategories(_subSectorsData);
                              PreferenceService.instance.setIsFirstStart(false);
                              await Future.delayed(Duration(seconds: 2));
                              Navigator.pushNamedAndRemoveUntil(context, wrapper, (Route<dynamic> route) => false);
                            } else {
                              ScaffoldMessenger.of(_key.currentState!.context).showSnackBar(SnackBar(
                                content: AdaptiveText(
                                  'Please Select atleast one preference',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ));
                            }
                          } else if (widget.type == 1) {
                            ScaffoldMessenger.of(_key.currentState!.context).removeCurrentSnackBar();
                            if (_newSelectedSubSectors.length > 0) {
                              showFullBodyLoader(context);
                              globals.subSectors!.addAll(_newSelectedSubSectors);
                              await PreferenceService.instance.setSubSectors(globals.subSectors!);
                              await _loadCategories(_newSelectedSubSectors);
                              _newSelectedSubSectors.clear();
                              Navigator.of(context, rootNavigator: true).pop();
                              ScaffoldMessenger.of(_key.currentState!.context).showSnackBar(SnackBar(
                                content: AdaptiveText(
                                  'New Preference has been added',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));
                            } else {
                              ScaffoldMessenger.of(_key.currentState!.context).showSnackBar(SnackBar(
                                content: AdaptiveText(
                                  'No changes has been made',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        } catch (e) {
                          print(e);
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(_key.currentState!.context).showSnackBar(SnackBar(
                            content: AdaptiveText(
                              'Error Creating Preferences, Please try Again',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      child: AdaptiveText(
                        'Submit',
                        style: TextStyle(color: Colors.white),
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

  Future<List<dynamic>?> _loadSubSectors() async {
    dynamic categories = jsonDecode(await rootBundle.loadString('assets/subsector.json'));
    List<dynamic>? _subSectors = categories['subSectors'];
    return _subSectors;
  }

  Future<void> _loadCategories(List<dynamic> _subSectors) async {
    final db = await TransactionService().getDatabaseAndStore(_subSectors[0]);
    await db.database.transaction((transaction) async {
      for (int i = 0; i < _subSectors.length; i++) {
        String _subSector = _subSectors[i];
        var incomeDbStore = await CategoryService().getDatabaseAndStore(_subSector, CategoryType.INCOME);
        var expenseDbStore = await CategoryService().getDatabaseAndStore(_subSector, CategoryType.EXPENSE);
        var _incomeCategories = await CategoryService().getStockCategories(_subSector, CategoryType.INCOME);
        var _expenseCategories = await CategoryService().getStockCategories(_subSector, CategoryType.EXPENSE);
        for (int i = 0; i < _incomeCategories.length; i++) {
          final category = _incomeCategories[i];
          await incomeDbStore.store!.record(category.id).put(
                incomeDbStore.database,
                category.toJson(),
              );
        }
        for (int i = 0; i < _expenseCategories.length; i++) {
          final category = _expenseCategories[i];
          await expenseDbStore.store!.record(category.id).put(
                expenseDbStore.database,
                category.toJson(),
              );
        }
      }
    }).catchError((onError) {
      throw (onError);
    });

    if (widget.type == 0) {
      // globals.selectedSubSector = _subSectors[0];
      if (await PreferenceService.instance.getCurrentIncomeCategoryIndex() == 0) await PreferenceService.instance.setCurrentIncomeCategoryIndex(1000);
      if (await PreferenceService.instance.getCurrentExpenseCategoryIndex() == 0) await PreferenceService.instance.setCurrentExpenseCategoryIndex(10000);

      if (await PreferenceService.instance.getCurrentTransactionIndex() == 0) await PreferenceService.instance.setCurrentTransactionIndex(1);
      final Account account = Account(
        name: 'Cash',
        type: 2,
        balance: '0',
        transactionIds: [],
      );
      final doesExists = await AccountService().checkifAccountExists(account);
      if (!doesExists) await AccountService().addAccount(account, true);
    }
  }
}

showFullBodyLoader(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      });
}
