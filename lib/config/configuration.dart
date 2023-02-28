import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class Configuration {
  TextStyle get whiteText => TextStyle(
        color: Colors.white,
      );

  Color get appColor => Color(0xff2B2F8E);
  Color get redColor => Color(0xff263547);
  Color get expenseColor => Color(0xffFBA41F);
  Color get incomeColor => Color(0xff2E4FFF);
  Color get selectedColor => Color(0xff7133BF);
  Color get deleteColor => Color(0xfffc717f);
  Color get cancelColor => Color(0xffb9bbc5);
  static const Color accountIconColor = Color(0xff2e4fff);

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

  Future<File?> saveImage(File file, String directoryFolderName, String fileName) async {
    File? compressedImage = await getCompressedImage(file, directoryFolderName, fileName);
    // print(compressedImage.path);
    return compressedImage;
  }

  Future<File?> getCompressedImage(File _file, String directoryFolderName, String fileName) async {
    if (_file.path.split('/').last.split('.').last == 'jpg' || _file.path.split('/').last.split('.').last == 'jpeg' || _file.path.split('/').last.split('.').last == 'png') {
      Directory _dir = await getApplicationSupportDirectory();
      String ext = _file.path.split('/').last.split('.').last;
      Directory directory = await Directory(_dir.path + '/$directoryFolderName').create(recursive: true);
      String filePath = directory.path + '/' + fileName + '.' + ext;
      try {
        final result = await FlutterImageCompress.compressAndGetFile(
          _file.path,
          filePath,
          format: ((_file.path.split('/').last).split('.').last != 'png') ? CompressFormat.jpeg : CompressFormat.png,
          quality: 40,
        );
        return result;
      } catch (e) {
        print(e);
        return _file;
      }
    } else {
      print('dssdsdsdds');
      return _file;
    }
  }
}
