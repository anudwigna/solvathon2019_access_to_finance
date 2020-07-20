import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MunshiG/services/preference_service.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:MunshiG/components/screen_size_config.dart';
import 'package:MunshiG/configuration.dart';
import 'package:MunshiG/globals.dart';
import 'package:MunshiG/models/user/user.dart';
import 'package:MunshiG/screens/setting.dart';
import 'package:MunshiG/services/user_service.dart';

class UserInfoRegistrationPage extends StatefulWidget {
  final User userData;

  const UserInfoRegistrationPage({Key key, this.userData}) : super(key: key);
  @override
  _UserInfoRegistrationPageState createState() =>
      _UserInfoRegistrationPageState();
}

class _UserInfoRegistrationPageState extends State<UserInfoRegistrationPage> {
  GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  DateTime dateTime;
  List<String> genders = ['Male', 'Female', 'Other'];
  String genderValue = 'Male';
  int popId = 0;
  File image;
  OutlineInputBorder border = OutlineInputBorder(
      gapPadding: 0,
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.black, width: 1.5));
  TextStyle hintTextStyle = TextStyle(
      color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500);
  TextStyle titleStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      addressController.text = widget.userData?.address ?? '';
      dateTime = widget.userData?.dob ?? null;
      emailController.text = widget.userData?.emailAddress ?? '';
      genderValue = widget.userData?.gender ?? null;
      image =
          widget.userData?.image != null ? File(widget.userData.image) : null;
      fnameController.text = widget.userData?.name?.split(' ')?.first ?? '';
      lnameController.text = widget.userData?.name?.split(' ')?.last ?? '';
      phoneNumberController.text = widget.userData?.phonenumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Configuration().appColor.withOpacity(0.7),
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Configuration().appColor,
        title: AdaptiveText('Create Account'),
        centerTitle: true,
        actions: <Widget>[
          if (widget.userData == null)
            Center(
              child: InkWell(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  if (phoneNumberController.text.length < 10) {
                    _scaffoldKey.currentState.removeCurrentSnackBar();
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                            'Valid Phone Number must be added to Continue')));
                  } else {
                    addNewUser(User(phonenumber: '123456789'));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Skip',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Card(
                color: Colors.white,
                shadowColor: Colors.black,
                child: InkWell(
                    onTap: () async {
                      bool callback = await checkPermission(_scaffoldKey);
                      if (!callback) {
                        return;
                      }
                      final img = await ImagePicker()
                          .getImage(source: ImageSource.gallery);
                      if (img != null) {
                        image = File(img.path);
                        setState(() {});
                      }
                    },
                    child: Container(
                        width: double.maxFinite,
                        height: ScreenSizeConfig.blockSizeVertical * 25,
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenSizeConfig.blockSizeVertical * 10,
                            vertical: 20),
                        child: SizedBox(
                          width: double.maxFinite,
                          child: (image != null)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    image,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.tag_faces,
                                      size: ScreenSizeConfig.blockSizeVertical *
                                          8,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Add Your Photo\nHere',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                        ))),
              ),
              SizedBox(
                height: 15,
              ),
              Card(
                color: Colors.white,
                shadowColor: Colors.black,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenSizeConfig.blockSizeHorizontal * 5,
                      vertical: ScreenSizeConfig.blockSizeHorizontal * 6),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: bodyField(
                              controller: fnameController,
                              hintText: 'John',
                              title: 'First Name',
                              validator: (value) => value.trim.call().isEmpty
                                  ? "First Name Required"
                                  : null,
                            )),
                            SizedBox(
                              width: ScreenSizeConfig.blockSizeVertical * 3.5,
                            ),
                            Expanded(
                                child: bodyField(
                                    title: 'Last Name',
                                    hintText: 'Doe',
                                    validator: (value) =>
                                        value.trim.call().isEmpty
                                            ? "First Name Required"
                                            : null,
                                    controller: lnameController)),
                          ],
                        ),
                        SizedBox(
                          height: ScreenSizeConfig.blockSizeHorizontal * 4.5,
                        ),
                        bodyField(
                            controller: phoneNumberController,
                            textInputType: TextInputType.numberWithOptions(
                                decimal: false, signed: false),
                            hintText: '9818212123',
                            title: 'Phone Number',
                            maxlength: 10,
                            validator: (value) => value.trim.call().length < 10
                                ? "Invalid Phone Number"
                                : null),
                        SizedBox(
                          height: ScreenSizeConfig.blockSizeHorizontal * 4.5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AdaptiveText(
                                    'Date Of Birth'.toUpperCase(),
                                    style: titleStyle,
                                  ),
                                  SizedBox(
                                    height:
                                        ScreenSizeConfig.blockSizeHorizontal *
                                            2,
                                  ),
                                  dateField()
                                ],
                              ),
                            ),
                            SizedBox(
                              width: ScreenSizeConfig.blockSizeVertical * 3.5,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AdaptiveText(
                                    'Gender'.toUpperCase(),
                                    style: titleStyle,
                                  ),
                                  SizedBox(
                                    height:
                                        ScreenSizeConfig.blockSizeHorizontal *
                                            2,
                                  ),
                                  InputDecorator(
                                    decoration: InputDecoration(
                                        border: border,
                                        enabledBorder: border,
                                        disabledBorder: border,
                                        focusedBorder: border,
                                        errorBorder: OutlineInputBorder(
                                            gapPadding: 0,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 1.5)),
                                        contentPadding:
                                            const EdgeInsets.all(0)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5),
                                      child: DropdownButtonFormField<String>(
                                          isExpanded: false,
                                          validator: (value) {
                                            return value != null
                                                ? null
                                                : 'Gender Required';
                                          },
                                          value: genderValue,
                                          decoration: InputDecoration(
                                            hintText: 'Gender',
                                            hintStyle: hintTextStyle,
                                            border: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                          items: genders
                                              .map((e) =>
                                                  DropdownMenuItem<String>(
                                                      value: e,
                                                      child: Container(
                                                          child: Text(
                                                        e,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ))))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              genderValue = value;
                                            });
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenSizeConfig.blockSizeHorizontal * 4.5,
                        ),
                        bodyField(
                            controller: addressController,
                            hintText: 'Lagankhel, Lalitpur',
                            title: 'Address',
                            validator: (value) => value.trim.call().isEmpty
                                ? "Address Required"
                                : null),
                        SizedBox(
                          height: ScreenSizeConfig.blockSizeHorizontal * 4.5,
                        ),
                        bodyField(
                            controller: emailController,
                            hintText: 'hello@gmail.com',
                            title: 'Email Address',
                            validator: (value) => value.trim.call().isEmpty
                                ? "Email Address Required"
                                : null),
                        SizedBox(
                          height: ScreenSizeConfig.blockSizeHorizontal * 6,
                        ),
                        Container(
                          width: double.maxFinite,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color: Configuration().incomeColor,
                            onPressed: () async {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              if (dateTime == null) {}
                              if (_formKey.currentState.validate()) {
                                String imageDir;
                                if (image != null) {
                                  Directory dir =
                                      await getApplicationSupportDirectory();
                                  String ext = image.path
                                      .split('/')
                                      .last
                                      .split('.')
                                      .last;
                                  imageDir = dir.path +
                                      '/avatar' +
                                      DateTime.now()
                                          .toString()
                                          .replaceAll(' ', '') +
                                      "." +
                                      ext;
                                  try {
                                    await image.copy(imageDir);
                                  } catch (e) {
                                    _scaffoldKey.currentState
                                        .removeCurrentSnackBar();
                                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                                        content: Text(
                                            'Error, Image cannot be uploaded')));
                                    return;
                                  }
                                }
                                User user = User(
                                    address: addressController.text.trim(),
                                    dob: dateTime,
                                    emailAddress: emailController.text.trim(),
                                    gender: genderValue,
                                    image: (imageDir != null) ? imageDir : null,
                                    name: fnameController.text.trim() +
                                        ' ' +
                                        lnameController.text.trim(),
                                    phonenumber: phoneNumberController.text);
                                if (widget.userData == null) {
                                  addNewUser(user);
                                } else {
                                  await UserService().updateUser(user);
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                          ),
                        )
                      ],
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

  addNewUser(User user) async {
    PreferenceService.instance.setIsUserRegistered();
    await UserService().addUser(user);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Settings(
              type: 0,
            )));
  }

  dateField({bool isBsDate = false}) {
    return PopupMenuButton(
      color: Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: ListTile(
            title: Text(
              'B.S Date Picker',
              style: TextStyle(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(
            title: Text(
              'A.D Date Picker',
              style: TextStyle(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
      onSelected: (id) async {
        DateTime date = DateTime(1910);
        popId = id;
        if (id == 0) {
          NepaliDateTime date1 = await showAdaptiveDatePicker(
              context: context,
              initialDate: NepaliDateTime.now(),
              firstDate: date.toNepaliDateTime(),
              lastDate: NepaliDateTime.now());
          if (date1 != null) {
            dateTime = date1.toDateTime();
          }
        } else {
          final date1 = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: date,
              lastDate: DateTime.now());
          if (date1 != null) {
            dateTime = date1;
          }
        }
        setState(() {});
      },
      child: TextFormField(
        validator: (value) =>
            dateTime == null ? 'Date of Birth Required' : null,
        enabled: false,
        decoration: InputDecoration(
          errorStyle: TextStyle(color: Colors.red),
          hintMaxLines: 2,
          hintStyle: dateTime != null
              ? TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)
              : TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          hintText: (dateTime == null)
              ? 'D.O.B'
              : (popId == 0)
                  ? NepaliDateFormat("MMMM dd, y (EEE)").format(dateTime != null
                      ? dateTime.toNepaliDateTime()
                      : NepaliDateTime.now())
                  : DateFormat("MMMM dd, y (EEEE)")
                      .format(dateTime ?? DateTime.now()),
          border: border,
          enabledBorder: border,
          errorBorder: OutlineInputBorder(
              gapPadding: 0,
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 1.5)),
          disabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }

  bodyField(
      {String title,
      String hintText,
      String Function(String) validator,
      TextEditingController controller,
      int maxlength,
      TextInputType textInputType = TextInputType.text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AdaptiveText(
          title.toUpperCase(),
          style: titleStyle,
        ),
        SizedBox(
          height: ScreenSizeConfig.blockSizeHorizontal * 2,
        ),
        TextFormField(
          enabled: (maxlength == null) ||
              (maxlength != null && widget.userData?.phonenumber == null),
          buildCounter: (context, {currentLength, isFocused, maxLength}) =>
              Container(),
          keyboardType: textInputType,
          inputFormatters: maxlength != null
              ? [WhitelistingTextInputFormatter.digitsOnly]
              : [],
          maxLength: maxlength,
          style: TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: (maxlength != null)
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '+977 ',
                      style: hintTextStyle,
                    ),
                  )
                : null,
            prefixIconConstraints: BoxConstraints(
              maxWidth: (14 * 4.0),
            ),
            errorStyle: TextStyle(color: Colors.red),
            prefixStyle: TextStyle(color: Colors.grey),
            hintStyle: hintTextStyle,
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
            hintText: hintText,
            border: border,
            enabledBorder: border,
            disabledBorder: border,
            focusedBorder: border,
          ),
          validator: validator,
          controller: controller,
        )
      ],
    );
  }
}
