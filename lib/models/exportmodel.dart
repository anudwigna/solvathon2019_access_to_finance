import 'dart:convert';

class ExportDataModel {
  final String? date;
  final double? outflow;
  final double? inflow;
  final double? inflowMINUSoutflow;
  final double? cf;
  ExportDataModel({
    this.date,
    this.outflow,
    this.inflow,
    this.inflowMINUSoutflow,
    this.cf,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'outflow': outflow,
      'inflow': inflow,
      'inflowMINUSoutflow': inflowMINUSoutflow,
      'cf': cf
    };
  }
}
