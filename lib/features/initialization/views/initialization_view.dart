import 'package:canaspad/core/services/app_state_service.dart';
import 'package:canaspad/features/home/home_view.dart';
import 'package:canaspad/features/mini_game/game_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitializationView extends ConsumerWidget {
  final String flavor;

  InitializationView({required this.flavor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateServiceProvider);

    return Scaffold(
      body: Center(
        child: appState.when(
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => _buildErrorWidget(context, ref, error.toString()),
          data: (environment) {
            if (environment != null) {
              // ログイン成功時、HomeViewに遷移
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeView()),
                );
              });
              return CircularProgressIndicator();
            } else {
              // 環境設定がない場合の処理
              return Text('No environment configured. Please set up the environment.');
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: $error'),
        ElevatedButton(
          onPressed: () => ref.read(appStateServiceProvider.notifier).initializeApp(),
          child: Text('Retry'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MyGame()),
            );
          },
          child: Text('Play Game'),
        ),
      ],
    );
  }
}
