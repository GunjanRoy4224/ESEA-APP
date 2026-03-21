import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<File> loadPdf(String url) async {
    final dir = await getApplicationDocumentsDirectory();

    final fileName = url.hashCode.toString();
    final file = File("${dir.path}/$fileName.pdf");

    // ✅ Already downloaded → reuse
    if (await file.exists()) {
      return file;
    }

    // 🔁 Convert Google Drive link to direct download
    final downloadUrl = _normalizeDriveUrl(url);

    await Dio().download(
      downloadUrl,
      file.path,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );

    return file;
  }

  static String _normalizeDriveUrl(String url) {
    if (url.contains("drive.google.com")) {
      final regExp = RegExp(r'/d/([^/]+)');
      final match = regExp.firstMatch(url);
      if (match != null) {
        final id = match.group(1);
        return "https://drive.google.com/uc?export=download&id=$id";
      }
    }
    return url;
  }
}
