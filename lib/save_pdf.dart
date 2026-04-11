//
// import 'dart:io';
//
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart';
//
//
// class SaveAndOpenDirectory{
//    Future<File> savePdf({
//     required String name,
//     required Document pdf,
//
// }) async {
//     final root = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
//     final file = File('${root!.path}/$name');
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }
//
//   static Future<void> openPdf(File file) async {
//     final path = file.path;
//     await OpenFile.open(path);
//   }
// }


import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';


class SaveAndOpenDirectory {
  /// **Save PDF file to Download folder**
  Future<File> savePdf({required String name, required pw.Document pdf}) async {
    // Request storage permission
    await _requestPermission();

    // Get external storage directory
    Directory? directory = Directory("/storage/emulated/0/Download");

    // If directory is not available, fallback to documents directory
    if (!directory.existsSync()) {
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File('${directory.path}/$name');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// **Request Storage Permission**
  Future<void> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return;
    }
    await Permission.storage.request();
  }

  /// **Open PDF File**
  static Future<void> openPdf(File file) async {
    await OpenFile.open(file.path);
  }
}

