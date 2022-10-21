import 'dart:io';

import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/config/globals.dart' as globals;
import 'package:MunshiG/icons/vector_icons.dart';
import 'package:MunshiG/models/account/account.dart';
import 'package:MunshiG/models/budget/budget.dart';
import 'package:MunshiG/models/category/category.dart';
import 'package:MunshiG/models/transaction/transaction.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/account_service.dart';
import 'package:MunshiG/services/budget_service.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';

import '../config/configuration.dart';
import '../config/globals.dart';
import '../models/app_page_naming.dart';
import '../models/categoryHeading/categoryHeading.dart';
import '../providers/preference_provider.dart';
import '../screens/account_page.dart';
import '../screens/category_page.dart';
import '../services/activity_tracking.dart';
import '../services/category_heading_service.dart';

class TransactionPage extends StatefulWidget {
  //0 = Income   1 = Expense
  final int? transactionType;
  final Transaction? transaction;
  final String? selectedSubSector;
  // final NepaliDateTime dateTime;

  TransactionPage(
    this.transactionType, {
    this.transaction,
    required this.selectedSubSector,
  });

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with WidgetsBindingObserver {
  TextEditingController _categoryName = TextEditingController();
  String? selectedSubSector;
  Lang? language;
  double fontsize = 15.0;
  BoxDecoration _decoration = BoxDecoration(border: Border.all(color: Colors.grey), color: Colors.white, borderRadius: BorderRadius.circular(5));
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _dropdownKey = GlobalKey();
  var _amountController = TextEditingController();
  var _descriptionController = TextEditingController();
  int? _selectedCategoryId;
  File? descriptonImage;
  Account? _selectedAccount;
  NepaliDateTime? _selectedDateTime = NepaliDateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ActivityTracker().pageTransactionActivity(widget.transactionType == 0 ? PageName.addCashIn : PageName.addCashOut, action: 'Opened');
    selectedSubSector = widget.selectedSubSector;

    if (widget.transaction != null) {
      _selectedCategoryId = widget.transaction!.categoryId;
      _amountController.text = widget.transaction!.amount!;
      _descriptionController.text = widget.transaction!.memo!;
      List<String> zz = widget.transaction!.timestamp!.split('T').first.split('-').toList();
      _selectedDateTime = NepaliDateTime(
        int.parse(zz[0]),
        int.parse(zz[1]),
        int.parse(zz[2]),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        ActivityTracker().pageTransactionActivity(widget.transactionType == 0 ? PageName.addCashIn : PageName.addCashOut, action: 'Paused');
        break;
      case AppLifecycleState.inactive:
        ActivityTracker().pageTransactionActivity(widget.transactionType == 0 ? PageName.addCashIn : PageName.addCashOut, action: 'Inactive');
        break;
      case AppLifecycleState.resumed:
        ActivityTracker().pageTransactionActivity(widget.transactionType == 0 ? PageName.addCashIn : PageName.addCashOut, action: 'Resumed');
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ActivityTracker().pageTransactionActivity(widget.transactionType == 0 ? PageName.addCashIn : PageName.addCashOut, action: 'Closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        // centerTitle: true,
        backgroundColor: Color(0xff2b2f8e),
        title: widget.transaction != null
            ? AdaptiveText(
                'Update ${widget.transactionType == 0 ? 'Income' : 'Expense'}',
                style: TextStyle(fontSize: 17),
              )
            : AdaptiveText(
                'Add ${widget.transactionType == 0 ? 'Income' : 'Expense'}',
                style: TextStyle(fontSize: 17),
              ),
      ),
      body: Stack(
        children: [
          Container(
            height: ScreenSizeConfig.blockSizeHorizontal * 50,
            color: Color(0xff2b2f8e),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    )),
                padding: const EdgeInsets.only(top: 30),
                child: _buildBody()),
          ),
        ],
      ),
    );
  }

  incomeExpenseCategoryWidget() {
    return Container(
      decoration: _decoration,
      padding: EdgeInsets.only(left: 12.0),
      child: FutureBuilder<List<Category>>(
        future: CategoryService().getCategories(
          selectedSubSector!,
          widget.transactionType == 0 ? CategoryType.INCOME : CategoryType.EXPENSE,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return IgnorePointer(
              ignoring: widget.transaction != null,
              child: DropdownButtonHideUnderline(
                key: _dropdownKey,
                child: DropdownButton<int>(
                  isExpanded: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[700],
                  ),
                  hint: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: AdaptiveText(
                      'Select Category',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  value: _selectedCategoryId,
                  selectedItemBuilder: (BuildContext context) {
                    return snapshot.data!.map<Widget>((Category item) {
                      return dropDownMenuBuilder(
                          VectorIcons.fromName(
                            'hornbill',
                            provider: IconProvider.FontAwesome5,
                          ),
                          '',
                          category: item,
                          iconBuilderWidget: FutureBuilder<CategoryHeading?>(
                              future: CategoryHeadingService().getCategoryHeadingById(widget.transactionType == 0 ? CategoryType.INCOME : CategoryType.EXPENSE,
                                  item.categoryHeadingId == null ? (widget.transactionType == 0 ? 100 : 1) : item.categoryHeadingId),
                              builder: (BuildContext context, AsyncSnapshot<CategoryHeading?> snapshot) {
                                return (!snapshot.hasData)
                                    ? Icon(
                                        VectorIcons.fromName(
                                          'hornbill',
                                          provider: IconProvider.FontAwesome5,
                                        ),
                                        color: Configuration().incomeColor,
                                        size: 20.0,
                                      )
                                    : SvgPicture.asset('assets/images/${snapshot.data!.iconName}');
                              }));
                    }).toList();
                  },
                  items: [
                    for (int i = 0; i < snapshot.data!.length; i++)
                      DropdownMenuItem<int>(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              dropDownMenuBuilder(
                                VectorIcons.fromName(
                                  'hornbill',
                                  provider: IconProvider.FontAwesome5,
                                ),
                                '',
                                category: snapshot.data![i],
                                iconBuilderWidget: FutureBuilder<CategoryHeading?>(
                                  future: CategoryHeadingService().getCategoryHeadingById(widget.transactionType == 0 ? CategoryType.INCOME : CategoryType.EXPENSE,
                                      snapshot.data![i].categoryHeadingId == null ? (widget.transactionType == 0 ? 100 : 1) : snapshot.data![i].categoryHeadingId),
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
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Divider(color: Colors.grey.withOpacity(0.5))
                            ],
                          ),
                        ),
                        value: snapshot.data![i].id,
                      ),
                    (widget.transaction == null)
                        ? DropdownMenuItem<int>(
                            child: dropDownMenuBuilder(
                                VectorIcons.fromName(
                                  'plus-circle',
                                  provider: IconProvider.FontAwesome5,
                                ),
                                'Add New Category'),
                            value: 'Add new Category'.hashCode,
                          )
                        : DropdownMenuItem<int>(child: Container())
                  ],
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  onChanged: (value) {
                    if (value == 'Add new Category'.hashCode) {
                      _showAddCategoryBottomSheet();
                    } else {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    }
                  },
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // SizedBox(height: 20.0),
              AdaptiveText((widget.transactionType == 1) ? 'Expense Amount' : 'Business Income', style: TextStyle(fontSize: fontsize, color: Colors.black)),
              SizedBox(
                height: 5,
              ),
              Container(
                padding: EdgeInsets.only(left: 12.0),
                decoration: _decoration,
                child: TextFormField(
                  validator: (value) => value!.length == 0
                      ? language == Lang.EN
                          ? 'Amount Required'
                          : 'रकम अनिवार्य छ'
                      : null,
                  autofocus: false,
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: Colors.grey[800], fontSize: fontsize),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: language == Lang.EN ? 'Enter amount' : 'रकम लेख्नुहोस',
                  ),
                ),
              ),

              //  if (widget.transaction == null)
              SizedBox(height: 20.0),
              //    if (widget.transaction == null)
              AdaptiveText((widget.transactionType == 1) ? 'Expense Category' : 'Source of Income', style: TextStyle(fontSize: fontsize, color: Colors.black)),
              SizedBox(
                height: 5,
              ),
              incomeExpenseCategoryWidget(),

              if (widget.transaction == null) SizedBox(height: 20.0),
              if (widget.transaction == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (language == Lang.EN)
                      Text(
                        widget.transactionType == 0 ? 'Deposit to:  ' : 'Paid from:  ',
                        style: TextStyle(fontSize: fontsize, color: Colors.black),
                      ),
                    if (language == Lang.EN)
                      SizedBox(
                        height: 5,
                      ),
                    Container(
                      decoration: _decoration,
                      padding: EdgeInsets.only(left: 12.0),
                      child: FutureBuilder<List<Account>>(
                        future: AccountService().getAccounts(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButtonHideUnderline(
                              child: DropdownButton<Account>(
                                isExpanded: true,
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
                                  for (int i = 0; i < snapshot.data!.length; i++)
                                    DropdownMenuItem<Account>(
                                      child: dropDownMenuBuilder(
                                        Icons.add,
                                        snapshot.data![i].name,
                                        iconBuilderWidget: getBankAccountTypeIcon(snapshot.data![i].type, isForm: true),
                                      ),
                                      value: snapshot.data![i],
                                    ),
                                ],
                                onTap: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAccount = value;
                                  });
                                },
                              ),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                    if (language == Lang.NP)
                      SizedBox(
                        height: 5,
                      ),
                    if (language == Lang.NP)
                      Text(
                        widget.transactionType == 0 ? 'मा जम्मा गरियो ' : 'बाट तिरिएको',
                        style: TextStyle(fontSize: fontsize, color: Colors.black),
                      ),
                  ],
                ),
              SizedBox(height: 20.0),
              AdaptiveText((widget.transactionType == 1) ? 'Date of Expense' : 'Date of Income', style: TextStyle(fontSize: fontsize, color: Colors.black)),
              SizedBox(height: 5.0),
              Material(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    if (widget.transaction != null) {
                      return;
                    }
                    _selectedDateTime = await showAdaptiveDatePicker(
                      context: context,
                      initialDate: NepaliDateTime.now(),
                      firstDate: NepaliDateTime(2073),
                      lastDate: NepaliDateTime(2090),
                      language: language == Lang.EN ? Language.english : Language.nepali,
                    );
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
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Row(
                      children: <Widget>[
                        AdaptiveText(
                          NepaliDateFormat("MMMM dd, y (EE)", language == Lang.EN ? Language.english : Language.nepali).format(_selectedDateTime!),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: fontsize,
                          ),
                        ),
                        Expanded(child: Container()),
                        SvgPicture.string(
                          calendarIcon,
                          allowDrawingOutsideViewBox: true,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              AdaptiveText('Description (Optional)', style: TextStyle(fontSize: fontsize, color: Colors.black)),
              SizedBox(height: 5.0),
              Container(
                decoration: _decoration,
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(color: Colors.grey[800], fontSize: fontsize),
                    decoration: InputDecoration(
                      suffixIcon: descriptonImage == null
                          ? InkWell(
                              onTap: () async {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                bool callback = await checkPermission(_scaffoldKey);
                                if (!callback) {
                                  return;
                                }
                                try {
                                  final img = await ImagePicker().getImage(source: ImageSource.gallery);
                                  if (img != null) {
                                    setState(() {
                                      descriptonImage = File(img.path);
                                    });
                                  }
                                } catch (e) {
                                  print('err');
                                }
                              },
                              child: Icon(
                                Icons.attach_file,
                                color: Configuration.accountIconColor,
                              ))
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0, right: 8),
                              child: Image.file(
                                descriptonImage!,
                                fit: BoxFit.contain,
                                width: 50,
                              ),
                            ),
                      border: InputBorder.none,
                      hintText: (widget.transactionType == 1)
                          ? language == Lang.EN
                              ? 'Enter description (Optional)'
                              : 'खर्च सम्बन्धि थप विवरण भए लेखुहोस्'
                          : language == Lang.EN
                              ? 'Enter description (Optional)'
                              : 'खर्च सम्बन्धि थप विवरण भए लेखुहोस्',
                      counterStyle: TextStyle(color: Colors.grey),
                    ),
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => Container(
                      height: 1,
                      width: 1,
                    ),
                    maxLines: 4,
                    maxLength: 80,
                  ),
                ),
              ),
              SizedBox(height: 25.0),
              Center(
                child: TextButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => Configuration().incomeColor)),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    widget.transaction == null ? _addTransaction() : _updateTransaction();
                  },
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
                        style: TextStyle(fontSize: 15.0, color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Future _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        _showMessage('Please select category.');
      } else if (_selectedAccount == null) {
        _showMessage('Please select account.');
      } else {
        Budget oldBudget;
        int _spent;
        int _total;
        if (widget.transactionType == 1) {
          oldBudget = await BudgetService().getBudget(selectedSubSector!, _selectedCategoryId, _selectedDateTime!.month, _selectedDateTime!.year);
          _spent = int.tryParse(oldBudget.spent ?? '0') ?? 0;
          _spent += int.tryParse(_amountController.text) ?? 0;
          _total = int.tryParse(oldBudget.total ?? '0') ?? 0;
          if (_spent > _total) {
            await BudgetService().updateBudget(
                selectedSubSector,
                Budget(
                  categoryId: _selectedCategoryId,
                  month: _selectedDateTime!.month,
                  spent: '$_spent',
                  year: _selectedDateTime!.year,
                  total: oldBudget.total,
                ),
                true);
            await _updateTransactionAndAccount(widget.transaction != null);
          } else {
            await BudgetService().updateBudget(
                selectedSubSector,
                Budget(
                  categoryId: oldBudget.categoryId,
                  month: oldBudget.month,
                  spent: '$_spent',
                  year: oldBudget.year,
                  total: oldBudget.total,
                ),
                true);
            await _updateTransactionAndAccount(widget.transaction != null);
          }
        } else {
          oldBudget = await BudgetService().getBudget(selectedSubSector!, _selectedCategoryId, _selectedDateTime!.month, _selectedDateTime!.year);
          _spent = int.tryParse(oldBudget.spent ?? '0') ?? 0;
          _spent += int.tryParse(_amountController.text) ?? 0;
          _total = int.tryParse(oldBudget.total ?? '0') ?? 0;
          await BudgetService().updateBudget(
              selectedSubSector,
              Budget(
                categoryId: _selectedCategoryId,
                month: _selectedDateTime!.month,
                spent: '$_spent',
                year: _selectedDateTime!.year,
                total: oldBudget.total,
              ),
              true);
          await _updateTransactionAndAccount(widget.transaction != null);
        }
        String? imageDir;
        if (descriptonImage != null) {
          try {
            imageDir = (await Configuration().saveImage(descriptonImage!, 'transaction', _selectedDateTime!.toIso8601String()))!.path;
          } catch (e) {
            ScaffoldMessenger.of(_scaffoldKey.currentState!.context).removeCurrentSnackBar();
            ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(SnackBar(content: Text('Error, Image cannot be uploaded')));
            return;
          }
        }
        Navigator.pop(context, true);
      }
    }
  }

  Future _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      Budget oldBudget;
      int _spent;
      int _total;
      if (widget.transactionType == 1) {
        oldBudget = await BudgetService().getBudget(selectedSubSector!, widget.transaction!.categoryId, _selectedDateTime!.month, _selectedDateTime!.year);
        _spent = int.tryParse(oldBudget.spent ?? '0') ?? 0;
        int checkExpense = (int.tryParse(widget.transaction!.amount!) ?? 0) - (int.tryParse(_amountController.text) ?? 0);
        _spent -= checkExpense;
        _total = int.tryParse(oldBudget.total ?? '0') ?? 0;
        if (_spent > _total) {
          await BudgetService().updateBudget(
              selectedSubSector,
              Budget(
                categoryId: widget.transaction!.categoryId,
                month: _selectedDateTime!.month,
                spent: '$_spent',
                year: _selectedDateTime!.year,
                total: oldBudget.total,
              ),
              false);
          await _updateTransactionAndAccount(widget.transaction != null);
        } else {
          await BudgetService().updateBudget(
              selectedSubSector,
              Budget(
                categoryId: oldBudget.categoryId,
                month: oldBudget.month,
                spent: '$_spent',
                year: oldBudget.year,
                total: oldBudget.total,
              ),
              false);
          await _updateTransactionAndAccount(widget.transaction != null);
        }
      } else {
        oldBudget = await BudgetService().getBudget(selectedSubSector!, widget.transaction!.categoryId, _selectedDateTime!.month, _selectedDateTime!.year);
        _spent = int.tryParse(oldBudget.spent ?? '0') ?? 0;
        int checkExpense = (int.tryParse(widget.transaction!.amount!) ?? 0) - (int.tryParse(_amountController.text) ?? 0);
        _spent -= checkExpense;
        _total = int.tryParse(oldBudget.total ?? '0') ?? 0;

        await BudgetService().updateBudget(
            selectedSubSector,
            Budget(
              categoryId: widget.transaction!.categoryId,
              month: _selectedDateTime!.month,
              spent: '$_spent',
              year: _selectedDateTime!.year,
              total: oldBudget.total,
            ),
            false);

        await _updateTransactionAndAccount(widget.transaction != null);
      }
      Navigator.pop(context, true);
    }
  }

  _updateTransactionAndAccount(bool isUpdate) async {
    int? transactionId = await TransactionService().updateTransaction(
        selectedSubSector!,
        Transaction(
          id: (widget.transaction != null) ? widget.transaction!.id : null,
          amount: _amountController.text,
          categoryId: isUpdate ? widget.transaction!.categoryId : _selectedCategoryId,
          memo: _descriptionController.text,
          month: isUpdate ? widget.transaction!.month : _selectedDateTime!.month,
          year: isUpdate ? widget.transaction!.year : _selectedDateTime!.year,
          transactionType: widget.transactionType,
          timestamp: isUpdate ? widget.transaction!.timestamp : _selectedDateTime!.toIso8601String(),
        ),
        false);
    if (!isUpdate) {
      await AccountService().updateAccount(
          Account(
            name: _selectedAccount!.name,
            type: _selectedAccount!.type,
            balance: widget.transactionType == 0
                ? '${int.parse(_selectedAccount!.balance!) + int.parse(_amountController.text)}'
                : '${int.parse(_selectedAccount!.balance!) - int.parse(_amountController.text)}',
            transactionIds: [
              if (_selectedAccount!.transactionIds != null) ..._selectedAccount!.transactionIds!,
              transactionId,
            ],
          ),
          true);
    } else {
      int checkExpense = (int.tryParse(widget.transaction!.amount!) ?? 0) - (int.tryParse(_amountController.text) ?? 0);
      Account? ac = await AccountService().getAccountForTransaction(widget.transaction);
      if (ac != null) {
        await AccountService().updateAccount(
            Account(
              name: ac.name,
              type: ac.type,
              balance: widget.transactionType == 0 ? '${int.parse(ac.balance!) - checkExpense}' : '${int.parse(ac.balance!) + checkExpense}',
              transactionIds: [
                if (ac.transactionIds != null) ...ac.transactionIds!,
              ],
            ),
            true);
      }
    }
  }

  _showMessage(String message) {
    ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(SnackBar(content: AdaptiveText(message)));
  }

  Future _showAddCategoryBottomSheet() async {
    if ((await showDialog(
          context: context,
          builder: (context) => Consumer<PreferenceProvider>(
            builder: (context, a, b) => CategoryDialog(
              isCashIn: widget.transactionType == 0,
            ),
          ),
        )) ??
        false) {
      setState(() {});
    }
  }

  String? validator(String value) {
    var _value = value.toLowerCase();
    var categories = widget.transactionType == 0 ? globals.expenseCategories : globals.incomeCategories;
    if (value.isEmpty) {
      return language == Lang.EN ? 'Category is empty' : 'श्रेणी खाली छ';
    } else if (categories!.any((category) => category.en!.toLowerCase() == _value || category.np!.toLowerCase() == _value)) {
      return language == Lang.EN ? 'Category already exists!' : 'श्रेणी पहिल्यै छ';
    }
    return null;
  }
}

Widget dropDownMenuBuilder(IconData leadingIcon, String? title, {Category? category, Widget? iconBuilderWidget}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      SizedBox(width: 5.0),
      iconBuilderWidget == null
          ? Icon(
              leadingIcon,
              color: Configuration.accountIconColor,
              size: 18,
            )
          : iconBuilderWidget,
      SizedBox(width: 10.0),
      Flexible(
        child: AdaptiveText(
          category != null ? '' : title!,
          category: category,
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontFamily: 'SourceSansPro',
            fontSize: 15,
            color: const Color(0xff272b37),
            height: 1.6666666666666667,
          ),
        ),
      ),
    ],
  );
}
