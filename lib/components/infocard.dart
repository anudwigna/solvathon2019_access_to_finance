import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/models/exportmodel.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final ExportDataModel groupedData;
  final TextStyle textStyle = TextStyle(
    color: Configuration().incomeColor,
    fontSize: 17,
  );
  final TextStyle nameTextStyle = TextStyle(
    color: Configuration().incomeColor,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  InfoCard({Key key, this.groupedData}) : super(key: key);

  Widget verticalDiv() {
    return Container(
      color: Colors.blue,
      height: 28,
      width: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Material(
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            title: Row(
              children: <Widget>[
                Text(
                  'Date: ',
                  style: nameTextStyle,
                ),
                Text(
                  groupedData.date,
                  style: textStyle,
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: subtitleInfo(
                            'cash inflow', groupedData.inflow.toString() ?? ''),
                      ),
                      verticalDiv(),
                      Expanded(
                          child: subtitleInfo(
                              'cash OutFlow', groupedData.outflow.toString())),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget subtitleInfo(String title, String value) {
    return Column(
      children: <Widget>[
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
