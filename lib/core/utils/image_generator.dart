import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageGenerator {
  static Future<ui.Image> generateImage(String text, {int width = 300, int height = 200}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.white; // 背景色を白に設定

    // テキストを描画
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: Colors.black, fontSize: 24),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: width.toDouble());
    textPainter.paint(canvas, Offset((width - textPainter.width) / 2, (height - textPainter.height) / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    return image;
  }
}
