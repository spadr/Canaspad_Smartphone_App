import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/home_view.dart';
import '../../mini_game/game_main.dart';
import '../viewmodels/initialization_viewmodel.dart';

class InitializationView extends ConsumerStatefulWidget {
  final String flavor;

  InitializationView({required this.flavor});

  @override
  _InitializationViewState createState() => _InitializationViewState();
}

class _InitializationViewState extends ConsumerState<InitializationView> {
  late InitializationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ref.read(initializationViewModelProvider);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _viewModel.initializeApp();
    _checkNetworkAndLoadData();
  }

  Future<void> _checkNetworkAndLoadData() async {
    final isConnected = await _viewModel.checkNetworkConnectivity();
    if (isConnected) {
      await Future.delayed(Duration(seconds: 3)); // Simulate a delay
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeView()));
    } else {
      _showNetworkError();
    }
  }

  void _showNetworkError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Network Error'),
        content: Text('There is a problem with the network connection. Please check your connection.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyGame()));
            },
            child: Text('Play Game'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkNetworkAndLoadData(); // Retry
            },
            child: Text('Retry'),
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
