import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/icons/vector_icons.dart';
import 'package:MunshiG/models/budget/budget.dart';
import 'package:MunshiG/models/category/category.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/budget_service.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';

import '../components/extra_componenets.dart';
import '../config/configuration.dart';
import '../config/globals.dart';
import '../models/app_page_naming.dart';
import '../models/categoryHeading/categoryHeading.dart';
import '../services/activity_tracking.dart';
import '../services/category_heading_service.dart';

class BudgetPage extends StatefulWidget {
  final bool? isInflowProjection;

  const BudgetPage({Key? key, this.isInflowProjection}) : super(key: key);
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentYear = NepaliDateTime.now().year;
  int _currentMonth = NepaliDateTime.now().month;
  Lang? language;
  TabController? _tabController;
  String? selectedSubSector;
  final int noOfmonths = 132;
  late bool isInflow;
  var _budgetAmountController = TextEditingController();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _dateResolver = <NepaliDateTime>[];
  @override
  void initState() {
    isInflow = widget.isInflowProjection ?? false;
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ActivityTracker().pageTransactionActivity(widget.isInflowProjection! ? PageName.cashInflowProjection : PageName.cashOutflowProjection, action: 'Opened');
    initializeDateResolver();
    _tabController = TabController(length: noOfmonths, vsync: this, initialIndex: _currentMonth - 1);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        ActivityTracker().pageTransactionActivity(widget.isInflowProjection! ? PageName.cashInflowProjection : PageName.cashOutflowProjection, action: 'Paused');
        break;
      case AppLifecycleState.inactive:
        ActivityTracker().pageTransactionActivity(widget.isInflowProjection! ? PageName.cashInflowProjection : PageName.cashOutflowProjection, action: 'Inactive');
        break;
      case AppLifecycleState.resumed:
        ActivityTracker().pageTransactionActivity(widget.isInflowProjection! ? PageName.cashInflowProjection : PageName.cashOutflowProjection, action: 'Resumed');
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ActivityTracker().pageTransactionActivity(widget.isInflowProjection! ? PageName.cashInflowProjection : PageName.cashOutflowProjection, action: 'Closed');
    _tabController!.dispose();
    super.dispose();
  }

