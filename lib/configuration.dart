import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

class Configuration {
  TextStyle get whiteText => TextStyle(
        color: Colors.white,
      );

  Color get appColor => Color(0xff2B2F8E);
  Color get redColor => Color(0xff263547);
  Color get expenseColor => Color(0xffFBA41F);
  Color get incomeColor => Color(0xff2E4FFF);
  Color get selectedColor => Color(0xff7133BF);

  Widget get drawerItemDivider => Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Divider(
          color: Colors.grey,
        ),
      );

  BoxDecoration get gradientDecoration => BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: FractionalOffset.bottomRight,
          end: FractionalOffset.topLeft,
        ),
      );

  List<Color> get gradientColors => [
        appColor,
        redColor,
      ];

  NepaliDateTime toNepaliDateTime(DateTime dateTime) {
    return NepaliDateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
