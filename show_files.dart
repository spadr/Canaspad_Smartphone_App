import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Please provide a directory path.');
    return;
  }

  final directoryPath = arguments[0];
  final directory = Directory(directoryPath);

  if (!directory.existsSync()) {
    print('The directory does not exist.');
    return;
  }

  // 最大階層数
  const maxDepth = 10;

  // ログファイルの作成
  final logFile = File('show_files.log');
  final logSink = logFile.openWrite();

  // ツリー状のディレクトリ構造を保存するためのリスト
  final List<String> treeStructure = [];

  // 再帰的にディレクトリ構造を取得する関数
  void getDirectoryTree(Directory dir, int depth, String prefix) {
    if (depth > maxDepth) return;

    final indent = prefix.isEmpty ? '' : '$prefix|-- ';

    treeStructure.add('$indent${dir.path}');

    final List<FileSystemEntity> entities = dir.listSync();
    for (int i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final isLast = i == entities.length - 1;
      final newPrefix = prefix + (isLast ? '    ' : '|   ');
      if (entity is Directory) {
        getDirectoryTree(entity, depth + 1, newPrefix);
      } else if (entity is File) {
        treeStructure.add('$newPrefix|-- ${entity.path}');
      }
    }
  }

  // 最初のディレクトリを取得
  getDirectoryTree(directory, 0, '');

  // ツリー状のディレクトリ構造をログに書き込む
  logSink.writeln('Directory Tree:');
  treeStructure.forEach(logSink.writeln);
  logSink.writeln('');

  // 再帰的にディレクトリ構造とファイル内容を表示する関数
  void listDirectory(Directory dir, int depth, String prefix) {
    if (depth > maxDepth) return;

    final indent = prefix.isEmpty ? '' : '$prefix|-- ';
    logSink.writeln('$indent${dir.path}');

    final List<FileSystemEntity> entities = dir.listSync();
    for (int i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final isLast = i == entities.length - 1;
      final newPrefix = prefix + (isLast ? '    ' : '|   ');
      if (entity is Directory) {
        listDirectory(entity, depth + 1, newPrefix);
      } else if (entity is File) {
        logSink.writeln('$newPrefix|-- ${entity.path}');
        try {
          final contents = entity.readAsStringSync();
          logSink.writeln(contents);
        } catch (e) {
          logSink.writeln('Error reading file: $e');
        }
        logSink.writeln('');
      }
    }
  }

  // 最初のディレクトリをリスト
  listDirectory(directory, 0, '');

  // ログファイルを閉じる
  logSink.close();
}


// dart show_files.dart "C:\github\canaspad_smartphone_app\lib"