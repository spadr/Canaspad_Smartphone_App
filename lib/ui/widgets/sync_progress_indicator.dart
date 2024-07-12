// lib/ui/widgets/sync_progress_indicator.dart

import 'package:flutter/material.dart';

class SyncProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 から 1.0 までの進捗率
  final String? message; // 表示するメッセージ (オプション)

  const SyncProgressIndicator({Key? key, required this.progress, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 64,
          width: 64,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              message!,
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