  initializeDateResolver() {
    // int _year = _currentYear;
    // int _firstMonth;
    // bool _incrementer;
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
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    selectedSubSector = Provider.of<SubSectorProvider>(context).selectedSubSector;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Configuration().appColor,
      drawer: MyDrawer(),
      appBar: AppBar(
        title: AdaptiveText(
          'Cash ' + (isInflow ? 'Inflow' : 'Outflow') + ' Projection',
          style: TextStyle(fontSize: 17),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (int index = 0; index < noOfmonths; index++)
              Tab(
                child: Text(
                  NepaliDateFormat("MMMM ''yy", language == Lang.EN ? Language.english : Language.nepali).format(
                    NepaliDateTime(_dateResolver[index].year, _dateResolver[index].month),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (int month = 0; month < noOfmonths; month++)
            _buildBody(
              _dateResolver[month].month,
              _dateResolver[month].year,
            ),
        ],
      ),
    );
  }

  Widget _buildBody(int month, int year) {
    return Padding(
      padding: const EdgeInsets.only(top: 23.0),
      child: Container(
        decoration: pageBorderDecoration,
        padding: const EdgeInsets.only(top: 30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: AdaptiveText(
                  selectedSubSector!,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xff1e1e1e),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: CategoryService().getCategories(selectedSubSector!, isInflow ? CategoryType.INCOME : CategoryType.EXPENSE),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.separated(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 10 : 0,
                            bottom: index == snapshot.data!.length - 1 ? 30 : 0,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.withOpacity(0.7))),
                            child: _buildCard(snapshot.data![index], month, year),
                          ),
                        ),
                        separatorBuilder: (context, _) => SizedBox(height: 20.0),
                      );
                    } else
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Category category, int month, int year) {
    return FutureBuilder<Budget>(
      future: BudgetService().getBudget(selectedSubSector!, category.id, month, year),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              PopupMenuButton<int>(
                color: Colors.white,
                onSelected: (value) async {
                  if (value == 1) {
                    _setBudgetDialog(snapshot.data, category, year, month, action: snapshot.data!.spent == null ? 'set' : 'update');
                  } else {
                    _clearBudgetDialog(snapshot.data, category);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: AdaptiveText(
                      snapshot.data!.spent == null ? 'Set Budget' : 'Update Budget',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  if (snapshot.data!.spent != null)
                    PopupMenuItem(
                      value: 2,
                      child: AdaptiveText(
                        'Clear Budget',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                ],
                child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 15.0, top: 13, bottom: 13),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FutureBuilder<CategoryHeading?>(
                        future: CategoryHeadingService().getCategoryHeadingById(widget.isInflowProjection! ? CategoryType.INCOME : CategoryType.EXPENSE,
                            category.categoryHeadingId == null ? (widget.isInflowProjection! ? 100 : 1) : category.categoryHeadingId),
                        builder: (BuildContext context, AsyncSnapshot<CategoryHeading?> snapshot1) {
                          return (!snapshot1.hasData)
                              ? Icon(
                                  VectorIcons.fromName(
                                    'hornbill',
                                    provider: IconProvider.FontAwesome5,
                                  ),
                                  color: Configuration().incomeColor,
                                  size: 20.0,
                                )
                              : SvgPicture.asset('assets/images/${snapshot1.data!.iconName}');
                        },
                      ),
                      SizedBox(width: 15.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AdaptiveText(
                              '',
                              category: category,
                              style: TextStyle(fontSize: 15.0, color: Colors.black),
                            ),
                            SizedBox(height: 2.0),
                            AdaptiveText(
                              (snapshot.data!.total == null) ? 'Click to set budget' : 'Click to update budget',
                              style: TextStyle(fontSize: 11.0, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            nepaliNumberFormatter(snapshot.data!.spent ?? 0) + '/',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Configuration().incomeColor,
                            ),
                          ),
                          Text(
                            nepaliNumberFormatter(snapshot.data!.total ?? 0),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Configuration().incomeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  double getProgressValue(String spent, String total) {
    int _total = int.tryParse(total) ?? 0;
    int _spent = int.tryParse(spent) ?? 0;
    if (_total == 0 && _spent == 0) return 1;
    if (_spent > _total) return 2;
    if (_total != 0 && _spent != 0) {
      return _spent / _total;
    }
    return 0.0;
  }

  void _clearBudgetDialog(Budget? budget, Category category) {
    showDeleteDialog(context,
            description: language == Lang.EN ? 'Are you sure to clear the budget for ${category.en}?' : 'के तपाई ${category.np}को लागि बजेट खाली गर्न निश्चित हुनुहुन्छ?',
            title: 'Clear Budget', onDeletePress: () async {
      if (await TransactionService().isBudgetEditable(selectedSubSector!, budget!.categoryId, budget.month, budget.year)) {
        await BudgetService().clearBudget(selectedSubSector!, budget, false);
        Navigator.of(context, rootNavigator: true).pop(true);
      } else {
        Navigator.of(context, rootNavigator: true).pop(false);
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: AdaptiveText(
              'Budget cannot be cleared as it is in use.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }, deleteButtonText: 'Clear  ')
        .then((value) {
      if (value ?? false) {
        setState(() {});
      }
    });
  }

  var _formKey = GlobalKey<FormState>();

  void _setBudgetDialog(Budget? oldBudgetData, Category category, int year, int month, {String action = 'set'}) {
    showFormDialog(
      context,
      buttonText: (action == 'set' ? 'Set' : 'Update') + ' Budget',
      onButtonPressed: () {
        if (_formKey.currentState!.validate()) {
          _setBudget(oldBudgetData, category.id, year, month, action: action).then((value) {
            _budgetAmountController.clear();
            Navigator.of(context, rootNavigator: true).pop(value);
          });
        }
      },
      title: language == Lang.EN ? category.en : category.np,
      bodyWidget: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            validator: (value) => value!.length == 0
                ? language == Lang.EN
                    ? 'Amount Cannot be empty'
                    : 'रकम खाली हुनसक्दैन '
                : null,
            controller: _budgetAmountController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: language == Lang.EN ? 'Budget amount' : 'बजेट रकम',
              labelStyle: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 15),
              contentPadding: const EdgeInsets.all(8.0),
            ),
          ),
        ),
      ),
    ).then((value) {
      if (value ?? false) {
        setState(() {});
      }
    });
  }

  Future<bool> _setBudget(Budget? oldBudgetData, int? categoryId, int year, int month, {String action = 'set'}) async {
    if (action == 'set') {
      await BudgetService().updateBudget(
          selectedSubSector,
          Budget(
            categoryId: oldBudgetData!.categoryId ?? categoryId,
            month: oldBudgetData.month ?? month,
            spent: '0',
            year: oldBudgetData.year ?? year,
            total: _budgetAmountController.text,
          ),
          false);
      return true;
    } else {
      int amount = int.tryParse(_budgetAmountController.text) ?? 0;
      String? spentString = (await BudgetService().getBudget(selectedSubSector!, categoryId, oldBudgetData!.month ?? month, oldBudgetData.year ?? year))

          ///--------------change yearrrrr
          .spent;
      // int spent = int.tryParse(spentString ?? '0') ?? 0;
      // if (amount > spent) {
      await BudgetService().updateBudget(
          selectedSubSector,
          Budget(
            categoryId: oldBudgetData.categoryId ?? categoryId,
            month: oldBudgetData.month ?? month,
            year: oldBudgetData.year ?? year,
            spent: spentString,
            total: _budgetAmountController.text,
          ),
          false);

      return true;
      // } else {
      //   _scaffoldKey.currentState.showSnackBar(
      //     SnackBar(
      //       backgroundColor: Colors.red,
      //       content: AdaptiveText(
      //         'Budget amount is not enough.',
      //         style: TextStyle(color: Colors.white),
      //       ),
      //     ),
      //   );
      //   return false;
      // }
    }
  }
}
