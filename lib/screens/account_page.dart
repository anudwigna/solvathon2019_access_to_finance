import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:MunshiG/models/account/account.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/account_service.dart';
import '../config/globals.dart';
import '../config/configuration.dart';
import '../components/extra_componenets.dart';
import '../icons/vector_icons.dart';
import '../screens/transaction_page.dart';
import '../services/app_page.dart';
import '../models/app_page_naming.dart';
import '../services/activity_tracking.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  int _currentBalance = 0;
  Lang language;
  var _accounts = <Account>[];
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _refreshBalance();
    WidgetsBinding.instance.addObserver(this);
    ActivityTracker()
        .pageTransactionActivity(PageName.account, action: 'Opened');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        ActivityTracker()
            .pageTransactionActivity(PageName.account, action: 'Paused');
        break;
      case AppLifecycleState.inactive:
        ActivityTracker()
            .pageTransactionActivity(PageName.account, action: 'Inactive');
        break;
      case AppLifecycleState.resumed:
        ActivityTracker()
            .pageTransactionActivity(PageName.account, action: 'Resumed');
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ActivityTracker()
        .pageTransactionActivity(PageName.account, action: 'Closed');
    super.dispose();
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
            // centerTitle: true,
            title: AdaptiveText(
              'Accounts',
              style: TextStyle(fontSize: 17),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            splashColor: const Color(0xff7635c7),
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
            child: Icon(
              Icons.add,
              size: 33,
              color: Configuration().appColor,
            ),
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
                              child: getBankAccountTypeIcon(
                                  _accounts[_index].type),
                              // child:
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
                                        _deleteDialog(_accounts[_index]);
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

  void _deleteDialog(Account account) {
    showDeleteDialog(context,
            title: 'Delete Account',
            deleteButtonText: 'Delete', onDeletePress: () async {
      if ((account.transactionIds?.length ?? 0) == 0) {
        await AccountService().deleteAccount(account, false);
        Navigator.of(context, rootNavigator: true).pop(true);
      } else {
        Navigator.of(context, rootNavigator: true).pop(false);
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: AdaptiveText(
              'Cannot delete! This account is linked with some transactions.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }, description: 'Are you sure you want to delete this account?')
        .then((value) {
      if (value ?? false) {
        _refreshBalance();
      }
    });
  }
}

///0=Person 1=Bank 2=Cash 3=Other
Widget getBankAccountTypeIcon(int accountTypeId, {bool isForm = false}) {
  switch (accountTypeId) {
    case 0:
      return Icon(
        VectorIcons.fromName('user-tie', provider: IconProvider.FontAwesome5),
        color: Configuration.accountIconColor,
        size: isForm ? 18 : 25,
      );
    case 1:
      return Icon(
        VectorIcons.fromName('university', provider: IconProvider.FontAwesome5),
        color: Configuration.accountIconColor,
        size: isForm ? 18 : 25,
      );
    case 2:
      return SvgPicture.string(
        cashIcon,
        fit: BoxFit.fill,
        height: isForm ? 14 : null,
        allowDrawingOutsideViewBox: false,
      );
    default:
      return Icon(
        VectorIcons.fromName('wallet', provider: IconProvider.FontAwesome5),
        color: Configuration.accountIconColor,
        size: isForm ? 18 : 25,
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
  List<Account> accounts;
  Lang language;
  @override
  void initState() {
    accounts = [
      Account(type: 0, name: 'Person'),
      Account(type: 1, name: 'Bank'),
      Account(type: 2, name: 'Cash'),
      Account(type: 3, name: 'Other')
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    language = Provider.of<PreferenceProvider>(context).language;
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 23),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
                            AdaptiveText(
                              'Account Type',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: const Color(0xff43425d),
                                height: 1.5625,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: _accountType,
                              isExpanded: true,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 15.0),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                              items: (accounts ?? [])
                                  .map(
                                    (e) => DropdownMenuItem(
                                      child: dropDownMenuBuilder(
                                          Icons.add, e.name,
                                          iconBuilderWidget:
                                              getBankAccountTypeIcon(e.type,
                                                  isForm: true)),
                                      value: e.type,
                                    ),
                                  )
                                  .toList(),
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              },
                              onChanged: (value) {
                                setState(() {
                                  _accountType = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: <Widget>[
                            SvgPicture.string(
                              userLogo,
                              allowDrawingOutsideViewBox: true,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            AdaptiveText(
                              'Enter Account Name',
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
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: <Widget>[
                            SvgPicture.string(
                              loadingIcon,
                              allowDrawingOutsideViewBox: true,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            AdaptiveText(
                              'Enter Opening Balance',
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
                        validator: (value) => value.isEmpty
                            ? language == Lang.EN
                                ? 'Balance Cannot be Empty'
                                : 'ब्यालेन्स खाली हुन सक्दैन'
                            : null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        controller: _openingBalanceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.0),
              FlatButton(
                color: Configuration().incomeColor,
                onPressed: _addAccount,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    AdaptiveText(
                      'Add Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }

  Future _addAccount() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (_formKey.currentState.validate()) {
      await AccountService().addAccount(
          Account(
              name: _accountNameController.text,
              balance: _openingBalanceController.text,
              type: _accountType,
              transactionIds: []),
          false);
      Navigator.pop(context, true);
    }
  }

  String validator(String value) {
    if (value.isEmpty) {
      return language == Lang.EN
          ? 'Name Cannot be empty'
          : 'नाम खाली हुनसक्दैन';
    } else if (widget.accounts.any((account) =>
        (account.name.toLowerCase() == value.toLowerCase() &&
            account.type == _accountType))) {
      return language == Lang.EN ? 'Account already exixts' : 'खाता पहिल्यै छ';
    }
    return null;
  }
}
