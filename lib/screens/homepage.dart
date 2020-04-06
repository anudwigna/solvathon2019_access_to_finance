import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import 'package:saral_lekha/components/adaptive_text.dart';
import 'package:saral_lekha/components/drawer.dart';
import 'package:saral_lekha/icons/vector_icons.dart';
import 'package:saral_lekha/models/category/category.dart';
import 'package:saral_lekha/models/transaction/transaction.dart';
import 'package:saral_lekha/providers/preference_provider.dart';
import 'package:saral_lekha/screens/transaction_page.dart';
import 'package:saral_lekha/services/category_service.dart';
import 'package:saral_lekha/services/transaction_service.dart';

import '../configuration.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Lang language;
  TabController _tabController;
  int _currentYear = NepaliDateTime.now().year;
  int _currentMonth = NepaliDateTime.now().month;

  var _dateResolver = <NepaliDateTime>[];

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initializeDateResolver();
    _tabController = TabController(
      length: 12,
      vsync: this,
      initialIndex: 9,
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
    return Container(
      decoration: Configuration().gradientDecoration,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: AdaptiveText("Finance Manager"),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              for (int index = 0; index < 12; index++)
                language == Lang.EN
                    ? Tab(
                        child: Text(
                          NepaliDateFormatter("MMMM ''yy").format(
                            NepaliDateTime(
                              _dateResolver[index].year,
                              _dateResolver[index].month,
                            ),
                          ),
                        ),
                      )
                    : Tab(
                        child: Text(
                          NepaliDateFormatter("MMMM ''yy",
                                  language: Language.NEPALI)
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
        drawer: MyDrawer(),
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

  Widget _buildBody(NepaliDateTime date) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Material(
            elevation: 5.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FutureBuilder<List<int>>(
                      future: TransactionService()
                          .getTotalIncomeExpense(date.year, date.month),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(
                            children: <Widget>[
                              AnimatedCircularChart(
                                size: Size(
                                    MediaQuery.of(context).size.width / 2,
                                    MediaQuery.of(context).size.width / 2),
                                initialChartData: <CircularStackEntry>[
                                  CircularStackEntry(
                                    [
                                      CircularSegmentEntry(
                                        _getIncomeFraction(
                                            snapshot.data[0], snapshot.data[1]),
                                        Configuration().yellowColor,
                                      ),
                                      CircularSegmentEntry(
                                        100 -
                                            _getIncomeFraction(snapshot.data[0],
                                                snapshot.data[1]),
                                        Colors.red,
                                      ),
                                    ],
                                  ),
                                ],
                                chartType: CircularChartType.Radial,
                                percentageValues: true,
                              ),
                              Positioned(
                                left: MediaQuery.of(context).size.width / 7,
                                top: MediaQuery.of(context).size.width / 7,
                                child: _centerWidget(date),
                              ),
                            ],
                          );
                        }
                        return Container();
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Material(
                            color: Configuration().yellowColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionPage(0),
                                    ),
                                  ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Icon(
                                        Icons.add,
                                        size: 20.0,
                                      ),
                                    ),
                                    Expanded(
                                      child: AdaptiveText(
                                        'Add Income',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Material(
                            color: Configuration().redColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionPage(1),
                                    ),
                                  ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(25.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Icon(
                                        Icons.add,
                                        size: 20.0,
                                      ),
                                    ),
                                    Expanded(
                                      child: AdaptiveText(
                                        'Add Expense',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.0),
                  ],
                ),
                Text(
                  language == Lang.EN
                      ? 'Overview for the month of  ${NepaliDateFormatter("MMMM").format(date)}'
                      : '${NepaliDateFormatter("MMMM", language: Language.NEPALI).format(date)} महिनाको विस्तृत सर्वेक्षण',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TransactionList(
            date: date,
            language: language,
          ),
        ),
      ],
    );
  }

  double _getIncomeFraction(int income, int expense) {
    if (income == 0 && expense == 0) {
      return 50;
    } else if (income == 0)
      return 0;
    else if (expense == 0)
      return 100;
    else {
      return income / (income + expense) * 100;
    }
  }

  Widget _centerWidget(NepaliDateTime date) {
    return FutureBuilder<List<int>>(
      future: TransactionService().getTotalIncomeExpense(date.year, date.month),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AdaptiveText(
                'Income',
                style: TextStyle(
                  color: Configuration().yellowColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                language == Lang.EN
                    ? NepaliNumber.formatWithComma('${snapshot.data[0]}')
                    : NepaliNumber.from(snapshot.data[0], true),
                style: TextStyle(
                  color: Configuration().yellowColor,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 10.0),
              AdaptiveText(
                'Expense',
                style: TextStyle(
                  color: Configuration().redColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                language == Lang.EN
                    ? NepaliNumber.formatWithComma('${snapshot.data[1]}')
                    : NepaliNumber.from(snapshot.data[1], true),
                style: TextStyle(
                  color: Configuration().redColor,
                  fontSize: 18.0,
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}

class TransactionList extends StatefulWidget {
  final NepaliDateTime date;
  final Lang language;

  TransactionList({this.date, this.language});

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  var _transactionMap = <int, List<Transaction>>{};
  var _updatedAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: TransactionService()
          .getTransactions(widget.date.year, widget.date.month),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Center(
              child: AdaptiveText('No Transactions'),
            );
          } else {
            _transactionMap = _buildTransactionMap(snapshot.data);
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  for (int i = 32; i > 0; i--)
                    if (_transactionMap.containsKey(i))
                      _dailyTransactionWidget(_transactionMap[i])
                ],
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
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
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(width: 8.0),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                    child: Text(
                      NepaliDateFormatter(
                        "MM/dd EE",
                        language: widget.language == Lang.EN
                            ? Language.ENGLISH
                            : Language.NEPALI,
                      ).format(
                        NepaliDateTime.parse(
                          dailyTransactions[0].timestamp,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey, height: 4.0),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: dailyTransactions.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _showTransactionDetail(dailyTransactions[index]),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            FutureBuilder<Category>(
                              future: CategoryService().getCategoryById(
                                dailyTransactions[index].categoryId,
                                dailyTransactions[index].transactionType,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                            color: dailyTransactions[index]
                                                        .transactionType ==
                                                    0
                                                ? Configuration().yellowColor
                                                : Configuration().redColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            VectorIcons.fromName(
                                              snapshot.data.iconName,
                                              provider:
                                                  IconProvider.FontAwesome5,
                                            ),
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        AdaptiveText(
                                          '',
                                          category: snapshot.data,
                                          style: getTextStyle(
                                              dailyTransactions[index]),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                            Expanded(child: Container()),
                            Text(
                              widget.language == Lang.EN
                                  ? NepaliNumber.formatWithComma(
                                      dailyTransactions[index].amount)
                                  : NepaliNumber.fromString(
                                      dailyTransactions[index].amount, true),
                              style: getTextStyle(dailyTransactions[index]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, _) => Divider(
                      height: 1.0,
                      color: Colors.grey[300],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(0.0),
          title: AdaptiveText(
            'Transaction Detail',
            style: TextStyle(
              color: Configuration().yellowColor,
              fontWeight: FontWeight.w300,
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
                  NepaliDateFormatter("MMMM dd, y (EEE)",
                          language: widget.language == Lang.EN
                              ? Language.ENGLISH
                              : Language.NEPALI)
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
                  widget.language == Lang.EN
                      ? NepaliNumber.formatWithComma(transaction.amount ?? '0')
                      : NepaliNumber.fromString(
                          transaction.amount ?? '0', true),
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                      ),
                      color: Configuration().redColor,
                      child: InkWell(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: AdaptiveText(
                            'DELETE',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () => _deleteTransaction(transaction),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Configuration().yellowColor,
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: AdaptiveText(
                            'UPDATE',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () => _updateTransaction(transaction),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: AdaptiveText(
                            'CANCEL',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _detailsRow(String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AdaptiveText(
          title,
          style: TextStyle(
            color: Configuration().yellowColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Configuration().redColor),
          ),
        ),
      ],
    );
  }

  TextStyle getTextStyle(Transaction transaction) => TextStyle(
        color: transaction.transactionType == 0
            ? Configuration().yellowColor
            : Configuration().redColor,
      );

  Map<int, List<Transaction>> _buildTransactionMap(
      List<Transaction> transactions) {
    var map = <int, List<Transaction>>{};
    transactions.forEach(
      (transaction) {
        int transactionDay = NepaliDateTime.parse(transaction.timestamp).day;
        if (map.containsKey(transactionDay)) {
          map[transactionDay].add(transaction);
        } else {
          map[transactionDay] = [transaction];
        }
      },
    );
    return map;
  }

  void _updateTransaction(Transaction transaction) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(
              transaction.id,
              transaction: transaction,
            ),
      ),
    );
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
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
                  child: AdaptiveText(
                    'Are you sure to delete this transaction?',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w300,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      color: Colors.red,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await TransactionService()
                              .deleteTransaction(transaction);
                          Navigator.pop(context, true);
                          Navigator.pop(context, true);
                          setState(() {});
                        },
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: AdaptiveText(
                            'DELETE',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
