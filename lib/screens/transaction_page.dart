import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import 'package:saral_lekha/components/adaptive_text.dart';
import 'package:saral_lekha/icons/vector_icons.dart';
import 'package:saral_lekha/models/account/account.dart';
import 'package:saral_lekha/models/budget/budget.dart';
import 'package:saral_lekha/models/category/category.dart';
import 'package:saral_lekha/models/transaction/transaction.dart';
import 'package:saral_lekha/providers/preference_provider.dart';
import 'package:saral_lekha/services/account_service.dart';
import 'package:saral_lekha/services/budget_service.dart';
import 'package:saral_lekha/services/category_service.dart';
import 'package:saral_lekha/services/transaction_service.dart';

import '../configuration.dart';
import '../providers/preference_provider.dart';

class TransactionPage extends StatefulWidget {
  //0 = Income   1 = Expense
  final int transactionType;
  final Transaction transaction;

  TransactionPage(this.transactionType, {this.transaction});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  Lang language;
  double fontsize = 15.0;
  BoxDecoration _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  );

  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  var _amountController = TextEditingController();
  var _descriptionController = TextEditingController();
  int _selectedCategoryId;
  Account _selectedAccount;
  NepaliDateTime _selectedDateTime = NepaliDateTime.now();

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    return Container(
      decoration: Configuration().gradientDecoration,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: widget.transaction != null
              ? AdaptiveText(
                  'Update ${widget.transactionType == 0 ? 'Income' : 'Expense'}')
              : AdaptiveText(
                  'Add ${widget.transactionType == 0 ? 'Income' : 'Expense'}'),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Text(
                      (language == Lang.EN)
                          ? (widget.transactionType == 1)
                              ? 'Expense Amount'
                              : 'Business Income'
                          : (widget.transactionType == 1)
                              ? 'खर्च रकम'
                              : 'व्यापार आय',
                      style: TextStyle(fontSize: fontsize)),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 12.0),
                      decoration: _decoration,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: (value) => value.length == 0
                              ? language == Lang.EN ? 'Required' : 'अनिवार्य'
                              : null,
                          autofocus: true,
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          style: TextStyle(
                              color: Colors.grey[800], fontSize: fontsize),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: language == Lang.EN
                                ? 'Enter amount'
                                : 'रकम लेख्नुहोस',
                            hintStyle: TextStyle(
                                color: Colors.grey, fontSize: fontsize),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.transaction == null) SizedBox(height: 20.0),
              if (widget.transaction == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                        (language == Lang.EN)
                            ? (widget.transactionType == 1)
                                ? 'Expense Category'
                                : 'Source of Income'
                            : (widget.transactionType == 1)
                                ? 'खर्च को वर्गीकरण'
                                : 'आय को स्रोत',
                        style: TextStyle(fontSize: fontsize)),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        decoration: _decoration,
                        child: FutureBuilder<List<Category>>(
                          future: CategoryService().getCategories(
                            widget.transactionType == 0
                                ? CategoryType.INCOME
                                : CategoryType.EXPENSE,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey[700],
                                    ),
                                    hint: AdaptiveText(
                                      (language == Lang.EN)
                                          ? 'Select Category'
                                          : 'वर्गीकरण गर्नुहोस्',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    value: _selectedCategoryId,
                                    items: [
                                      for (int i = 0;
                                          i < snapshot.data.length;
                                          i++)
                                        DropdownMenuItem<int>(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(
                                                VectorIcons.fromName(
                                                  snapshot.data[i].iconName,
                                                  provider:
                                                      IconProvider.FontAwesome5,
                                                ),
                                                color: Colors.grey,
                                                size: fontsize,
                                              ),
                                              SizedBox(width: 5.0),
                                              AdaptiveText(
                                                '',
                                                category: snapshot.data[i],
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          value: snapshot.data[i].id,
                                        ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                    },
                                  ),
                                ),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              if (widget.transaction == null) SizedBox(height: 20.0),
              if (widget.transaction == null)
                Row(
                  children: <Widget>[
                    if (language == Lang.EN)
                      Text(
                        widget.transactionType == 0
                            ? 'Deposited to:  '
                            : 'Pay from:  ',
                        style: TextStyle(fontSize: fontsize),
                      ),
                    Expanded(
                      child: Container(
                        decoration: _decoration,
                        child: FutureBuilder<List<Account>>(
                          future: AccountService().getAccounts(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Account>(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey[700],
                                    ),
                                    hint: AdaptiveText(
                                      'Select Account',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    value: _selectedAccount,
                                    items: [
                                      for (int i = 0;
                                          i < snapshot.data.length;
                                          i++)
                                        DropdownMenuItem<Account>(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(
                                                _accountTypeIcon(
                                                    snapshot.data[i].type),
                                                color: Colors.grey,
                                                size: fontsize,
                                              ),
                                              SizedBox(width: 5.0),
                                              AdaptiveText(
                                                '${snapshot.data[i].name}',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          value: snapshot.data[i],
                                        ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAccount = value;
                                      });
                                    },
                                  ),
                                ),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                    ),
                    if (language == Lang.NP)
                      Text(
                        widget.transactionType == 0
                            ? '  मा जम्मा गर्नुहोस'
                            : '  बाट तिर्नुहोस',
                        style: TextStyle(fontSize: fontsize),
                      ),
                  ],
                ),
              SizedBox(height: 20.0),
              Text((widget.transactionType == 1)
                  ? (language == Lang.EN) ? 'Date of Expense' : 'खर्चको मिति'
                  : (language == Lang.EN) ? 'Date of Income' : 'आयको मिति'),
              SizedBox(height: 5.0),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Material(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      _selectedDateTime = await showNepaliDatePicker(
                          context: context,
                          initialDate: NepaliDateTime.now(),
                          firstDate: NepaliDateTime(2070),
                          lastDate: NepaliDateTime(2090),
                          language: language == Lang.EN
                              ? Language.ENGLISH
                              : Language.NEPALI,
                          builder: (context, widget) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Configuration().redColor,
                                accentColor: Configuration().redColor,
                              ),
                              child: widget,
                            );
                          });
                      if (_selectedDateTime != null) {
                        setState(() {});
                      } else {
                        _selectedDateTime = NepaliDateTime.now();
                      }
                    },
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          AdaptiveText(
                            NepaliDateFormatter("MMMM dd, y (EEE)",
                                    language: language == Lang.EN
                                        ? Language.ENGLISH
                                        : Language.NEPALI)
                                .format(_selectedDateTime),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: fontsize,
                            ),
                          ),
                          Expanded(child: Container()),
                          Icon(
                            Icons.date_range,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                  language == Lang.EN
                      ? 'Description (optional)'
                      : 'विवरण (इच्छाधीन)',
                  style: TextStyle(fontSize: 15)),
              SizedBox(height: 5.0),
              Container(
                decoration: _decoration,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    style:
                        TextStyle(color: Colors.grey[800], fontSize: fontsize),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: language == Lang.EN
                          ? 'Enter description'
                          : 'विवरण लेख्नुहोस',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                      counterStyle: TextStyle(color: Colors.grey),
                    ),
                    maxLines: 3,
                    maxLength: 80,
                  ),
                ),
              ),
              SizedBox(height: 25.0),
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      // gradient: LinearGradient(
                      //   colors: Configuration().gradientColors,
                      //   begin: FractionalOffset.centerLeft,
                      //   end: FractionalOffset.centerRight,
                      // ),
                      color: Colors.white),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.transaction == null
                          ? _addTransaction()
                          : _updateTransaction(),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      child: Padding(
                        padding: EdgeInsets.all(14.0),
                        child: AdaptiveText(
                            widget.transaction == null
                                ? (language == Lang.EN)
                                    ? 'SUBMIT'
                                    : 'बुझाउनुहोस्'
                                : (language == Lang.EN)
                                    ? 'UPDATE'
                                    : 'अद्यावधिक गर्नुहोस्',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 17.0, color: Colors.black)),
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
  }

  IconData _accountTypeIcon(int value) {
    switch (value) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.account_balance;
      case 2:
        return Icons.monetization_on;
      default:
        return Icons.attach_money;
    }
  }

  Future _addTransaction() async {
    if (_formKey.currentState.validate()) {
      if (_selectedCategoryId == null) {
        _showMessage('Please select category.');
      } else if (_selectedAccount == null) {
        _showMessage('Please select account.');
      } else {
        var oldBudget;
        int _spent;
        int _total;
        if (widget.transactionType == 1) {
          oldBudget = await BudgetService()
              .getBudget(_selectedCategoryId, _selectedDateTime.month);
          _spent = int.tryParse(oldBudget.spent ?? '0') ?? 0;
          _spent += int.tryParse(_amountController.text ?? '0') ?? 0;
          _total = int.tryParse(oldBudget.total ?? '0') ?? 0;
          if (_spent > _total) {
            bool forcedUpdate = await _warnUser();
            if (forcedUpdate) {
              await BudgetService().updateBudget(
                Budget(
                  categoryId: _selectedCategoryId,
                  month: _selectedDateTime.month,
                  spent: '$_spent',
                  total: oldBudget.total,
                ),
              );
              await _updateTransactionAndAccount(widget.transaction != null);
              Navigator.pop(context);
            }
            return;
          } else {
            await BudgetService().updateBudget(
              Budget(
                categoryId: oldBudget.categoryId,
                month: oldBudget.month,
                spent: '$_spent',
                total: oldBudget.total,
              ),
            );
            await _updateTransactionAndAccount(widget.transaction != null);
          }
        } else {
          await _updateTransactionAndAccount(widget.transaction != null);
        }
        Navigator.pop(context);
      }
    }
  }

  Future _updateTransaction() async {
    if (_formKey.currentState.validate()) {
      var oldBudget;
      int _spent;
      int _total;
      if (widget.transactionType == 1) {
        oldBudget = await BudgetService()
            .getBudget(widget.transaction.categoryId, _selectedDateTime.month);
        _spent = int.tryParse(oldBudget.spent ?? '0') ?? 0;
        _spent += int.tryParse(_amountController.text ?? '0') ?? 0;
        _total = int.tryParse(oldBudget.total ?? '0') ?? 0;
        if (_spent > _total) {
          bool forcedUpdate = await _warnUser();
          if (forcedUpdate) {
            await BudgetService().updateBudget(
              Budget(
                categoryId: widget.transaction.categoryId,
                month: _selectedDateTime.month,
                spent: '$_spent',
                total: oldBudget.total,
              ),
            );
            await _updateTransactionAndAccount(widget.transaction != null);
            Navigator.pop(context);
          }
          return;
        } else {
          await BudgetService().updateBudget(
            Budget(
              categoryId: oldBudget.categoryId,
              month: oldBudget.month,
              spent: '$_spent',
              total: oldBudget.total,
            ),
          );
          await _updateTransactionAndAccount(widget.transaction != null);
        }
      } else {
        await _updateTransactionAndAccount(widget.transaction != null);
      }
    }
  }

  _updateTransactionAndAccount(bool isUpdate) async {
    int transactionId = await TransactionService().updateTransaction(
      Transaction(
        amount: _amountController.text,
        categoryId:
            isUpdate ? widget.transaction.categoryId : _selectedCategoryId,
        memo: _descriptionController.text,
        month: _selectedDateTime.month,
        year: _selectedDateTime.year,
        transactionType: widget.transactionType,
        timestamp: _selectedDateTime.toIso8601String(),
      ),
    );
    await AccountService().updateAccount(
      Account(
        name: _selectedAccount.name,
        type: _selectedAccount.type,
        balance: widget.transactionType == 0
            ? '${int.parse(_selectedAccount.balance) + int.parse(_amountController.text)}'
            : '${int.parse(_selectedAccount.balance) - int.parse(_amountController.text)}',
        transactionIds: [
          if (_selectedAccount.transactionIds != null)
            ..._selectedAccount.transactionIds,
          transactionId,
        ],
      ),
    );
  }

  Future<bool> _warnUser() async => await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AdaptiveText(
                  'Warning',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                IconButton(
                  icon: Transform.rotate(
                    angle: 40.0,
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 30.0,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
            content: AdaptiveText(
              'Budget is not enough for the transaction. Do you really want to add the transaction?',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              SimpleDialogOption(
                child: AdaptiveText(
                  'UPDATE BUDGET',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                  Navigator.pushNamed(
                    context,
                    '/budget',
                  );
                },
              ),
              SimpleDialogOption(
                child: AdaptiveText(
                  'OKAY',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          );
        },
      );

  _showMessage(String message) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: AdaptiveText(message)));
  }
}
