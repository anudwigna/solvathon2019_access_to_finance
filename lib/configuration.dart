import 'package:flutter/material.dart';

class Configuration {
  TextStyle get whiteText => TextStyle(
        color: Colors.white,
      );

  //Color get yellowColor => Color(0xeef8aa2c);
  Color get yellowColor => Colors.blue;

  //Color get redColor => Color(0xeee62844);
  Color get redColor => Colors.blue;

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
        yellowColor,
        redColor,
      ];
}
