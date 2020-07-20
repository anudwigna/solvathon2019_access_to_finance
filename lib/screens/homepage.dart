import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/globals.dart';
import 'package:MunshiG/icons/vector_icons.dart';
import 'package:MunshiG/models/transaction/transaction.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/screens/transaction_page.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/transaction_service.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../configuration.dart';
import '../globals.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Lang language;
  String selectedSubSector;
  TabController _tabController;
  int _currentYear = NepaliDateTime.now().year;
  int _currentMonth = NepaliDateTime.now().month;
  List<GlobalKey<AnimatedCircularChartState>> _chartKey =
      new List<GlobalKey<AnimatedCircularChartState>>();
  var _dateResolver = <NepaliDateTime>[];
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  final int _initialIndex = 9;

  @override
  void initState() {
    super.initState();
    initializeDateResolver();
    _tabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: _initialIndex,
    );
  }

  initializeDateResolver() {
    int _year = _currentYear;
    int _firstMonth;
    bool _incrementer;
    _firstMonth = _currentMonth - 9;
    if (_firstMonth <= 0) {
      _year = _currentYear - 1;
    }
    for (int i = 0; i < 12; i++) {
      int _thisMonth = (_firstMonth + i) % 12;
      if (_incrementer = _thisMonth == 0) {
        _thisMonth = 12;
      }
      _dateResolver.add(NepaliDateTime(_year, _thisMonth));
      if (_incrementer) _year++;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateResolver.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    selectedSubSector =
        Provider.of<SubSectorProvider>(context).selectedSubSector;
    return Container(
      decoration: Configuration().gradientDecoration,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xff2b2f8e),
        appBar: AppBar(
          title: Text(
            ((language == Lang.EN) ? 'MunshiG (' : 'मुंशीजी (') +
                (selectedSubSector) +
                ')',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              color: const Color(0xffffffff),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Configuration().incomeColor,
            ),
            tabs: [
              for (int index = 0; index < 12; index++)
                language == Lang.EN
                    ? Tab(
                        child: Text(
                          NepaliDateFormat("MMMM ''yy").format(
                            NepaliDateTime(
                              _dateResolver[index].year,
                              _dateResolver[index].month,
                            ),
                          ),
                        ),
                      )
                    : Tab(
                        child: Text(
                          NepaliDateFormat("MMMM ''yy", Language.nepali).format(
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
            for (int index = 0; index < 12; index++)
              _buildBody(_dateResolver[index]),
          ],
        ),
      ),
    );
  }

  initChartController(NepaliDateTime date) {
    _chartKey.add(GlobalKey<AnimatedCircularChartState>());
  }

  Widget _buildBody(NepaliDateTime date) {
    initChartController(date);
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Material(
        elevation: 5.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40.0), topLeft: Radius.circular(40.0)),
        ),
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
                                top: ScreenSizeConfig.blockSizeVertical * 4.5),
                            child:
                                Center(child: _centerWidget(income, expense)),
                          ),
                          key: _chartKey[date.month - 1],
                          initialValue: isExpenseGreater ? 100 : percentSaved,
                          appearance: CircularSliderAppearance(
                            angleRange: 360,
                            startAngle: 270,
                            customWidths: CustomSliderWidths(
                              trackWidth: 10.0,
                              progressBarWidth: 10.0,
                            ),
                            customColors: CustomSliderColors(
                              trackColor: Color(0xff7635C7),
                              progressBarColors: (isExpenseGreater)
                                  ? [Colors.red, Colors.red]
                                  : [
                                      Configuration().expenseColor,
                                      Configuration().expenseColor
                                    ],
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
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionPage(0),
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
                                builder: (context) => TransactionPage(1),
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
                    ),
                  ),
                  SizedBox(width: 20.0),
                ],
              ),
            ),
            Text(
              language == Lang.EN
                  ? 'Overview for the month of  ${NepaliDateFormat("MMMM").format(date)}'
                  : '${NepaliDateFormat("MMMM", Language.nepali).format(date)} महिनाको विस्तृत सर्वेक्षण',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: const Color(0xffb2b2b2),
                  height: 1.4285714285714286,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10.0,
            ),
            Divider(
              color: Colors.grey.withOpacity(0.5),
              thickness: 2,
            ),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
                child: FutureBuilder<List<Transaction>>(
                    future: TransactionService().getTransactions(
                        selectedSubSector, date.year, date.month),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length == 0) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.string(
                                noTransaction,
                                allowDrawingOutsideViewBox: true,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              AdaptiveText(
                                'No Transactions',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: const Color(0xff272b37),
                                  height: 1.4285714285714286,
                                ),
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
                    })),
          ],
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
          NepaliNumberFormat(
                  decimalDigits: 0,
                  language: (language == Lang.EN)
                      ? Language.english
                      : Language.nepali)
              .format(income ?? 0),
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
          NepaliNumberFormat(
                  decimalDigits: 0,
                  language: (language == Lang.EN)
                      ? Language.english
                      : Language.nepali)
              .format(expense ?? 0),
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
          color: cashIn
              ? Configuration().incomeColor
              : Configuration().expenseColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 0),
              blurRadius: 3,
            )
          ]),
      height: 38,
      width: 38,
      child: Center(
        child: Icon(
          Icons.add,
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

  @override
  void initState() {
    super.initState();
    _transactionMap = _buildTransactionMap(widget.transactionData);
    _expansionRecords = List.filled(_transactionMap.length, false);
  }

  @override
  void didUpdateWidget(TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactionData.length != oldWidget.transactionData.length) {
      _transactionMap = _buildTransactionMap(widget.transactionData);
      _expansionRecords = List.filled(_transactionMap.length, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Theme(
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
                            getIncomeExpense(
                                _transactionMap.values.toList()[i], 0),
                          ),
                          _aggregate(
                            1,
                            getIncomeExpense(
                                _transactionMap.values.toList()[i], 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: _dailyTransactionWidget(
                      _transactionMap[_transactionMap.keys.toList()[i]]),
                ),
            ]),
      ),
    );
  }

  double getIncomeExpense(List<Transaction> data, int type) {
    double value = 0.0;
    var list = (type == 0)
        ? data.takeWhile((value) => (value.transactionType == 0)).toList()
        : data.skipWhile((value) => (value.transactionType == 0)).toList();
    list.forEach((element) {
      value = value + double.parse(element.amount);
    });

    return value;
  }

  Widget _aggregate(int transactionType, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Material(
            color: (transactionType == 0)
                ? Configuration().expenseColor
                : Colors.grey[400],
            shape: CircleBorder(),
            child: SizedBox(
              width: 10.0,
              height: 10.0,
            ),
          ),
          SizedBox(width: 5.0),
          Text(
            NepaliNumberFormat(
                    decimalDigits: 0,
                    language:
                        (language == 'en') ? Language.english : Language.nepali)
                .format<double>(amount),
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
                            NepaliNumberFormat(
                                    language: (language == 'en')
                                        ? Language.english
                                        : Language.nepali)
                                .format(dailyTransactions[index].amount),
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
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(0.0),
          title: AdaptiveText(
            'Transaction Detail',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              color: const Color(0xff1e1e1e),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: _detailsRow(
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
              ),
              SizedBox(height: 5.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: _detailsRow('Detail: ', '${transaction.memo ?? ''}'),
              ),
              SizedBox(height: 5.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: _detailsRow(
                  'Amount: ',
                  NepaliNumberFormat(
                          language: (language == Lang.EN)
                              ? Language.english
                              : Language.nepali)
                      .format(transaction.amount ?? 0),
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        _deleteTransaction(transaction).then((value) {
                          Navigator.pop(context, value);
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21.0),
                          color: const Color(0xfffc717f),
                        ),
                        child: AdaptiveText(
                          'DELETE',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21.0),
                          color: const Color(0xffb380f6),
                        ),
                        child: AdaptiveText(
                          'Update',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21.0),
                          color: const Color(0xffb9bbc5),
                        ),
                        child: AdaptiveText(
                          'Cancel',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value ?? false) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          ModalRoute.withName('/home'),
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
          ? Configuration().expenseColor
          : Colors.black,
      fontWeight: FontWeight.bold);

  Map<String, List<Transaction>> _buildTransactionMap(
      List<Transaction> transactions) {
    transactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final zz = transactions.reversed.toList();
    final map = zz.groupBy((e) => e.timestamp.split('T').first);
    return map;
  }

  Future<bool> _deleteTransaction(Transaction transaction) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.warning,
                        color: Colors.black,
                        size: 35,
                      ),
                      Text(
                        'Warning!!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          color: const Color(0xff1e1e1e),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      AdaptiveText(
                        'Are you sure you want to delete this category? Deleting the category will also clear all the records related to it.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: const Color(0xff43425d),
                          height: 1.5625,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          await TransactionService().deleteTransaction(
                              selectedSubSector, transaction);
                          Navigator.pop(context, true);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(21.0),
                            color: const Color(0xfffc717f),
                          ),
                          child: AdaptiveText(
                            'DELETE',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(21.0),
                            color: const Color(0xffb9bbc5),
                          ),
                          child: AdaptiveText(
                            'Cancel',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      return value;
    });
  }
}
