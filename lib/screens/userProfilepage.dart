import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/models/user/user.dart';
import 'package:MunshiG/screens/userinfoRegistrationPage.dart';
import 'package:MunshiG/services/user_service.dart';
import '../icons/vector_icons.dart';
import '../config/globals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/app_page_naming.dart';
import '../services/activity_tracking.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with WidgetsBindingObserver {
  User user;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ActivityTracker()
        .pageTransactionActivity(PageName.profile, action: 'Opened');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  getData() async {
    final data = await UserService().getAccounts();
    setState(() {
      user = data;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        ActivityTracker()
            .pageTransactionActivity(PageName.profile, action: 'Paused');
        break;
      case AppLifecycleState.inactive:
        ActivityTracker()
            .pageTransactionActivity(PageName.profile, action: 'Inactive');
        break;
      case AppLifecycleState.resumed:
        ActivityTracker()
            .pageTransactionActivity(PageName.profile, action: 'Resumed');
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ActivityTracker()
        .pageTransactionActivity(PageName.profile, action: 'Closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Center(
              child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => UserInfoRegistrationPage(
                            userData: user,
                          )))
                  .then((value) {
                getData();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset('assets/images/editIcon.png'),
            ),
          )),
        ],
      ),
      backgroundColor: Configuration().appColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 23.0),
        child: Container(
          height: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          padding: EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  headerWidget(),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.2),
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  detailsWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  headerWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: ScreenSizeConfig.blockSizeHorizontal * 35,
              height: ScreenSizeConfig.blockSizeVertical * 25,
              child: (File(user?.image ?? '').existsSync())
                  ? (Image.file(
                      File(user.image),
                      fit: BoxFit.contain
                    ))
                  : Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                          )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Image.asset(
                              'assets/images/image_placeholder.png',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          AdaptiveText(
                            'Upload your photo',
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          )
                        ],
                      ),
                    ),
            ),
            SizedBox(
              width: 20,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          user?.name?.split(' ')?.first ?? '',
                          maxLines: 2,
                          style: TextStyle(
                              height: 0,
                              fontSize: 19,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          user?.name?.split(' ')?.last ?? '',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 19,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(
                            Icons.call,
                            color: Colors.grey,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            user?.phonenumber ?? '',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  detailsWidget() {
    return Column(
      children: <Widget>[
        detailbody(genderIcon, 'Gender', user?.gender ?? ''),
        detailbody(addressIcon, 'Address', user?.address ?? ''),
        detailbody(
            dobIcon,
            'Date of Birth (B.S)',
            (user?.dob != null)
                ? (NepaliDateFormat("MMMM dd, y")
                    .format(user.dob.toNepaliDateTime()))
                : ''),
        detailbody(
            dobIcon,
            'Date of Birth (A.D)',
            (user?.dob != null)
                ? (DateFormat("MMMM dd, y").format(user.dob))
                : ''),
        detailbody(emailIcon, 'Email Address', user?.emailAddress ?? ''),
      ],
    );
  }

  detailbody(String icon, String title, String data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SvgPicture.string(
            icon,
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AdaptiveText(
                title,
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 15),
              ),
              Text(
                data ?? '',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              )
            ],
          )
        ],
      ),
    );
  }
}
