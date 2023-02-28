import 'package:MunshiG/components/adaptive_text.dart';
import 'package:MunshiG/providers/preference_provider.dart';
import 'package:MunshiG/services/account_service.dart';
import 'package:MunshiG/services/activity_tracking.dart';
import 'package:MunshiG/services/app_page.dart';
import 'package:MunshiG/services/budget_service.dart';
import 'package:MunshiG/services/category_heading_service.dart';
import 'package:MunshiG/services/category_service.dart';
import 'package:MunshiG/services/http_service.dart';
import 'package:MunshiG/services/transaction_service.dart';
import 'package:MunshiG/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:io';
import '../config/routes.dart';
import '../services/preference_service.dart';
import 'package:MunshiG/components/drawer.dart';
import 'package:MunshiG/config/configuration.dart';
import 'package:MunshiG/config/globals.dart';
import 'package:archive/archive_io.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../components/extra_componenets.dart';
import '../models/app_page_naming.dart';
import '../services/activity_tracking.dart';
import '../services/user_service.dart';
import 'package:device_info/device_info.dart';

class BackUpPage extends StatefulWidget {
  @override
  _BackUpPageState createState() => _BackUpPageState();
}

class _BackUpPageState extends State<BackUpPage> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool isCreating = false;
  File backupFile;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ActivityTracker()
        .pageTransactionActivity(PageName.backupPage, action: 'Opened');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        ActivityTracker()
            .pageTransactionActivity(PageName.backupPage, action: 'Paused');
        break;
      case AppLifecycleState.inactive:
        ActivityTracker()
            .pageTransactionActivity(PageName.backupPage, action: 'Inactive');
        break;
      case AppLifecycleState.resumed:
        ActivityTracker()
            .pageTransactionActivity(PageName.backupPage, action: 'Resumed');
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ActivityTracker()
        .pageTransactionActivity(PageName.backupPage, action: 'Closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<PreferenceProvider>(context).language;
    final subSector = Provider.of<SubSectorProvider>(context).selectedSubSector;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Configuration().appColor,
      drawer: MyDrawer(),
      appBar: AppBar(
        title: AdaptiveText('Backup'),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Icon(
            MdiIcons.cloudUploadOutline,
            size: 28,
            color: Configuration().appColor,
          ),
          onPressed: () async {
            if (isCreating) return;
            final canPerformBackup = await UserService().canPerformBackUp();
            if (!(canPerformBackup ?? false)) {
              showAlertDialog();
              return;
            }
            ActivityTracker().otherActivityOnPage(
                PageName.backupPage,
                'Pressed Backup Button',
                'Floating Action Button',
                'Floating Action Button');
            isCreating = true;
            final callback = await checkPermission(
              _scaffoldKey,
            );
            if (callback) {
              ProgressDialog pr = ProgressDialog(context, isDismissible: false);
              pr.style(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  message: language == Lang.EN
                      ? 'Synchronizing Data'
                      : 'समिकरण भइरहेको छ');
              await pr.show();
              try {
                await createBackup(subSector, language);
                pr.hide();
                showErrorDialog(
                    'Data has been backup successfully', 'Success');
              } catch (e) {
                pr.hide();
                showErrorDialog(
                    'Error Performing Backup, ' + e.toString(), null);
              }
              backupFile.deleteSync(recursive: true);
            }
            isCreating = false;
          }),
      body: Center(
        child: FutureBuilder(
            future: PreferenceService.instance.getLastBackUpDate(),
            builder: (context, snapshot) => snapshot.hasData
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AdaptiveText(
                        'Last Backup on',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        NepaliDateFormat(
                                "MMMM dd, y (EEE)",
                                language == Lang.EN
                                    ? Language.english
                                    : Language.nepali)
                            .format(DateTime.parse(snapshot.data)
                                .toNepaliDateTime()),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Center(
                    child: AdaptiveText(
                    'No Backup Found',
                    style: TextStyle(fontSize: 16),
                  ))),
      ),
    );
  }

  showAlertDialog() {
    showDeleteDialog(context,
        hideCancel: true,
        deleteButtonText: 'Go To Profile',
        description:
            'You have to create account to create backup, Please create account and try again.',
        onDeletePress: () {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushNamedAndRemoveUntil(
        context,
        profilePage,
        ModalRoute.withName(home),
      );
    });
  }

  showErrorDialog(String descritpion, String title) {
    showDeleteDialog(context,
        title: title,
        hideCancel: true,
        deleteButtonText: 'Okay    ',
        description: descritpion, onDeletePress: () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  Future<void> createBackup(String subSector, Lang language) async {
    try {
      await Future.wait([
        AccountService().closeDatabase(subSector),
        ActivityTracker().closeDatabase(subSector),
        AppPage().closeDatabase(subSector),
        BudgetService().closeDatabase(subSector),
        CategoryHeadingService().closeDatabase(subSector),
        CategoryService().closeDatabase(subSector),
        TransactionService().closeDatabase(subSector),
        UserService().closeDatabase(subSector),
      ]);
    } catch (e) {
      Toast.show(
          language == Lang.EN
              ? 'Error Creating Backup, Please Try Again'
              : 'कृपया फेरि प्रयास गर्नुहोस्',
          context);
      return;
    }

    Directory dir = await getApplicationDocumentsDirectory();
    var encoder = ZipFileEncoder();
    String zipPath = dir.path + '/temporary/backup.zip';
    encoder.create(zipPath);
    List<File> files = [];
    dir
        .listSync()
        .where((element) =>
            element.path.split('/').last.split('.').last.compareTo('db') == 0)
        .toList()
        .forEach((element) {
      encoder.addFile(File(element.path));
      files.add(File(element.path));
    });
    encoder.close();
    dir = await getExternalStorageDirectory();
    final zipDirectory =
        await Directory(dir.path + '/temporary').create(recursive: true);
    String newzipPath = zipDirectory.path + '/backup.zip';
    await File(zipPath).copy(newzipPath).then((value) async {
      File(zipPath).deleteSync(recursive: true);
      backupFile = File(newzipPath);
      final sizeInKB = value.lengthSync() / 1024;
      double sizeinMB = sizeInKB / 1024;
      Toast.show(
          'Backup File has been Created of: ' +
              (sizeInKB > 1024
                  ? sizeinMB.toStringAsFixed(2) + ' MB'
                  : sizeInKB.toStringAsFixed(2) + ' KB'),
          context,
          duration: 7);
      await HttpService().backupData(value);
      PreferenceService.instance.setLastBackUpDate().then((value) {
        setState(() {});
      });
    });
  }
}
