import 'dart:io';

import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/date_selector.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/components/infocard.dart';
import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/config/globals.dart' as globals;
import 'package:MunshiG/models/budget/budget.dart';
import 'package:MunshiG/models/exportmodel.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/budget_service.dart';
import 'package:MunshiG/services/category_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../components/extra_componenets.dart';
import '../config/globals.dart';
import '../models/app_page_naming.dart';
import '../services/activity_tracking.dart';

class ReportPage extends StatefulWidget {
  final String? selectedSubSector;
  const ReportPage({
    Key? key,
    this.selectedSubSector,
  }) : super(key: key);
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with WidgetsBindingObserver {
  List<ExportDataModel> budgetExportDataModel = [];
  List<ExportDataModel> transcationExportDataModel = [];
  Lang? language;
  String? selectedSubSector;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ActivityTracker().pageTransactionActivity(PageName.report, action: 'Opened');
    selectedSubSector = widget.selectedSubSector ?? globals.selectedSubSector;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        ActivityTracker().pageTransactionActivity(PageName.report, action: 'Paused');
        break;
      case AppLifecycleState.inactive:
        ActivityTracker().pageTransactionActivity(PageName.report, action: 'Inactive');
        break;
      case AppLifecycleState.resumed:
        ActivityTracker().pageTransactionActivity(PageName.report, action: 'Resumed');
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ActivityTracker().pageTransactionActivity(PageName.report, action: 'Closed');
    super.dispose();
  }

  List<NepaliDateTime> initializeDateResolver(int fromyear, int frommonth, int toyear, int tomonth) {
    List<NepaliDateTime> _dateResolver = [];
    int noOfMonths = ((((toyear - fromyear) * 12) + tomonth) - frommonth);

    // int noOfMonths = ((NepaliDateTime(toyear, tomonth)
    //         .difference(NepaliDateTime(fromyear, frommonth))
    //         .inDays) ~/
    //     30);
    int initYear = fromyear;
    int indexYear = initYear;
    for (int i = frommonth; i <= (noOfMonths + frommonth); i++) {
      _dateResolver.add(NepaliDateTime(indexYear, (i % 12 == 0) ? 12 : i % 12));
      if (i % 12 == 0) {
        indexYear++;
      }
    }
    return _dateResolver;
  }

