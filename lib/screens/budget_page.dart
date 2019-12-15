import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import 'package:sampatti/components/adaptive_text.dart';
import 'package:sampatti/components/drawer.dart';
import 'package:sampatti/icons/vector_icons.dart';
import 'package:sampatti/models/budget/budget.dart';
import 'package:sampatti/models/category/category.dart';
import 'package:sampatti/providers/preference_provider.dart';
import 'package:sampatti/services/budget_service.dart';
import 'package:sampatti/services/category_service.dart';
import 'package:sampatti/services/transaction_service.dart';

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
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
      child: Container(
        decoration: Configuration().gradientDecoration,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: MyDrawer(),
          appBar: AppBar(
            title: AdaptiveText('Monthly Budget'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                for (int month = 1; month <= 12; month++)
                  language == Lang.EN
                      ? Tab(
                          child: Text(
                            NepaliDateFormatter("MMMM ''yy").format(
                              NepaliDateTime(_currentYear, month),
                            ),
                          ),
                        )
                      : Tab(
                          child: Text(
                            NepaliDateFormatter("MMMM ''yy",
                                    language: Language.NEPALI)
                                .format(
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
        ),
      ),
    );
  }

  Widget _buildBody(int month) {
    return FutureBuilder<List<Category>>(
      future: CategoryService().getCategories(CategoryType.EXPENSE),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    top: index == 0 ? 20 : 0,
                    bottom: index == snapshot.data.length - 1 ? 30 : 0,
                  ),
                  child: _buildCard(snapshot.data[index], month),
                ),
            separatorBuilder: (context, _) => SizedBox(height: 20.0),
          );
        } else
          return Center(
            child: CircularProgressIndicator(),
          );
      },
    );
  }

  Widget _buildCard(Category category, int month) {
    return FutureBuilder<Budget>(
      future: BudgetService().getBudget(category.id, month),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${language == Lang.EN ? NepaliNumber.formatWithComma(snapshot.data.spent ?? '0') : NepaliNumber.fromString(snapshot.data.spent ?? '0', true)} /',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300,
                      color: getProgressValue(
                                  snapshot.data.spent, snapshot.data.total) >
                              1
                          ? Colors.red[200]
                          : Colors.white,
                    ),
                  ),
                  Text(
                    '${language == Lang.EN ? NepaliNumber.formatWithComma(snapshot.data.total ?? '0') : NepaliNumber.fromString(snapshot.data.total ?? '0', true)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: getProgressValue(
                                  snapshot.data.spent, snapshot.data.total) >
                              1
                          ? Colors.red[200]
                          : Colors.white,
                    ),
                  ),
                  SizedBox(width: 25.0),
                ],
              ),
              Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.0),
                      child: InkWell(
                        onTap: snapshot.data.total != null
                            ? null
                            : () => _setBudgetDialog(snapshot.data, category,
                                action: snapshot.data.spent == null
                                    ? 'set'
                                    : 'update'),
                        borderRadius: BorderRadius.circular(14.0),
                        child: SizedBox(
                          height: 50.0,
                          child: LinearProgressIndicator(
                            value: getProgressValue(
                              snapshot.data.spent,
                              snapshot.data.total,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              getProgressValue(snapshot.data.spent,
                                          snapshot.data.total) >
                                      1
                                  ? Colors.red.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.2),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 26.0, right: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          VectorIcons.fromName(category.iconName,
                              provider: IconProvider.FontAwesome5),
                          size: 14.0,
                        ),
                        SizedBox(width: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AdaptiveText(
                              '',
                              category: category,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            if (snapshot.data.total == null) ...[
                              SizedBox(height: 5.0),
                              AdaptiveText(
                                'Click to set budget',
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ],
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        snapshot.data.total != null
                            ? Theme(
                                data: Theme.of(context)
                                    .copyWith(cardColor: Colors.white),
                                child: PopupMenuButton<int>(
                                  onSelected: (value) async {
                                    if (value == 1) {
                                      _setBudgetDialog(snapshot.data, category,
                                          action: 'update');
                                    } else {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return _clearBudgetDialog(
                                              snapshot.data, category);
                                        },
                                      );
                                      setState(() {});
                                    }
                                  },
                                  itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 1,
                                          child: AdaptiveText(
                                            'Update Budget',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 2,
                                          child: AdaptiveText(
                                            'Clear Budget',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        ),
                                      ],
                                ),
                              )
                            : Container(
                                height: 50.0,
                              ),
                      ],
                    ),
                  ),
                ],
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
              child: Text(
                language == Lang.EN
                    ? 'Are you sure to clear the budget for ${category.en}?'
                    : 'के तपाई ${category.np}को लागि बजेट खाली गर्न निश्चित हुनुहुन्छ?',
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
                      if (await TransactionService().isBudgetEditable(
                          budget.categoryId,
                          budget.month,
                          NepaliDateTime.now().year)) {
                        await BudgetService().clearBudget(budget);
                      } else {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: AdaptiveText(
                                'Budget cannot be cleared as it in use.'),
                          ),
                        );
                      }
                      Navigator.pop(context, true);
                    },
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: AdaptiveText(
                        'CLEAR BUDGET',
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 15.0),
                AdaptiveText(
                  '',
                  category: category,
                  style: TextStyle(
                    color: Colors.grey[700],
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
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
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
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 20.0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: language == Lang.EN
                              ? 'Enter budget amount'
                              : 'बजेट रकम लेख्नुहोस',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 20.0),
                          prefixIcon: Icon(
                            Icons.dialpad,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      gradient: LinearGradient(
                        colors: Configuration().gradientColors,
                        begin: FractionalOffset.centerLeft,
                        end: FractionalOffset.centerRight,
                      ),
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

  Future _setBudget(Budget oldBudgetData, int categoryId,
      {String action = 'set'}) async {
    if (_formKey.currentState.validate()) {
      if (action == 'set') {
        await BudgetService().updateBudget(
          Budget(
            categoryId: oldBudgetData.categoryId ?? categoryId,
            month: oldBudgetData.month ?? _tabController.index + 1,
            spent: '0',
            total: _budgetAmountController.text,
          ),
        );
      } else {
        int amount = int.tryParse(_budgetAmountController.text) ?? 0;
        String spentString = (await BudgetService().getBudget(
                categoryId, oldBudgetData.month ?? _tabController.index + 1))
            .spent;
        int spent = int.tryParse(spentString ?? '0') ?? 0;
        if (amount > spent) {
          await BudgetService().updateBudget(
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
      Navigator.pop(context);
      _budgetAmountController.clear();
      setState(() {});
    }
  }
}
