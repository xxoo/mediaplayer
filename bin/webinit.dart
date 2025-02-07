// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:isolate';

void main(List<String> args) async {
  final path = args.isEmpty ? Directory.current.path : args[0];
  final html = File('$path/web/index.html');
  if (!await html.exists()) {
    print(
      'File not found: ${html.path}. Please make sure your project enabled web support.',
    );
  } else {
    final content = await html.readAsString();
    if (!content.contains('mediaplayer.js')) {
      final newContent = content.replaceFirst(
        RegExp(r'(?=</head>)', caseSensitive: false),
        '  <script src="mediaplayer.js"></script>\n',
      );
      await html.writeAsString(newContent);
      print('mediaplayer.js added to ${html.path}');
    }
    final js = 'web/mediaplayer.js';
    final srcUri = await Isolate.resolvePackageUri(
      Uri.parse('package:mediaplayer/'),
    );
    final srcFile = File(
      srcUri!.toFilePath().replaceFirst(RegExp(r'lib/$'), js),
    );
    await srcFile.copy('$path/$js');
    print('mediaplayer.js copied to $path/web');
  }
}
