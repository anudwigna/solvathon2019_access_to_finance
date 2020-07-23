import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/icons/vector_icons.dart';
import 'package:MunshiG/models/account/account.dart';
import 'package:MunshiG/globals.dart' as globals;
import 'package:MunshiG/models/budget/budget.dart';
import 'package:MunshiG/models/category/category.dart';
import 'package:MunshiG/models/transaction/transaction.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/account_service.dart';
import 'package:MunshiG/services/budget_service.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/transaction_service.dart';
import '../configuration.dart';
import '../globals.dart';
import '../providers/preference_provider.dart';

class TransactionPage extends StatefulWidget {
  //0 = Income   1 = Expense
  final int transactionType;
  final Transaction transaction;
  final String selectedSubSector;

  TransactionPage(this.transactionType,
      {this.transaction, @required this.selectedSubSector});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TextEditingController _categoryName = TextEditingController();
  String selectedSubSector;
  Lang language;
  double fontsize = 15.0;
  BoxDecoration _decoration = BoxDecoration(
      border: Border.all(color: Colors.grey),
      color: Colors.white,
      borderRadius: BorderRadius.circular(5));
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _dropdownKey = GlobalKey();
  var _amountController = TextEditingController();
  var _descriptionController = TextEditingController();
  int _selectedCategoryId;
  File descriptonImage;
  Account _selectedAccount;
  NepaliDateTime _selectedDateTime = NepaliDateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedSubSector = widget.selectedSubSector;

