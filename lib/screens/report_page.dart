import 'dart:io';

import 'package:MunshiG/components/infocard.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/config/globals.dart' as globals;
import 'package:MunshiG/models/budget/budget.dart';
import 'package:MunshiG/models/exportmodel.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/budget_service.dart';
import 'package:MunshiG/services/category_service.dart';

class ReportPage extends StatefulWidget {
  final String selectedSubSector;
  const ReportPage({
    Key key,
    this.selectedSubSector,
  }) : super(key: key);
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  List<ExportDataModel> exportDataModel = [];
  TabController _tabController;
  int _currentYear = NepaliDateTime.now().year;
  int _currentMonth = NepaliDateTime.now().month;
  final int noOfmonths = 132;
  Lang language;
  String selectedSubSector;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  var _dateResolver = <NepaliDateTime>[];
  @override
  void initState() {
    super.initState();
    initializeDateResolver();
    selectedSubSector = widget.selectedSubSector ?? globals.selectedSubSector;
    generateReport();
    _tabController =
        TabController(length: noOfmonths ~/ 12, vsync: this, initialIndex: 0);
  }

  initializeDateResolver() {
    // int _year = _currentYear;
    // int _firstMonth;
    // bool _incrementer;
    int initYear = _currentYear;
    int indexYear = initYear;
    for (int i = 1; i <= noOfmonths; i++) {
      _dateResolver.add(NepaliDateTime(indexYear, (i % 12 == 0) ? 12 : i % 12));
      if (i % 12 == 0) {
        indexYear++;
      }
    }
  }

  generateReport() {
    Future.wait([
      CategoryService()
          .getCategoriesID(selectedSubSector, CategoryType.EXPENSE),
      CategoryService().getCategoriesID(selectedSubSector, CategoryType.INCOME),
    ]).then((value) async {
      exCat = value[0];
      incomeCat = value[1];
      for (int i = 0; i < _dateResolver.length; i++) {
        final e = _dateResolver[i];
        final value = await BudgetService()
            .getTotalBudgetByDate(selectedSubSector, e.month, e.year);
        final temp = getSumTotal(
          value,
        );
        final outflow = temp[0];
        final inflow = temp[1];
        exportDataModel.add(
          ExportDataModel(
              date: NepaliDateFormat("MMMM ''yy",
                      language == Lang.EN ? Language.english : Language.nepali)
                  .format(
                NepaliDateTime(e.year, e.month),
              ),
              inflow: inflow,
              outflow: outflow,
              inflowMINUSoutflow: (inflow - outflow)),
        );

        groupedData = exportDataModel.groupBy((e) => e.date.split("'").last);
        setState(() {});
      }
    });
  }

  Map<String, List<ExportDataModel>> groupedData;
  List<int> incomeCat = [];
  List<int> exCat = [];
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(
        builder: (context, preferenceProvider, _) {
      language = preferenceProvider.language;
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Configuration().appColor,
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AdaptiveText('Report'),
                Flexible(child: Text(' (' + selectedSubSector.toString() + ')'))
              ]),
          bottom: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Configuration().incomeColor,
            ),
            isScrollable: true,
            tabs: [
              for (int index = 0; index < (noOfmonths ~/ 12); index++)
                Tab(
                  child: Text(NepaliDateFormat(
                          "yyyy",
                          language == Lang.EN
                              ? Language.english
                              : Language.nepali)
                      .format(
                    NepaliDateTime(
                      _dateResolver[index * 12].year,
                      _dateResolver[index * 12].month,
                    ),
                  )),
                )
            ],
          ),
        ),
        floatingActionButton: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.yellow[800],
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.grey,
            hoverColor: Colors.grey,
            // highlightColor: Colors.grey,
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
                  Text(
                    'Export Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              ),
            ),
            padding: EdgeInsets.only(top: 30, left: 0),
            child: exportDataModel.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : TabBarView(controller: _tabController, children: <Widget>[
                    for (int i = 0; i < groupedData.keys.length; i++)
                      GraphPlot(
                        groupedData: groupedData[groupedData.keys.toList()[i]],
                        titleYear: groupedData.keys.toList()[i],
                      )
                  ]),
          ),
        ),
      );
    });
  }

  Widget _buildBody(ExportDataModel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          model.date,
          style: TextStyle(
              color: Configuration().appColor,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        Column(
          children: <Widget>[
            Text(
              'Cash Inflow :' + model.inflow.toString(),
              style: TextStyle(color: Colors.red),
            ),
            Text(
              'Cash Outflow :' + model.outflow.toString(),
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  List<double> getSumTotal(List<Budget> data, {bool isInflow = false}) {
    if (data == null) return [0.0, 0.0];
    double inflow = 0.0;
    double outflow = 0.0;
    data.forEach((element) {
      if (incomeCat.contains(element.categoryId))
        inflow = inflow + (double.tryParse(element?.total.toString()) ?? 0.0);
      else
        outflow = outflow + (double.tryParse(element?.total.toString()) ?? 0.0);
    });
    return [outflow, inflow];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _exportDataToExcel() async {
    var excel = Excel.createExcel();
    var sheet = await excel.getDefaultSheet();

    // await excel.setDefaultSheet(sheet);

    /*-------------SET Heading----------------*/
    excel.updateCell(
        sheet, CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), "Date");
    excel.updateCell(
        sheet,
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0),
        "Inflow Project1ion");
    excel.updateCell(
        sheet,
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0),
        "OutFlow Projection");
    excel.updateCell(
        sheet,
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
        "Inflow - Outflow");
    excel.updateCell(
      sheet,
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0),
      "CF",
    );
    /*-------------END Heading----------------*/
    int row = 1;
    double cf = 0.0;
    exportDataModel.forEach((element) {
      cf = cf + element.inflowMINUSoutflow;
      element.toMap().forEach((key, value) {
        switch (key) {
          case 'date':
            excel.updateCell(
                sheet,
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
                value,
                wrap: TextWrapping.WrapText);
            break;
          case 'inflow':
            excel.updateCell(
                sheet,
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
                value,
                wrap: TextWrapping.WrapText);
            break;
          case 'outflow':
            excel.updateCell(
                sheet,
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
                value,
                wrap: TextWrapping.WrapText);

            break;
          case 'inflowMINUSoutflow':
            excel.updateCell(
                sheet,
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row),
                value,
                wrap: TextWrapping.WrapText);
            break;
          default:
        }
      });
      excel.updateCell(
        sheet,
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row),
        cf,
      );
      row++;
    });

    excel.encode().then((value) async {
      Directory directory = await getExternalStorageDirectory();
      print(directory);
      String finalPath = directory.path +
          "/files/" +
          selectedSubSector +
          "ProjectionSheet.xlsx";
      File(finalPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(value);
      emailSender(finalPath);
    });
  }

  emailSender(String path) async {
    Email email = Email(
        attachmentPaths: [path],
        subject: selectedSubSector + ' Projection Details',
        recipients: ['rishrestha@aria.com.np'],
        isHTML: false);
    await FlutterEmailSender.send(email);
  }
}

class GraphPlot extends StatelessWidget {
  final List<ExportDataModel> groupedData;
  final String titleYear;

  const GraphPlot({Key key, this.groupedData, this.titleYear})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) => InfoCard(
        groupedData: groupedData[index],
      ),
      itemCount: groupedData.length,
    );
  }
}
