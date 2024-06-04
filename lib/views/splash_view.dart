import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_page.dart';

class SplashView extends StatefulWidget {
  final String flavor;

  SplashView({required this.flavor});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _saveSampleData(); // デバッグ用のサンプルデータ保存
    _checkNetworkAndLoadData();
  }

  Future<void> _saveSampleData() async {
    final sampleData = [
      {
        "anon_key": null,
        "supabase_url": null,
        "env_name": "Environment 1",
        "password": null,
        "email_address": null,
        "front_end_url": null,
        "selected": null,
        "session": null,
      },
      {
        "anon_key": null,
        "supabase_url": null,
        "env_name": "Environment 2",
        "password": null,
        "email_address": null,
        "front_end_url": null,
        "selected": null,
        "session": null,
      }
    ];
    await _storage.write(key: 'envSettings', value: jsonEncode(sampleData));
  }

  Future<void> _checkNetworkAndLoadData() async {
    try {
      // ネットワーク接続の確認
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // ネットワーク接続がある場合、データを読み込む
        await Future.delayed(Duration(seconds: 3)); // 擬似的に3秒待つ
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        // 接続に失敗した場合
        _showNetworkError();
      }
    } on SocketException catch (_) {
      // 接続に失敗した場合
      _showNetworkError();
    }
  }

  void _showNetworkError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Network Error'),
        content: Text('ネットワーク接続に問題があります。接続を確認してください。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkNetworkAndLoadData(); // 再試行
            },
            child: Text('再試行'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