    if (widget.transaction != null) {
      _selectedCategoryId = widget.transaction.categoryId;
      _amountController.text = widget.transaction.amount;
      _descriptionController.text = widget.transaction.memo;
      List<String> zz =
          widget.transaction.timestamp.split('T').first.split('-').toList();
      _selectedDateTime = NepaliDateTime(
        int.parse(zz[0]),
        int.parse(zz[1]),
        int.parse(zz[2]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff2b2f8e),
        title: widget.transaction != null
            ? AdaptiveText(
                'Update ${widget.transactionType == 0 ? 'Income' : 'Expense'}')
            : AdaptiveText(
                'Add ${widget.transactionType == 0 ? 'Income' : 'Expense'}'),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _buildBody()),
          ),
        ],
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
                  Expanded(
                    child: AdaptiveText(
                        (widget.transactionType == 1)
                            ? 'Expense Amount'
                            : 'Business Income',
                        style:
                            TextStyle(fontSize: fontsize, color: Colors.black)),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    key: new GlobalKey(),
                    width: (MediaQuery.of(context).size.width / 100) * 45,
                    padding: EdgeInsets.only(left: 12.0),
                    decoration: _decoration,
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (value) => value.length == 0
                            ? language == Lang.EN ? 'Required' : 'अनिवार्य'
                            : null,
                        autofocus: false,
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
                              fontSize: fontsize, color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //  if (widget.transaction == null)
              SizedBox(height: 20.0),
              //    if (widget.transaction == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: AdaptiveText(
                        (widget.transactionType == 1)
                            ? 'Expense Category'
                            : 'Source of Income',
                        style:
                            TextStyle(fontSize: fontsize, color: Colors.black)),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width / 100) * 45,
                    decoration: _decoration,
                    child: FutureBuilder<List<Category>>(
                      future: CategoryService().getCategories(
                        selectedSubSector,
                        widget.transactionType == 0
                            ? CategoryType.INCOME
                            : CategoryType.EXPENSE,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: IgnorePointer(
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
                                    return snapshot.data
                                        .map<Widget>((Category item) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(width: 5.0),
                                          Icon(
                                            VectorIcons.fromName(
                                              item.iconName,
                                              provider:
                                                  IconProvider.FontAwesome5,
                                            ),
                                            color: Colors.blue,
                                            size: fontsize,
                                          ),
                                          SizedBox(width: 10.0),
                                          Flexible(
                                            child: AdaptiveText(
                                              '',
                                              category: item,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: const Color(0xff272b37),
                                                height: 1.6666666666666667,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                  items: [
                                    for (int i = 0;
                                        i < snapshot.data.length;
                                        i++)
                                      DropdownMenuItem<int>(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(width: 5.0),
                                                  Icon(
                                                    VectorIcons.fromName(
                                                      snapshot.data[i].iconName,
                                                      provider: IconProvider
                                                          .FontAwesome5,
                                                    ),
                                                    color: Colors.blue,
                                                    size: fontsize,
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  Flexible(
                                                    child: AdaptiveText(
                                                      '',
                                                      category:
                                                          snapshot.data[i],
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 12,
                                                        color: const Color(
                                                            0xff272b37),
                                                        height:
                                                            1.6666666666666667,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Divider(
                                                  color: Colors.grey
                                                      .withOpacity(0.5))
                                            ],
                                          ),
                                        ),
                                        value: snapshot.data[i].id,
                                      ),
                                    (widget.transaction == null)
                                        ? DropdownMenuItem<int>(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SizedBox(width: 5.0),
                                                Icon(
                                                  Icons.create,
                                                  color: Colors.grey,
                                                  size: fontsize,
                                                ),
                                                SizedBox(width: 10.0),
                                                Flexible(
                                                  child: AdaptiveText(
                                                    'Add new Category',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 12,
                                                      color: const Color(
                                                          0xff272b37),
                                                      height:
                                                          1.6666666666666667,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            value: 'Add new Category'.hashCode,
                                          )
                                        : DropdownMenuItem<int>(
                                            child: Container())
                                  ],
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
                            ),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (widget.transaction == null)
                SizedBox(height: 20.0),
              if (widget.transaction == null)
                Row(
                  children: <Widget>[
                    if (language == Lang.EN)
                      Expanded(
                        child: Text(
                          widget.transactionType == 0
                              ? 'Deposited to:  '
                              : 'Paid from:  ',
                          style: TextStyle(
                              fontSize: fontsize, color: Colors.black),
                        ),
                      ),
                    Container(
                      width: (MediaQuery.of(context).size.width / 100) * 45,
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
                    if (language == Lang.NP)
                      Text(
                        widget.transactionType == 0
                            ? '  मा जम्मा गरियो '
                            : '  बाट तिरिएको',
                        style:
                            TextStyle(fontSize: fontsize, color: Colors.black),
                      ),
                  ],
                ),
              SizedBox(height: 20.0),
              AdaptiveText(
                  (widget.transactionType == 1)
                      ? 'Date of Expense'
                      : 'Date of Income',
                  style: TextStyle(fontSize: fontsize, color: Colors.black)),
              SizedBox(height: 5.0),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Material(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      if (widget.transaction != null) {
                        return;
                      }
                      _selectedDateTime = await showAdaptiveDatePicker(
                        context: context,
                        initialDate: NepaliDateTime.now(),
                        firstDate: NepaliDateTime(2073),
                        lastDate: NepaliDateTime(2090),
                        language: language == Lang.EN
                            ? Language.english
                            : Language.nepali,
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
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          AdaptiveText(
                            NepaliDateFormat(
                                    "MMMM dd, y (EEE)",
                                    language == Lang.EN
                                        ? Language.english
                                        : Language.nepali)
                                .format(_selectedDateTime),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: fontsize,
                            ),
                          ),
                          Expanded(child: Container()),
                          SvgPicture.string(
                            calendar,
                            allowDrawingOutsideViewBox: true,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              AdaptiveText('Description (Optional)',
                  style: TextStyle(fontSize: fontsize, color: Colors.black)),
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
                      suffixIcon: descriptonImage == null
                          ? InkWell(
                              onTap: () async {
                                bool callback =
                                    await checkPermission(_scaffoldKey);
                                if (!callback) {
                                  return;
                                }
                                try {
                                  final img = await ImagePicker()
                                      .getImage(source: ImageSource.gallery);
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
                                color: Colors.yellow,
                              ))
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Image.file(
                                descriptonImage,
                                fit: BoxFit.contain,
                                width: 60,
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
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15.0),
                      counterStyle: TextStyle(color: Colors.grey),
                    ),
                    buildCounter: (context,
                            {currentLength, isFocused, maxLength}) =>
                        Container(
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
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      color: Color(0xff2E4FFF)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.transaction == null
                          ? _addTransaction()
                          : _updateTransaction(),
                      borderRadius: BorderRadius.all(Radius.circular(21.0)),
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
                                TextStyle(fontSize: 15.0, color: Colors.white)),
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
          oldBudget = await BudgetService().getBudget(
              selectedSubSector,
              _selectedCategoryId,
              _selectedDateTime.month,
              _selectedDateTime.year);
          _spent = int.tryParse(oldBudget.spent ?? '0') ?? 0;
          _spent += int.tryParse(_amountController.text ?? '0') ?? 0;
          _total = int.tryParse(oldBudget.total ?? '0') ?? 0;
          if (_spent > _total) {
            await BudgetService().updateBudget(
              selectedSubSector,
              Budget(
                categoryId: _selectedCategoryId,
                month: _selectedDateTime.month,
                spent: '$_spent',
                year: _selectedDateTime.year,
                total: oldBudget.total,
              ),
            );
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
            );
            await _updateTransactionAndAccount(widget.transaction != null);
          }
        } else {
          await _updateTransactionAndAccount(widget.transaction != null);
        }
        String imageDir;
        if (descriptonImage != null) {
          Directory dir = await getApplicationSupportDirectory();
          String ext = descriptonImage.path.split('/').last.split('.').last;
          imageDir = dir.path +
              '/transaction' +
              _selectedDateTime.toIso8601String().toString() +
              "." +
              ext;
          try {
            await descriptonImage.copy(imageDir);
          } catch (e) {
            _scaffoldKey.currentState.removeCurrentSnackBar();
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text('Error, Image cannot be uploaded')));
            return;
          }
        }
        Navigator.pop(context, true);
      }
    }
  }

  Future _updateTransaction() async {
    if (_formKey.currentState.validate()) {
      Budget oldBudget;
      int _spent;
      int _total;
      if (widget.transactionType == 1) {
        oldBudget = await BudgetService().getBudget(
            selectedSubSector,
            widget.transaction.categoryId,
            _selectedDateTime.month,
            _selectedDateTime.year);
        _spent = int.tryParse(oldBudget.spent ?? '0') ?? 0;

        int checkExpense = (int.tryParse(widget.transaction.amount) ?? 0) -
            (int.tryParse(_amountController.text ?? '0') ?? 0);
        _spent -= checkExpense;
        _total = int.tryParse(oldBudget.total ?? '0') ?? 0;
        if (_spent > _total) {
          await BudgetService().updateBudget(
            selectedSubSector,
            Budget(
              categoryId: widget.transaction.categoryId,
              month: _selectedDateTime.month,
              spent: '$_spent',
              year: _selectedDateTime.year,
              total: oldBudget.total,
            ),
          );
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
          );
          await _updateTransactionAndAccount(widget.transaction != null);
        }
      } else {
        await _updateTransactionAndAccount(widget.transaction != null);
      }
      Navigator.pop(context, true);
    }
  }

  _updateTransactionAndAccount(bool isUpdate) async {
    int transactionId = await TransactionService().updateTransaction(
      selectedSubSector,
      Transaction(
        id: (widget.transaction != null) ? widget.transaction.id : null,
        amount: _amountController.text,
        categoryId:
            isUpdate ? widget.transaction.categoryId : _selectedCategoryId,
        memo: _descriptionController.text,
        month: isUpdate ? widget.transaction.month : _selectedDateTime.month,
        year: isUpdate ? widget.transaction.year : _selectedDateTime.year,
        transactionType: widget.transactionType,
        timestamp: isUpdate
            ? widget.transaction.timestamp
            : _selectedDateTime.toIso8601String(),
      ),
    );
    if (!isUpdate) {
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
    } else {
      int checkExpense = (int.tryParse(widget.transaction.amount) ?? 0) -
          (int.tryParse(_amountController.text ?? '0') ?? 0);
      Account ac =
          await AccountService().getAccountForTransaction(widget.transaction);
      if (ac != null) {
        await AccountService().updateAccount(
          Account(
            name: ac.name,
            type: ac.type,
            balance: widget.transactionType == 0
                ? '${int.parse(ac.balance) - checkExpense}'
                : '${int.parse(ac.balance) + checkExpense}',
            transactionIds: [
              if (ac.transactionIds != null) ...ac.transactionIds,
            ],
          ),
        );
      }
    }
  }

  _showMessage(String message) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: AdaptiveText(message)));
  }

  Future _showAddCategoryBottomSheet() async {
    GlobalKey<FormState> formKey = GlobalKey();
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    VectorIcons.fromName('hornbill',
                        provider: IconProvider.FontAwesome5),
                    color: Colors.grey,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
                Text(
                  language == Lang.EN
                      ? 'Enter new category'
                      : 'नयाँ श्रेणी लेख्नुहोस',
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.7)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextFormField(
                        validator: validator,
                        autofocus: false,
                        controller: _categoryName,
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 20.0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(8.0),
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
                        color: Configuration().incomeColor),
                    child: InkWell(
                      onTap: () async {
                        if (formKey.currentState.validate()) {
                          await CategoryService().addCategory(
                            selectedSubSector,
                            Category(
                              en: _categoryName.text,
                              np: _categoryName.text,
                              iconName: 'hornbill',
                              id: _categoryName.text.hashCode,
                            ),
                            type: widget.transactionType == 1
                                ? CategoryType.EXPENSE
                                : CategoryType.INCOME,
                          );
                          Navigator.pop(context);
                        }
                        _categoryName.clear();
                      },
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 18),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.add),
                            SizedBox(
                              width: 5,
                            ),
                            AdaptiveText(
                              'Add Category',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ],
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
    setState(() {});
  }

  String validator(String value) {
    var _value = value.toLowerCase();
    var categories = widget.transactionType == 0
        ? globals.expenseCategories
        : globals.incomeCategories;
    if (value.isEmpty) {
      return language == Lang.EN ? 'Category is empty' : 'श्रेणी खाली छ';
    } else if (categories.any((category) =>
        category.en.toLowerCase() == _value ||
        category.np.toLowerCase() == _value)) {
      return language == Lang.EN
          ? 'Category already exists!'
          : 'श्रेणी पहिल्यै छ';
    }
    return null;
  }
}
