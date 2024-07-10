// lib/core/utils/file_utils.dart

import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  // 他のファイル操作ユーティリティを追加 (例: ファイルの削除、存在確認など)
}
