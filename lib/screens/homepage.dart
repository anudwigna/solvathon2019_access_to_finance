import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/components/extra_componenets.dart';
import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/config/globals.dart';
import 'package:MunshiG/config/routes.dart';
import 'package:MunshiG/icons/vector_icons.dart';
import 'package:MunshiG/models/app_page_naming.dart';
import 'package:MunshiG/models/transaction/transaction.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/screens/transaction_page.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../config/configuration.dart';
import '../config/globals.dart';
import '../services/activity_tracking.dart';
import '../services/app_page.dart';
import '../services/versionChanges.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Lang language;
  String selectedSubSector;
  TabController _tabController;
  int _currentYear = NepaliDateTime.now().year;
  int _currentMonth = NepaliDateTime.now().month;
  final int noOfmonths = 132;
  // List<GlobalKey<AnimatedCircularChartState>> _chartKey =
  //     new List<GlobalKey<AnimatedCircularChartState>>();
  var _dateResolver = <NepaliDateTime>[];
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeDateResolver();
    VersionChanges().v102Changes().then((value) {
      AppPage().initializeAppPages()
        ..then((value) {
          ActivityTracker()
              .pageTransactionActivity(PageName.dashboard, action: 'Opened');
        }).catchError((onError) {
          print('error');
        });
    });

    // loadv102appPages();
    _tabController = TabController(
      length: noOfmonths,
      vsync: this,
      initialIndex: _currentMonth - 1,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        ActivityTracker()
            .pageTransactionActivity(PageName.dashboard, action: 'Paused');
        break;
      case AppLifecycleState.inactive:
        ActivityTracker()
            .pageTransactionActivity(PageName.dashboard, action: 'Inactive');
        break;
      case AppLifecycleState.resumed:
        ActivityTracker()
            .pageTransactionActivity(PageName.dashboard, action: 'Resumed');
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  initializeDateResolver() {
    int initYear = _currentYear;
    int indexYear = initYear;
    for (int i = 1; i <= noOfmonths; i++) {
      _dateResolver.add(NepaliDateTime(indexYear, (i % 12 == 0) ? 12 : i % 12));
      if (i % 12 == 0) {
        indexYear++;
      }
    }
  }

  @override
  void dispose() {
    ActivityTracker()
        .pageTransactionActivity(PageName.dashboard, action: 'Closed');
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _dateResolver.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    selectedSubSector =
        Provider.of<SubSectorProvider>(context).selectedSubSector;
    return WillPopScope(
      onWillPop: () async {
        exitApplication();
        return false;
      },
      child: Container(
        decoration: Configuration().gradientDecoration,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xff2b2f8e),
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  ((language == Lang.EN) ? 'MunshiG (' : 'मुंशीजी ('),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    color: const Color(0xffffffff),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                AdaptiveText(
                  (selectedSubSector),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    color: const Color(0xffffffff),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  ')',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    color: const Color(0xffffffff),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  exitApplication();
                },
                icon: Icon(Icons.exit_to_app),
              )
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                for (int index = 0; index < noOfmonths; index++)
                  language == Lang.EN
                      ? Tab(
                          child: Text(
                            NepaliDateFormat(
                                    "MMMM ''yy",
                                    language == Lang.EN
                                        ? Language.english
                                        : Language.nepali)
                                .format(
                              NepaliDateTime(
                                _dateResolver[index].year,
                                _dateResolver[index].month,
                              ),
                            ),
                          ),
                        )
                      : Tab(
                          child: Text(
                            NepaliDateFormat(
                                    "MMMM ''yy",
                                    language == Lang.EN
                                        ? Language.english
                                        : Language.nepali)
                                .format(
                              NepaliDateTime(_dateResolver[index].year,
                                  _dateResolver[index].month),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
              ],
            ),
          ),
          drawer: MyDrawer(homePageState: this),
          body: TabBarView(
            controller: _tabController,
            children: [
              for (int index = 0; index < noOfmonths; index++)
                _buildBody(_dateResolver[index]),
            ],
          ),
        ),
      ),
    );
  }

  exitApplication() {
    showDeleteDialog(context,
        title: 'Confirm Exit',
        deleteButtonText: 'Exit  ',
        description: 'Do you want to exit this application?',
        onDeletePress: () {
      ActivityTracker().otherActivityOnPage(PageName.dashboard,
          'Exit App from In-App Dialog', 'Exit', 'FlatButton');
      SystemNavigator.pop(animated: true);
    });
  }

  Widget _buildBody(NepaliDateTime date) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Container(
        decoration: pageBorderDecoration,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenSizeConfig.blockSizeHorizontal * 10,
                    vertical: ScreenSizeConfig.blockSizeHorizontal * 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FutureBuilder<List<double>>(
                      future: TransactionService().getTotalIncomeExpense(
                          selectedSubSector, date.year, date.month),
                      builder: (context, snapshot) {
                        final income = snapshot.data?.first ?? 0.0;
                        final expense = snapshot.data?.last ?? 0.0;
                        final bool isExpenseGreater = (expense - income) > 0;
                        final percentSaved = income == 0.0
                            ? 0.0
                            : (income - expense) / (income) * 100;
                        return Center(
                          child: SleekCircularSlider(
                            innerWidget: (percentage) => Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      ScreenSizeConfig.blockSizeVertical * 4.5),
                              child:
                                  Center(child: _centerWidget(income, expense)),
                            ),
                            initialValue:
                                isExpenseGreater ? 100 : (percentSaved),
                            appearance: CircularSliderAppearance(
                              angleRange: 360,
                              startAngle: 270,
                              customWidths: CustomSliderWidths(
                                trackWidth: 10.0,
                                progressBarWidth: 10.0,
                              ),
                              customColors: CustomSliderColors(
                                trackColor: Configuration().expenseColor,
                                progressBarColors: (isExpenseGreater)
                                    ? [Colors.red, Colors.red]
                                    : [Color(0xff7635C7), Color(0xff7635C7)],
                                hideShadow: true,
                              ),
                              infoProperties: InfoProperties(
                                topLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                ),
                                bottomLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                ),
                                mainLabelStyle: TextStyle(
                                    fontSize: 17.0, color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionPage(
                                0,
                                selectedSubSector: selectedSubSector,
                              ),
                            ),
                          ).then((onValue) {
                            if (onValue ?? false) {
                              updateChartData();
                            }
                          }),
                          child: Column(
                            children: <Widget>[
                              circularComponent(true),
                              AdaptiveText(
                                'Cash In',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: const Color(0xff1e1e1e),
                                  height: 2.0833333333333335,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionPage(
                                1,
                                selectedSubSector: selectedSubSector,
                              ),
                            ),
                          ).then((onValue) {
                            if (onValue ?? false) {
                              updateChartData();
                            }
                          }),
                          child: Column(
                            children: <Widget>[
                              circularComponent(false),
                              AdaptiveText(
                                'Cash out',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: const Color(0xff1e1e1e),
                                  height: 2.0833333333333335,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20.0),
                  ],
                ),
              ),
              Text(
                language == Lang.EN
                    ? 'Overview for the month of ${NepaliDateFormat("MMMM").format(date)}'
                    : '${NepaliDateFormat("MMMM", Language.nepali).format(date)} महिनाको विस्तृत सर्वेक्षण',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.4285714285714286,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 1,
              ),
              SizedBox(
                height: 10.0,
              ),
              FutureBuilder<List<Transaction>>(
                  future: TransactionService().getTransactions(
                      selectedSubSector, date.year, date.month),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length == 0) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 4,
                              child: SvgPicture.string(
                                noTransactionIcon,
                                allowDrawingOutsideViewBox: true,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AdaptiveText(
                              'No Transactions',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey,
                                  height: 1.4285714285714286,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      } else {
                        return TransactionList(
                            transactionData: snapshot.data,
                            date: date,
                            language: language);
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerWidget(double income, double expense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AdaptiveText(
          'Cash In',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        Text(
          nepaliNumberFormatter(income ?? 0),
          style: TextStyle(
              color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        AdaptiveText(
          'Cash Out',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        Text(
          nepaliNumberFormatter(expense ?? 0),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ],
    );
  }

  updateChartData() {
    setState(() {});
  }

  circularComponent(bool cashIn) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            cashIn ? Configuration().incomeColor : Configuration().expenseColor,
      ),
      height: 38,
      width: 38,
      child: Center(
        child: Icon(
          (cashIn) ? Icons.add : Icons.remove,
          size: 30,
        ),
      ),
    );
  }
}

class TransactionList extends StatefulWidget {
  final List<Transaction> transactionData;
  final NepaliDateTime date;
  final Lang language;

  TransactionList({this.date, this.language, this.transactionData});

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  var _transactionMap = <String, List<Transaction>>{};
  List<bool> _expansionRecords;
  List<double> income, expense;
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() {
    _transactionMap = _buildTransactionMap(widget.transactionData);
    income = List.filled(_transactionMap.length, 0.0);
    expense = List.filled(_transactionMap.length, 0.0);
    int z = 0;
    _transactionMap.forEach((key, value) {
      final vv = getIncomeExpense(value);
      income[z] = vv[0];
      expense[z] = vv[1];
      z++;
    });
    _expansionRecords = List.filled(_transactionMap.length, false);
  }

  @override
  void didUpdateWidget(TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactionData.length != oldWidget.transactionData.length) {
      initData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          cardColor: Colors.white,
          cursorColor: Colors.red,
          buttonColor: Colors.amber,
          primaryColor: Colors.red),
      child: ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            setState(() {
              _expansionRecords[index] = !isExpanded;
            });
          },
          children: [
            for (int i = 0; i < _transactionMap.length; i++)
              ExpansionPanel(
                isExpanded: _expansionRecords[i],
                canTapOnHeader: true,
                headerBuilder: (context, isExpanded) => ListTile(
                  leading: Chip(
                    label: Text(
                        getDateTimeFormat(_transactionMap.keys.toList()[i])),
                    backgroundColor: Configuration().incomeColor,
                  ),
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _aggregate(
                          0,
                          income[i],
                        ),
                        _aggregate(
                          1,
                          expense[i],
                        ),
                      ],
                    ),
                  ),
                ),
                body: _dailyTransactionWidget(
                    _transactionMap[_transactionMap.keys.toList()[i]]),
              ),
          ]),
    );
  }

  List<double> getIncomeExpense(List<Transaction> data) {
    double inValue = 0.0;
    double exValue = 0.0;
    data.forEach((element) {
      if (element.transactionType == 0) {
        inValue = inValue + double.parse(element.amount);
      } else
        exValue = exValue + double.parse(element.amount);
    });
    return [inValue, exValue];
  }

  Widget _aggregate(int transactionType, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Material(
            color: (transactionType == 0)
                ? Configuration().incomeColor
                : Configuration().expenseColor,
            shape: CircleBorder(),
            child: SizedBox(
              width: 10.0,
              height: 10.0,
            ),
          ),
          SizedBox(width: 5.0),
          Text(
            nepaliNumberFormatter(amount),
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  getDateTimeFormat(String date) {
    return NepaliDateFormat("dd/MM/EE",
            widget.language == Lang.EN ? Language.english : Language.nepali)
        .format(NepaliDateTime.parse(NepaliDateTime(
      int.parse(date.split('-').first),
      int.parse(date.split('-')[1]),
      int.parse(date.split('-').last),
    ).toString()));
  }

  Widget _dailyTransactionWidget(List<Transaction> dailyTransactions) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: dailyTransactions.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: CategoryService().getCategoryById(
                        selectedSubSector,
                        dailyTransactions[index].categoryId,
                        dailyTransactions[index].transactionType,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Container(
                            height: 1,
                            width: 1,
                          );
                        return ListTile(
                          onTap: () async {
                            await _showTransactionDetail(
                                dailyTransactions[index]);
                          },
                          leading: Icon(
                            VectorIcons.fromName(
                              snapshot.data.iconName,
                              provider: IconProvider.FontAwesome5,
                            ),
                            color: Configuration().incomeColor,
                            size: 20.0,
                          ),
                          title: AdaptiveText(
                            '',
                            category: snapshot.data,
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Text(
                            nepaliNumberFormatter(double.tryParse(
                                dailyTransactions[index].amount)),
                            style: getTextStyle(dailyTransactions[index]),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, _) => Container(
                        height: 1,
                      )),
            ),
          ],
        ),
      ),
    );
  }

  Future _showTransactionDetail(Transaction transaction) async {
    await detailDialog(context,
        title: 'Transaction Detail',
        detailWidget: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _detailsRow(
                'Date: ',
                NepaliDateFormat(
                        "MMMM dd, y (EEE)",
                        widget.language == Lang.EN
                            ? Language.english
                            : Language.nepali)
                    .format(
                  NepaliDateTime.parse(transaction.timestamp),
                ),
              ),
              // SizedBox(height: 5.0),
              _detailsRow('Detail: ', '${transaction.memo ?? ''}'),
              // SizedBox(height: 5.0),
              _detailsRow(
                'Amount: ',
                nepaliNumberFormatter(transaction.amount ?? 0),
              ),
            ]), onDelete: () {
      _deleteTransaction(transaction).then((value) {
        Navigator.of(context, rootNavigator: true).pop(value);
      });
    }, onUpdate: () {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionPage(
            transaction.transactionType,
            transaction: transaction,
            selectedSubSector: selectedSubSector,
          ),
        ),
      ).then((value) {
        if (value ?? false) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            home,
            ModalRoute.withName(home),
          );
        }
      });
    }, onDialogClosed: (value) {
      if (value ?? false) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          home,
          ModalRoute.withName(home),
        );
      }
    });
  }

  _detailsRow(String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AdaptiveText(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: const Color(0xff272b37),
            height: 2.1538461538461537,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          width: 3,
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: const Color(0xff272b37),
              height: 2.1538461538461537,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle getTextStyle(Transaction transaction) => TextStyle(
      color: transaction.transactionType == 0
          ? Configuration().incomeColor
          : Configuration().expenseColor,
      fontWeight: FontWeight.bold);

  Map<String, List<Transaction>> _buildTransactionMap(
      List<Transaction> transactions) {
    transactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final zz = transactions.reversed.toList();
    final map = zz.groupBy((e) => e.timestamp.split('T').first);
    return map;
  }

  Future<bool> _deleteTransaction(Transaction transaction) async {
    final d = await showDeleteDialog(context,
        topIcon: Icons.error_outline,
        description: 'Are you sure you want to delete this transaction?',
        title: 'Delete Transaction', onDeletePress: () async {
      await TransactionService()
          .deleteTransaction(selectedSubSector, transaction, false);
      Navigator.of(context, rootNavigator: true).pop(true);
    }, onCancelPress: () {
      Navigator.of(context, rootNavigator: true).pop(false);
    });

    return d;
  }
}
