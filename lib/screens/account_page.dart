import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:provider/provider.dart';
import 'package:munshiji/components/adaptive_text.dart';
import 'package:munshiji/components/drawer.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:munshiji/models/account/account.dart';
import 'package:munshiji/providers/preference_provider.dart';
import 'package:munshiji/services/account_service.dart';
import '../globals.dart';
import '../configuration.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _currentBalance = 0;
  Lang language;
  var _accounts = <Account>[];
  // var _updatedBalanceController = TextEditingController();

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refreshBalance();
  }

  _refreshBalance() => AccountService().getAccounts().then(
        (accounts) {
          if (accounts != null) {
            _currentBalance = 0;
            accounts.forEach(
              (account) {
                _currentBalance += int.tryParse(account.balance) ?? 0;
              },
            );
            setState(() {});
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
      builder: (context, preferenceProvider, _) {
        language = preferenceProvider.language;
        return Scaffold(
          backgroundColor: Configuration().appColor,
          key: _scaffoldKey,
          drawer: MyDrawer(),
          appBar: AppBar(
            centerTitle: true,
            title: AdaptiveText('Accounts'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if ((await showDialog(
                    context: context,
                    builder: (context) =>
                        ChangeNotifierProvider<PreferenceProvider>(
                      builder: (context) => PreferenceProvider(),
                      child: _AccountDialog(_accounts),
                    ),
                  )) ??
                  false) {
                _refreshBalance();
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.white,
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                ),
                color: const Color(0xff7635c7),
              ),
              //  height: MediaQuery.of(context).size.shortestSide * 0.7,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AdaptiveText(
                      'Current Balance',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          _formatBalanceWithComma('$_currentBalance'),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 31,
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: AdaptiveText(
                            'NPR',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: const Color(0xffb182ec),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            FutureBuilder<List<Account>>(
              future: AccountService().getAccounts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.length < 0) {
                    return Container();
                  }
                  _accounts = snapshot.data;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _accounts.length,
                    itemBuilder: (context, index) {
                      int _index = _accounts.length - index - 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                              bottomLeft: Radius.circular(30.0),
                            ),
                            color: const Color(0xffffffff),
                          ),
                          child: ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.string(
                                cash,
                                allowDrawingOutsideViewBox: true,
                              ),
                            ),
                            title: AdaptiveText(
                              _accounts[_index].name ?? '',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: const Color(0xff272b37),
                                height: 1.4285714285714286,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            subtitle: AdaptiveText(
                              _accountType(_accounts[_index].type),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  _formatBalanceWithComma(
                                      _accounts[_index].balance),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    color: const Color(0xff1e1e1e),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Theme(
                                  data: Theme.of(context)
                                      .copyWith(cardColor: Colors.white),
                                  child: PopupMenuButton<int>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.grey,
                                    ),
                                    onSelected: (value) async {
                                      if (value == 1) {
                                        if ((await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  _deleteDialog(
                                                      _accounts[_index]),
                                            )) ??
                                            false) {
                                          _refreshBalance();
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 1,
                                        child: AdaptiveText(
                                          'Delete',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
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
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatBalanceWithComma(String balance) {
    if (balance.contains('-')) {
      return '-' +
          NepaliNumberFormat(
                  language: (language == Lang.EN)
                      ? Language.english
                      : Language.nepali)
              .format(double.parse(balance.substring(1)) ?? 0);
    } else
      return NepaliNumberFormat(
              language:
                  (language == Lang.EN) ? Language.english : Language.nepali)
          .format(balance ?? 0);
  }

  String _accountType(int value) {
    switch (value) {
      case 0:
        return 'Person';
      case 1:
        return 'Bank';
      case 2:
        return 'Cash';
      default:
        return 'Other';
    }
  }

  Widget _deleteDialog(Account account) {
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
                  AdaptiveText(
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
                    'Are you sure you want to delete this account?',
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
                      if ((account.transactionIds?.length ?? 0) == 0) {
                        await AccountService().deleteAccount(account);
                      } else {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: AdaptiveText(
                                'Cannot delete! This account is linked with some transactions.'),
                          ),
                        );
                      }
                      Navigator.of(context, rootNavigator: true).pop(true);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
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
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).pop(true),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
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
  }
}

class _AccountDialog extends StatefulWidget {
  final List<Account> accounts;

  _AccountDialog(this.accounts);

  @override
  __AccountDialogState createState() => __AccountDialogState();
}

class __AccountDialogState extends State<_AccountDialog> {
  // 0 = Person , 1 = Bank, 2 = Cash, 3 = Others
  int _accountType = 1;
  var _accountNameController = TextEditingController();
  var _openingBalanceController = TextEditingController();

  var _formKey = GlobalKey<FormState>();

  Lang language;

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.white),
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          AdaptiveText(
                            'Account Type: ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              color: const Color(0xff4b4b4d),
                              height: 1.25,
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: _accountType,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20.0),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    child: AdaptiveText(
                                      'Person',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20.0),
                                    ),
                                    value: 0,
                                  ),
                                  DropdownMenuItem(
                                    child: AdaptiveText(
                                      'Bank',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20.0),
                                    ),
                                    value: 1,
                                  ),
                                  DropdownMenuItem(
                                    child: AdaptiveText(
                                      'Cash',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20.0),
                                    ),
                                    value: 2,
                                  ),
                                  DropdownMenuItem(
                                    child: AdaptiveText(
                                      'Other',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20.0),
                                    ),
                                    value: 3,
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _accountType = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SvgPicture.string(
                                userLogo,
                                allowDrawingOutsideViewBox: true,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                language == Lang.EN
                                    ? 'Enter account name'
                                    : 'खाताको नाम लेख्नुहोस',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: const Color(0xff43425d),
                                  height: 1.5625,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextFormField(
                              validator: validator,
                              controller: _accountNameController,
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 20.0),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 20.0),
                                errorStyle: TextStyle(fontSize: 10.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              SvgPicture.string(
                                loading,
                                allowDrawingOutsideViewBox: true,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                language == Lang.EN
                                    ? 'Enter opening balance'
                                    : 'सुरुवाती रकम लेख्नुहोस',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: const Color(0xff43425d),
                                  height: 1.5625,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 20.0),
                            errorStyle: TextStyle(fontSize: 10.0),
                          ),
                          controller: _openingBalanceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          style: TextStyle(
                              color: Colors.grey[800], fontSize: 20.0),
                        ),
                      ),
                    ],
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
                      onTap: _addAccount,
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: AdaptiveText(
                          'ADD',
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
      ),
    );
  }

  Future _addAccount() async {
    if (_formKey.currentState.validate()) {
      await AccountService().addAccount(
        Account(
          name: _accountNameController.text,
          balance: _openingBalanceController.text,
          type: _accountType,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  String validator(String value) {
    if (value.isEmpty) {
      return language == Lang.EN ? '    Cannot be empty' : '    खाली हुनसक्दैन';
    } else if (widget.accounts.any((account) =>
        (account.name.toLowerCase() == value.toLowerCase() &&
            account.type == _accountType))) {
      return language == Lang.EN
          ? '    Account already exixts'
          : '    खाता पहिल्यै छ';
    }
    return null;
  }
}
