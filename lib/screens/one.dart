// import 'dart:io';

// import 'package:MunshiG/components/drawer.dart';
// import 'package:MunshiG/config/configuration.dart';
// import 'package:MunshiG/config/globals.dart';
// import 'package:archive/archive_io.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:path_provider/path_provider.dart';

// class BackUpAndRestore extends StatefulWidget {
//   @override
//   _BackUpAndRestoreState createState() => _BackUpAndRestoreState();
// }

// class _BackUpAndRestoreState extends State<BackUpAndRestore> {
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Configuration().appColor,
//       drawer: MyDrawer(),
//       appBar: AppBar(),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           FloatingActionButton(onPressed: () async {
//             final callback = await checkPermission(
//               _scaffoldKey,
//             );
//             if (!callback) return;
//             try {
//               Directory dir = await getApplicationDocumentsDirectory();
//               var encoder = ZipFileEncoder();
//               String zipPath = dir.path + '/temp/backup.zip';
//               encoder.create(zipPath);
//               List<File> files = [];
//               dir
//                   .listSync()
//                   .where((element) =>
//                       element.path
//                           .split('/')
//                           .last
//                           .split('.')
//                           .last
//                           .compareTo('db') ==
//                       0)
//                   .toList()
//                   .forEach((element) {
//                 encoder.addFile(File(element.path));
//                 files.add(File(element.path));
//               });
//               encoder.close();
//               Directory newdir = await getExternalStorageDirectory();
//               await Directory(newdir.path + '/temp').create(recursive: true);
//               String newzipPath = newdir.path + '/temp/backup.zip';
//               (File(zipPath))
//                 ..createSync(recursive: true)
//                 ..copy(newzipPath).then((value) async {
//                   File(zipPath).deleteSync(recursive: true);
//                   Email email = Email(
//                       attachmentPaths: [newzipPath],
//                       subject: 'BackUp',
//                       recipients: ['rishrestha@aria.com.np'],
//                       isHTML: false);
//                   await FlutterEmailSender.send(email);
//                 });
//             } catch (e) {
//               _scaffoldKey.currentState.showSnackBar(
//                   SnackBar(content: Text('Error Creating Backup')));
//             }
//           }),
//         ],
//       ),
//     );
//   }
// }
