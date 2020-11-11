import 'dart:convert';

class ExportDataModel {
  final String date;
  final double outflow;
  final double inflow;
  final double inflowMINUSoutflow;
  ExportDataModel({
    this.date,
    this.outflow,
    this.inflow,
    this.inflowMINUSoutflow,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'outflow': outflow,
      'inflow': inflow,
      'inflowMINUSoutflow': inflowMINUSoutflow,
    };
  }
}
