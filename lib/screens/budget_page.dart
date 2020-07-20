import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/icons/vector_icons.dart';
import 'package:MunshiG/models/budget/budget.dart';
import 'package:MunshiG/models/category/category.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/budget_service.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/transaction_service.dart';

import '../configuration.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage>
    with SingleTickerProviderStateMixin {
  int _currentYear = NepaliDateTime.now().year;
  int _currentMonth = NepaliDateTime.now().month;
  Lang language;
  TabController _tabController;
  String selectedSubSector;

  var _budgetAmountController = TextEditingController();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 12, vsync: this, initialIndex: _currentMonth - 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    selectedSubSector =
        Provider.of<SubSectorProvider>(context).selectedSubSector;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Configuration().appColor,
      drawer: MyDrawer(),
      appBar: AppBar(
        title: AdaptiveText('Cash Outflow Projection'),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Configuration().incomeColor,
          ),
          isScrollable: true,
          tabs: [
            for (int month = 1; month <= 12; month++)
              language == Lang.EN
                  ? Tab(
                      child: Text(NepaliDateFormat("MMMM ''yy").format(
                        NepaliDateTime(_currentYear, month),
                      )),
                    )
                  : Tab(
                      child: Text(
                        NepaliDateFormat("MMMM ''yy", Language.nepali).format(
                          NepaliDateTime(_currentYear, month),
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
          for (int month = 1; month <= 12; month++) _buildBody(month),
        ],
      ),
    );
  }

  Widget _buildBody(int month) {
    return Padding(
      padding: const EdgeInsets.only(top: 23.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            )),
        padding: const EdgeInsets.only(top: 30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: AdaptiveText(
                  selectedSubSector,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: const Color(0xff1e1e1e),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: CategoryService()
                      .getCategories(selectedSubSector, CategoryType.EXPENSE),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.separated(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 10 : 0,
                            bottom: index == snapshot.data.length - 1 ? 30 : 0,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.7))),
                            child: _buildCard(snapshot.data[index], month),
                          ),
                        ),
                        separatorBuilder: (context, _) =>
                            SizedBox(height: 20.0),
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

  Widget _buildCard(Category category, int month) {
    return FutureBuilder<Budget>(
      future: BudgetService().getBudget(selectedSubSector, category.id, month),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              PopupMenuButton<int>(
                color: Colors.white,
                onSelected: (value) async {
                  if (value == 1) {
                    _setBudgetDialog(snapshot.data, category,
                        action: snapshot.data.spent == null ? 'set' : 'update');
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _clearBudgetDialog(snapshot.data, category);
                      },
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: AdaptiveText(
                      snapshot.data.spent == null
                          ? 'Set Budget'
                          : 'Update Budget',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  if (snapshot.data.spent != null)
                    PopupMenuItem(
                      value: 2,
                      child: AdaptiveText(
                        'Clear Budget',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                ],
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 15, right: 15.0, top: 13, bottom: 13),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        VectorIcons.fromName(category.iconName,
                            provider: IconProvider.FontAwesome5),
                        size: 20.0,
                        color: Configuration().incomeColor,
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
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black),
                            ),
                            SizedBox(height: 2.0),
                            AdaptiveText(
                              (snapshot.data.total == null)
                                  ? 'Click to set budget'
                                  : 'Click to update budget',
                              style: TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            NepaliNumberFormat(
                                        decimalDigits: 0,
                                        language: (language == Lang.EN)
                                            ? Language.english
                                            : Language.nepali)
                                    .format(snapshot.data.spent ?? 0) +
                                '/',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Configuration().incomeColor,
                            ),
                          ),
                          Text(
                            NepaliNumberFormat(
                                    decimalDigits: 0,
                                    language: (language == Lang.EN)
                                        ? Language.english
                                        : Language.nepali)
                                .format(snapshot.data.total ?? 0),
                            style: TextStyle(
                              fontFamily: 'Poppins',
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
    int _total = int.tryParse(total ?? '0') ?? 0;
    int _spent = int.tryParse(spent ?? '0') ?? 0;
    if (_total == 0 && _spent == 0) return 1;
    if (_spent > _total) return 2;
    if (_total != 0 && _spent != 0) {
      return _spent / _total;
    }
    return 0.0;
  }

  Widget _clearBudgetDialog(Budget budget, Category category) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
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
              child: Text(
                language == Lang.EN
                    ? 'Are you sure to clear the budget for ${category.en}?'
                    : 'के तपाई ${category.np}को लागि बजेट खाली गर्न निश्चित हुनुहुन्छ?',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: InkWell(
                onTap: () async {
                  if (await TransactionService().isBudgetEditable(
                      selectedSubSector,
                      budget.categoryId,
                      budget.month,
                      NepaliDateTime.now().year)) {
                    await BudgetService()
                        .clearBudget(selectedSubSector, budget);
                  } else {
                    _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: AdaptiveText(
                            'Budget cannot be cleared as it is in use.'),
                      ),
                    );
                  }
                  setState(() {});
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21.0),
                    color: const Color(0xfffc717f),
                  ),
                  child: AdaptiveText(
                    'Clear Budget',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  var _formKey = GlobalKey<FormState>();

  void _setBudgetDialog(Budget oldBudgetData, Category category,
      {String action = 'set'}) {
    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    VectorIcons.fromName(category.iconName,
                        provider: IconProvider.FontAwesome5),
                    size: 30.0,
                    color: Configuration().incomeColor,
                  ),
                  SizedBox(height: 15.0),
                  AdaptiveText(
                    '',
                    category: category,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.7)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: (value) => value.length == 0
                              ? language == Lang.EN
                                  ? 'Cannot be empty'
                                  : 'खाली  हुनसक्दैन '
                              : null,
                          controller: _budgetAmountController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          style: TextStyle(color: Colors.grey, fontSize: 20.0),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 10.0,
                            ),
                            border: InputBorder.none,
                            hintText: language == Lang.EN
                                ? 'Enter budget amount'
                                : 'बजेट रकम लेख्नुहोस',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Configuration().incomeColor,
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _setBudget(oldBudgetData, category.id,
                              action: action),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: AdaptiveText(
                              action == 'set' ? 'SET BUDGET' : 'UPDATE BUDGET',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future _setBudget(Budget oldBudgetData, int categoryId,
      {String action = 'set'}) async {
    if (_formKey.currentState.validate()) {
      if (action == 'set') {
        await BudgetService().updateBudget(
          selectedSubSector,
          Budget(
            categoryId: oldBudgetData.categoryId ?? categoryId,
            month: oldBudgetData.month ?? _tabController.index + 1,
            spent: '0',
            total: _budgetAmountController.text,
          ),
        );
      } else {
        int amount = int.tryParse(_budgetAmountController.text) ?? 0;
        String spentString = (await BudgetService().getBudget(selectedSubSector,
                categoryId, oldBudgetData.month ?? _tabController.index + 1))
            .spent;
        int spent = int.tryParse(spentString ?? '0') ?? 0;
        if (amount > spent) {
          await BudgetService().updateBudget(
            selectedSubSector,
            Budget(
              categoryId: oldBudgetData.categoryId ?? categoryId,
              month: oldBudgetData.month ?? _tabController.index + 1,
              spent: spentString,
              total: _budgetAmountController.text,
            ),
          );
        } else {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: AdaptiveText('Budget amount is not enough.'),
            ),
          );
        }
      }
      Navigator.of(context, rootNavigator: true).pop();
      _budgetAmountController.clear();
      setState(() {});
    }
  }
}
