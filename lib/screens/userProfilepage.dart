import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:munshiji/components/adaptive_text.dart';
import 'package:munshiji/components/drawer.dart';
import 'package:munshiji/components/screen_size_config.dart';
import 'package:munshiji/configuration.dart';
import 'package:munshiji/models/user/user.dart';
import 'package:munshiji/screens/userinfoRegistrationPage.dart';
import 'package:munshiji/services/user_service.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User user;
  @override
  void initState() {
    super.initState();
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
              child: AdaptiveText(
                'Edit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          )),
        ],
      ),
      backgroundColor: Configuration().appColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: ScreenSizeConfig.blockSizeHorizontal * 10, right: 10),
            child: headerWidget(),
          ),
          SizedBox(
            height: 20,
          ),
          Divider(
            color: Colors.grey.withOpacity(0.2),
            thickness: 5,
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(
                left: ScreenSizeConfig.blockSizeHorizontal * 7, right: 10),
            child: detailsWidget(),
          ),
        ],
      ),
    );
  }

  headerWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 10,
                      style: BorderStyle.solid,
                      color: Colors.grey.withOpacity(0.19))),
              width: ScreenSizeConfig.blockSizeHorizontal * 40,
              height: ScreenSizeConfig.blockSizeVertical * 32,
              child: (user?.image != null)
                  ? (Image.file(
                      File(user.image),
                      fit: BoxFit.cover,
                    ))
                  : Image.asset(
                      'assets/image_placeholder.jpg',
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(
              width: 20,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user?.name?.split(' ')?.first ?? '',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          user?.name?.split(' ')?.last ?? '',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      user?.phonenumber ?? '',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600),
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
        detailbody(Icons.face, 'Gender', user?.gender ?? ''),
        detailbody(Icons.email, 'Address', user?.address ?? ''),
        detailbody(
            (user?.dob == null) ? Icons.calendar_today : Icons.event,
            'Date of Birth (B.S)',
            (user?.dob != null)
                ? (NepaliDateFormat("MMMM dd, y (EEE)")
                    .format(user.dob.toNepaliDateTime()))
                : ''),
        detailbody(
            (user?.dob == null) ? Icons.calendar_today : Icons.event,
            'Date of Birth (A.D)',
            (user?.dob != null)
                ? (DateFormat("MMMM dd, y (EEEE)").format(user.dob))
                : ''),
        detailbody(Icons.email, 'Email Address', user?.emailAddress ?? ''),
      ],
    );
  }

  detailbody(IconData icon, String title, String data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black, offset: Offset(0, 0), blurRadius: 3)
                ],
                shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                size: 20,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
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
              SizedBox(
                height: 3,
              ),
              Text(
                data ?? '',
                style: TextStyle(color: Colors.white, fontSize: 15),
              )
            ],
          )
        ],
      ),
    );
  }
}
