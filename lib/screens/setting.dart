import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saral_lekha/components/adaptive_text.dart';
import 'package:saral_lekha/components/drawer.dart';
import 'package:saral_lekha/configuration.dart';
import 'package:saral_lekha/globals.dart' as globals;
import 'package:saral_lekha/models/account/account.dart';
import 'package:saral_lekha/services/account_service.dart';
import 'package:saral_lekha/services/category_service.dart';
import 'package:saral_lekha/services/preference_service.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.type == 0)
          ? PreferredSize(child: Container(), preferredSize: Size(0, 0))
          : AppBar(
              title: AdaptiveText("Select your preferences"),
            ),
      drawer: (widget.type == 0) ? Container() : MyDrawer(),
      backgroundColor: Configuration().yellowColor,
      key: _key,
      body: SafeArea(
        child: Container(
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
                                    mainAxisSpacing: 5,
                                    crossAxisSpacing: 5,
                                    crossAxisCount: 4),
                            itemCount: snapshot.data.length,
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
                                    Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: (_subSectorsData.contains(
                                                          snapshot
                                                              .data[index]) ||
                                                      _newSelectedSubSectors
                                                          .contains(snapshot
                                                              .data[index]))
                                                  ? Colors.green
                                                  : Colors.white,
                                              width: 2)),
                                      padding: EdgeInsets.all(5),
                                      child: Image.asset(
                                        'assets/${snapshot.data[index].toString().toLowerCase()}_logo.png',
                                        fit: BoxFit.contain,
                                        color: Colors.white,
                                        height: 50,
                                      ),
                                    ),
                                    Expanded(
                                        child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text(
                                              snapshot.data[(index)],
                                              style: TextStyle(
                                                color: (_subSectorsData
                                                            .contains(snapshot
                                                                .data[index]) ||
                                                        _newSelectedSubSectors
                                                            .contains(snapshot
                                                                .data[index]))
                                                    ? Colors.green
                                                    : Colors.white,
                                              ),
                                            )))
                                  ],
                                ),
                                onTap: () {
                                  if (widget.type == 0) {
                                    if (_subSectorsData
                                        .contains(snapshot.data[index])) {
                                      _subSectorsData
                                          .remove(snapshot.data[index]);
                                    } else {
                                      _subSectorsData.add(snapshot.data[index]);
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
                            globals.expenseCategories = await CategoryService()
                                .getCategories(globals.selectedSubSector,
                                    CategoryType.EXPENSE);
                          });
                          await _loadCategories(_subSectorsData);
                          await Future.delayed(Duration(seconds: 2));
                          Navigator.pushReplacementNamed(context, '/wrapper');
                        } else {
                          _key.currentState.showSnackBar(SnackBar(
                            content:
                                Text('At least one options must be selected'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      } else if (widget.type == 1) {
                        if (_newSelectedSubSectors.length > 0) {
                          globals.subSectors.addAll(_newSelectedSubSectors);
                          await PreferenceService.instance
                              .setSubSectors(globals.subSectors);
                          _loadCategories(_newSelectedSubSectors);
                          _newSelectedSubSectors.clear();
                          _key.currentState.showSnackBar(SnackBar(
                            content: Text('Action Completed'),
                            backgroundColor: Colors.green,
                          ));
                        } else {
                          _key.currentState.showSnackBar(SnackBar(
                            content: Text('No Changes has been made'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    },
                    child: AdaptiveText(
                      'Submit',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
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

  _loadCategories(List<dynamic> _subSectors) async {
    for (String _subSector in _subSectors) {
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
      await PreferenceService.instance.setCurrentIncomeCategoryIndex(1000);
      await PreferenceService.instance.setCurrentExpenseCategoryIndex(10000);
      await PreferenceService.instance.setCurrentTransactionIndex(1);
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
