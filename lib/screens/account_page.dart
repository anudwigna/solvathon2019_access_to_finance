import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nepali_utils/nepali_utils.dart' as nu;
import 'package:provider/provider.dart';
import 'package:saral_lekha/components/adaptive_text.dart';
import 'package:saral_lekha/components/drawer.dart';
import 'package:saral_lekha/models/account/account.dart';
import 'package:saral_lekha/providers/preference_provider.dart';
import 'package:saral_lekha/services/account_service.dart';

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
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: Container(
            decoration: Configuration().gradientDecoration,
            child: Scaffold(
              key: _scaffoldKey,
              drawer: MyDrawer(),
              appBar: AppBar(
                title: AdaptiveText('Accounts'),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  if ((await showDialog(
                        context: context,
                        builder: (context) => _AccountDialog(_accounts),
                      )) ??
                      false) {
                    _refreshBalance();
                  }
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.white,
              ),
              body: _buildBody(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0),
            child: Material(
              color: Colors.white,
              shape: CircleBorder(),
              elevation: 5.0,
              child: Container(
                height: MediaQuery.of(context).size.shortestSide * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AdaptiveText(
                      'Current Balance',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 25.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      _formatBalanceWithComma('$_currentBalance'),
                      style: TextStyle(
                        color: Configuration().redColor,
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    AdaptiveText(
                      'NPR',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
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
                    return ListTile(
                      leading: Icon(_accountTypeIcon(_accounts[_index].type)),
                      title: AdaptiveText(
                        _accounts[_index].name ?? '',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      subtitle: AdaptiveText(
                        _accountType(_accounts[_index].type),
                        style: TextStyle(
                          fontSize: 10.0,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _formatBalanceWithComma(_accounts[_index].balance),
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          Theme(
                            data: Theme.of(context)
                                .copyWith(cardColor: Colors.white),
                            child: PopupMenuButton<int>(
                              onSelected: (value) async {
                                if (value == 1) {
                                  if ((await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            _deleteDialog(_accounts[_index]),
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
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    );
  }

  String _formatBalanceWithComma(String balance) {
    if (balance.contains('-')) {
      return '- ${language == Lang.EN ? nu.NepaliNumber.formatWithComma(balance.substring(1)) : nu.NepaliNumber.fromString(balance.substring(1), true)}';
    } else
      return language == Lang.EN
          ? nu.NepaliNumber.formatWithComma(balance)
          : nu.NepaliNumber.fromString(balance, true);
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

  // Widget _updateDialog(Account account) {
  //   return Theme(
  //     data: Theme.of(context).copyWith(canvasColor: Colors.white),
  //     child: Dialog(
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(32.0))),
  //       backgroundColor: Colors.white,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: <Widget>[
  //           Padding(
  //             padding: EdgeInsets.only(
  //                 top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
  //             child: TextFormField(
  //               controller: _updatedBalanceController,
  //               keyboardType: TextInputType.number,
  //               inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
  //               style: TextStyle(color: Colors.grey[800], fontSize: 20.0),
  //               decoration: InputDecoration(
  //                 border: InputBorder.none,
  //                 hintText: language == Lang.EN
  //                     ? 'Enter new balance'
  //                     : 'नयाँ रकम लेख्नुहोस',
  //                 hintStyle: TextStyle(color: Colors.grey, fontSize: 20.0),
  //                 prefixIcon: Icon(
  //                   Icons.dialpad,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(20.0),
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(30.0)),
  //                 gradient: LinearGradient(
  //                   colors: Configuration().gradientColors,
  //                   begin: FractionalOffset.centerLeft,
  //                   end: FractionalOffset.centerRight,
  //                 ),
  //               ),
  //               child: Material(
  //                 color: Colors.transparent,
  //                 child: InkWell(
  //                   onTap: () async {
  //                     await AccountService().updateAccount(
  //                       Account(
  //                         name: account.name,
  //                         balance: _updatedBalanceController.text,
  //                         type: account.type,
  //                       ),
  //                     );
  //                     Navigator.pop(context, true);
  //                   },
  //                   borderRadius: BorderRadius.all(Radius.circular(30.0)),
  //                   child: Padding(
  //                     padding: EdgeInsets.symmetric(vertical: 16.0),
  //                     child: AdaptiveText(
  //                       'UPDATE',
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(fontSize: 20.0),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
              child: AdaptiveText(
                'Are you sure to delete this account?',
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
                      Navigator.pop(context, true);
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
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        backgroundColor: Colors.white,
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
                          'Account Type',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20.0,
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
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextFormField(
                        validator: validator,
                        controller: _accountNameController,
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 20.0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: language == Lang.EN
                              ? 'Enter account name'
                              : 'खाताको नाम लेख्नुहोस',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 20.0),
                          errorStyle: TextStyle(fontSize: 10.0),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextFormField(
                        controller: _openingBalanceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 20.0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: language == Lang.EN
                              ? 'Enter opening balance'
                              : 'सुरुवाती रकम लेख्नुहोस',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 20.0),
                          prefixIcon: Icon(
                            Icons.dialpad,
                            color: Colors.grey,
                          ),
                        ),
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
