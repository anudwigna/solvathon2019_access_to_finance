import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/providers/preference_provider.dart';

import '../configuration.dart';

import '../providers/preference_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _formKey = GlobalKey<FormState>();
  // Country _selectedCountry = Country(
  //   isoCode: "NP",
  //   phoneCode: "977",
  //   name: "Nepal",
  //   iso3Code: "NPL",
  // );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Configuration().gradientDecoration,
      child: Scaffold(
        body: Consumer<PreferenceProvider>(
          builder: (context, preferenceProvider, _) =>
              _buildBody(preferenceProvider.language),
        ),
      ),
    );
  }

  Widget _buildBody(Lang language) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _spacing(2),
            Image.asset(
              'assets/MunshiG_logo.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 10.0),
            AdaptiveText(
              'MunshiG',
              style: TextStyle(
                fontWeight: FontWeight.w100,
                fontSize: 30.0,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            _spacing(2),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: <Widget>[
            //     Material(
            //       elevation: 5.0,
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(20.0),
            //       child: InkWell(
            //         onTap: _openCountryPickerDialog,
            //         borderRadius: BorderRadius.circular(20.0),
            //         child: Padding(
            //           padding: EdgeInsets.symmetric(
            //             horizontal: 12.0,
            //             vertical: 16.0,
            //           ),
            //           child: Row(
            //             mainAxisSize: MainAxisSize.min,
            //             children: <Widget>[
            //               CountryPickerUtils.getDefaultFlagImage(
            //                   _selectedCountry),
            //               SizedBox(width: 8.0),
            //               Text(
            //                 '+${_selectedCountry.phoneCode}',
            //                 style: TextStyle(
            //                   color: Colors.black,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: 8.0),
            //     Expanded(
            //       child: Material(
            //         elevation: 5.0,
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(20.0),
            //         child: Padding(
            //           padding:
            //               EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
            //           child: TextFormField(
            //             decoration: InputDecoration(
            //               border: InputBorder.none,
            //               hintText: language == Lang.EN
            //                   ? 'Enter Phone Number'
            //                   : 'फोन नम्बर लेख्नुहोस',
            //               hintStyle: TextStyle(
            //                 color: Colors.grey[700],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: 40.0),
            // Material(
            //   elevation: 5.0,
            //   color: Colors.transparent,
            //   borderRadius: BorderRadius.circular(20.0),
            //   child: Ink(
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         colors: Configuration().gradientColors,
            //         begin: FractionalOffset.centerLeft,
            //         end: FractionalOffset.centerRight,
            //       ),
            //       borderRadius: BorderRadius.circular(20.0),
            //     ),
            //     child: InkWell(
            //       onTap: () {},
            //       borderRadius: BorderRadius.circular(20.0),
            //       child: Padding(
            //         padding: EdgeInsets.symmetric(vertical: 16.0),
            //         child: AdaptiveText(
            //           'REGISTER',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 16.0,
            //             fontWeight: FontWeight.bold,
            //           ),
            //           textAlign: TextAlign.center,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(height: 40.0),
            // Row(
            //   children: <Widget>[
            //     Expanded(child: Divider(color: Colors.white)),
            //     Text(
            //       "    OR    ",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //     Expanded(child: Divider(color: Colors.white)),
            //   ],
            // ),
            // SizedBox(height: 40.0),
            Material(
              elevation: 5.0,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
              child: Ink(
                decoration: BoxDecoration(
                  color: Configuration().appColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: InkWell(
                  onTap: _warnUser,
                  borderRadius: BorderRadius.circular(20.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: AdaptiveText(
                      'LOGIN AS GUEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            _spacing(2),
          ],
        ),
      ),
    );
  }

  Widget _spacing(int fraction) => Flexible(flex: fraction, child: Container());

  // void _openCountryPickerDialog() => showDialog(
  //       context: context,
  //       builder: (context) => Theme(
  //         data: Theme.of(context).copyWith(
  //           canvasColor: Colors.white,
  //           cardColor: Colors.white,
  //           brightness: Brightness.light,
  //         ),
  //         child: CountryPickerDialog(
  //           titlePadding: EdgeInsets.all(8.0),
  //           searchCursorColor: Colors.pinkAccent,
  //           searchInputDecoration: InputDecoration(
  //             hintText: 'Search...',
  //             hintStyle: TextStyle(
  //               color: Colors.grey,
  //             ),
  //           ),
  //           isSearchable: true,
  //           title: AdaptiveText('Select your country'),
  //           onValuePicked: (country) => setState(
  //             () => _selectedCountry = country,
  //           ),
  //           itemBuilder: (country) => Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               CountryPickerUtils.getDefaultFlagImage(country),
  //               SizedBox(width: 12.0),
  //               Expanded(
  //                 child: RichText(
  //                   text: TextSpan(
  //                     text: country.name,
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.w300,
  //                     ),
  //                     children: [
  //                       TextSpan(
  //                         text: ' (+${country.phoneCode})',
  //                         style: TextStyle(
  //                           color: Colors.grey,
  //                           fontWeight: FontWeight.w300,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );

  _warnUser() => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: AdaptiveText(
              'Warning',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            content: AdaptiveText(
              'The data will be lost if you remove the app while using it as guest.',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              SimpleDialogOption(
                child: AdaptiveText(
                  'CANCEL',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              SimpleDialogOption(
                child: AdaptiveText(
                  'OKAY',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
              ),
            ],
          );
        },
      );
}
