import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/models/exportmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../components/adaptive_text.dart';
import '../components/extra_componenets.dart';

class InfoCard extends StatelessWidget {
  final ExportDataModel? budgetData;
  final ExportDataModel? transactionData;

  final TextStyle textStyle = TextStyle(
    color: Configuration().incomeColor,
    fontSize: 17,
  );
  final TextStyle nameTextStyle = TextStyle(
    color: Colors.grey,
    // fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  InfoCard({Key? key, this.budgetData, this.transactionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Material(
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ListTile(
            title: Row(
              children: <Widget>[
                Text(
                  budgetData!.date!.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: subtitleInfo('projected', budgetData!),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      // verticalDiv(),
                      Expanded(child: subtitleInfo('real', transactionData!)),
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

  Widget subtitleInfo(String title, ExportDataModel value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AdaptiveText(
          title.toUpperCase(),
          style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 5,
        ),
        getRowValue(
          svgImageName: 'arrow_right',
          value: value.inflow!,
        ),
        getRowValue(
          svgImageName: 'arrow_left',
          value: value.outflow!,
        ),
        getRowValue(svgImageName: 'monthly_surplus', value: value.inflowMINUSoutflow!, valueColor: Colors.green),
        getRowValue(svgImageName: 'cumulative_surplus', value: value.cf!, valueColor: Colors.green),
      ],
    );
  }

  getRowValue({
    String? svgImageName,
    required double value,
    Color valueColor = Colors.black,
  }) {
    return Row(
      children: [
        if (svgImageName != null) SvgPicture.asset('assets/images/$svgImageName.svg', width: 18, color: Colors.black),
        SizedBox(
          width: 4,
        ),
        Flexible(
          child: Text(
            (value.isNegative ? '(' : '') + nepaliNumberFormatter((value.abs())) + (value.isNegative ? ')' : ''),
            style: TextStyle(fontSize: 18, color: value.isNegative ? Colors.red : valueColor, fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}