  NepaliDateTime fromDate = NepaliDateTime(NepaliDateTime.now().year, NepaliDateTime.now().month);
  NepaliDateTime toDate = NepaliDateTime(NepaliDateTime.now().year, NepaliDateTime.now().month + 1);
  Widget getSearchWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          AdaptiveText(
                            'From'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          DateSelector(
                            textColor: Colors.black,
                            onDateChanged: (value) {
                              if (value != null)
                                setState(() {
                                  fromDate = value;
                                });
                            },
                            currentDate: fromDate,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AdaptiveText(
                            'To'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          DateSelector(
                            textColor: Colors.black,
                            initialDateYear: fromDate.year,
                            initialMonth: fromDate.month,
                            currentDate: toDate,
                            onDateChanged: (value) {
                              if (value != null)
                                setState(() {
                                  toDate = value;
                                });
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => Configuration().incomeColor)),
                  onPressed: () {
                    if (toDate.difference(fromDate).isNegative) {
                      ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(SnackBar(content: Text('End date cannot be behind than From date')));
                      return;
                    }
                    getReportData(fromDate.year, fromDate.month, toDate.year, toDate.month);
                  },
                  child: Center(
                    child: AdaptiveText(
                      'Search',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

  clearVariable() {
    budgetExportDataModel?.clear();
    transcationExportDataModel?.clear();
    transactionGroupData?.clear();
    budgetGroupedData?.clear();
  }

  getReportData(int formyear, int fromtmonth, int toyear, int tomonth) {
    clearVariable();
    Future.wait([
      CategoryService().getCategoriesID(selectedSubSector!, CategoryType.EXPENSE),
      CategoryService().getCategoriesID(selectedSubSector!, CategoryType.INCOME),
    ]).then((value) async {
      exCat = value[0];
      incomeCat = value[1];
      double budgetcf = 0;
      double transactioncf = 0;
      final _dateResolver = initializeDateResolver(formyear, fromtmonth, toyear, tomonth);
      for (int i = 0; i < _dateResolver.length; i++) {
        double inflowMINUSoutflow = 0.0;
        final e = _dateResolver[i];

        /// ---budjet projection data--
        final value = await BudgetService().getTotalBudgetByDate(selectedSubSector!, e.month, e.year);
        final totalData = getSumTotal(
          value,
        );
        final budgetTotalData = totalData[0];
        final budgetOutflow = budgetTotalData[0];
        final budgetInflow = budgetTotalData[1];
        inflowMINUSoutflow = (budgetInflow - budgetOutflow);
        budgetcf = budgetcf + inflowMINUSoutflow;
        budgetExportDataModel.add(
          ExportDataModel(
              date: NepaliDateFormat("MMMM yyyy", language == Lang.EN ? Language.english : Language.nepali).format(
                NepaliDateTime(e.year, e.month),
              ),
              inflow: budgetInflow,
              outflow: budgetOutflow,
              inflowMINUSoutflow: inflowMINUSoutflow,
              cf: budgetcf),
        );

        /// --- transaction data ---
        final transactionTotal = totalData[1];
        inflowMINUSoutflow = 0.0;
        // final transactionValue = await TransactionService()
        //     .getTransactions(selectedSubSector, e.year, e.month);
        // final transactionTotal = getTranscationTotal(transactionValue);
        final realDataOutflow = transactionTotal[0];
        final realDataInflow = transactionTotal[1];
        inflowMINUSoutflow = (realDataInflow - realDataOutflow);

        transactioncf = transactioncf + inflowMINUSoutflow;
        transcationExportDataModel.add(
          ExportDataModel(
              date: NepaliDateFormat("MMMM yyyy", language == Lang.EN ? Language.english : Language.nepali).format(
                NepaliDateTime(e.year, e.month),
              ),
              inflow: realDataInflow,
              outflow: realDataOutflow,
              inflowMINUSoutflow: inflowMINUSoutflow,
              cf: transactioncf),
        );
      }
      budgetGroupedData = budgetExportDataModel.groupBy((e) => e.date!.split("'").last);

      transactionGroupData = transcationExportDataModel.groupBy((e) => e.date!.split("'").last);
      setState(() {});
    });
  }

  Map<String, List<ExportDataModel>>? budgetGroupedData;
  Map<String, List<ExportDataModel>>? transactionGroupData;
  List<int?> incomeCat = [];
  List<int?> exCat = [];
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, preferenceProvider, _) {
      language = preferenceProvider.language;
      return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Configuration().appColor,
          drawer: MyDrawer(),
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  detailDialog(
                    context,
                    showButton: false,
                    detailWidget: Column(
                      children: [
                        getRowValue(
                          value: 'Inflow',
                          svgImageName: 'arrow_right',
                        ),
                        getRowValue(
                          value: 'Outflow',
                          svgImageName: 'arrow_left',
                        ),
                        getRowValue(
                          value: 'Monthly Surplus/Deficit',
                          svgImageName: 'monthly_surplus',
                        ),
                        getRowValue(
                          value: 'Cumulative Surplus/Deficit',
                          svgImageName: 'cumulative_surplus',
                        ),
                      ],
                    ),
                    title: 'Indicators',
                  );
                },
                icon: Icon(MdiIcons.informationOutline),
              )
            ],
            title: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              AdaptiveText(
                'Report',
                style: TextStyle(fontSize: 17),
              ),
              Flexible(
                child: Row(
                  children: [
                    Text(
                      ' (',
                      style: TextStyle(fontSize: 17),
                    ),
                    AdaptiveText(
                      selectedSubSector.toString(),
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      ')',
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              )
            ]),
          ),
          floatingActionButton: budgetExportDataModel.isEmpty
              ? Container(
                  height: 1,
                  width: 1,
                )
              : Material(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.yellow[800],
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Colors.grey,
                    hoverColor: Colors.grey,
                    onTap: _exportDataToExcel,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RotatedBox(
                            quarterTurns: 1,
                            child: Icon(
                              Icons.import_export,
                              size: 30,
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          AdaptiveText(
                            'Export Report',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
          body: Padding(
            padding: const EdgeInsets.only(top: 23.0),
            child: Container(
              height: double.maxFinite,
              decoration: pageBorderDecoration,
              padding: EdgeInsets.only(top: 35, left: 15, right: 15),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    getSearchWidget(),
                    SizedBox(
                      height: 15,
                    ),
                    ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: InfoCard(
                                budgetData: budgetExportDataModel[index],
                                transactionData: transcationExportDataModel[index],
                              ),
                            ),
                        separatorBuilder: (context, index) => SizedBox(
                              height: 0,
                            ),
                        itemCount: budgetExportDataModel.length),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ));
    });
  }

  getRowValue({
    String? svgImageName,
    // Color iconColor,
    required String value,
    // double angle,
    // Widget iconWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // if (svgImageName != null)
          SvgPicture.asset('assets/images/$svgImageName.svg', width: 18, color: Colors.black),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: AdaptiveText(
              value,
              style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }

  List<List<double>> getSumTotal(List<Budget> data, {bool isInflow = false}) {
    if (data.isEmpty)
      return [
        [0.0, 0.0],
        [0.0, 0.0]
      ];
    double budgetinflow = 0.0;
    double budgetoutflow = 0.0;
    double transactioninflow = 0.0;
    double tranasctionoutflow = 0.0;
    data.forEach((element) {
      if (incomeCat.contains(element.categoryId)) {
        budgetinflow = budgetinflow + (double.tryParse(element.total.toString()) ?? 0.0);

        transactioninflow = transactioninflow + (double.tryParse(element.spent.toString()) ?? 0.0);
      } else {
        budgetoutflow = budgetoutflow + (double.tryParse(element.total.toString()) ?? 0.0);

        tranasctionoutflow = tranasctionoutflow + (double.tryParse(element.spent.toString()) ?? 0.0);
      }
    });
    return [
      [budgetoutflow, budgetinflow],
      [tranasctionoutflow, transactioninflow]
    ];
  }

  setExcelHeading(String? sheet, Excel excel) {
    excel.updateCell(sheet, CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), "Date");
    excel.updateCell(sheet, CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0), "Inflow Project1ion");
    excel.updateCell(sheet, CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0), "OutFlow Projection");
    excel.updateCell(sheet, CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0), "Monthly Surplus/Deficit");
    excel.updateCell(
      sheet,
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0),
      "Cumulative Surplus/Deficit",
    );
  }

  _exportDataToExcel() async {
    var excel = Excel.createExcel();
    // excel.setDefaultSheet('Projection Data');

    var sheet = await excel.getDefaultSheet();
    /*-------------SET Heading----------------*/
    setExcelHeading(sheet, excel);
    /*-------------END Heading----------------*/
    int row = 1;
    /*----- budget data project -----*/
    budgetExportDataModel.forEach((element) {
      element.toMap().forEach((key, value) {
        switch (key) {
          case 'date':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );
            break;
          case 'inflow':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );
            break;
          case 'outflow':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );

            break;
          case 'inflowMINUSoutflow':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );
            break;
          case 'cf':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );
            break;
          default:
        }
      });
      row++;
    });

    /*----- budget data project ends -----*/

    sheet = 'Real Data';
    /*-------------SET Heading----------------*/
    setExcelHeading(sheet, excel);
    /*-------------END Heading----------------*/
    row = 1;
    transcationExportDataModel.forEach((element) {
      element.toMap().forEach((key, value) {
        switch (key) {
          case 'date':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );
            break;
          case 'inflow':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );
            break;
          case 'outflow':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );

            break;
          case 'inflowMINUSoutflow':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );
            break;
          case 'cf':
            excel.updateCell(
              sheet,
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row),
              value,
              cellStyle: CellStyle(textWrapping: TextWrapping.WrapText),
            );
            break;
          default:
        }
      });
      row++;
    });
    excel.encode().then((value) async {
      Directory directory = await (getExternalStorageDirectory() as Future<Directory>);
      String finalPath = directory.path + "/temp/" + selectedSubSector! + "ProjectionSheet.xlsx";
      File(finalPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(value);
      emailSender(finalPath);
    });
  }

  emailSender(String path) async {
    Email email = Email(attachmentPaths: [path], subject: selectedSubSector! + ' Projection Details', recipients: ['info@aria.com.np'], isHTML: false);
    await FlutterEmailSender.send(email).then((value) {
      File(path).deleteSync();
    });
  }
}
