import 'package:canaspad/core/services/app_state_service.dart';
import 'package:canaspad/features/environment/views/environment_view.dart';
import 'package:canaspad/features/home/home_view.dart';
import 'package:canaspad/features/initialization/viewmodels/initialization_viewmodel.dart';
import 'package:canaspad/features/notification/models/notification_model.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitializationView extends ConsumerWidget {
  final String flavor;

  InitializationView({required this.flavor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(initializationViewModelProvider).initializeApp();
    final appState = ref.watch(appStateServiceProvider);

    return Scaffold(
      body: Center(
        child: appState.when(
          loading: () => CircularProgressIndicator(),
          error: (error, _) => _handleError(context, ref, error),
          data: (environment) {
            if (environment == null) {
              // 環境設定がない場合、環境設定画面に遷移
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => EnvironmentView()),
                );
              });
              return CircularProgressIndicator();
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeView()),
              );
            });
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget _handleError(BuildContext context, WidgetRef ref, Object error) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _recordErrorNotification(ref, error.toString());
      // エラーが発生した場合も、HomeViewに遷移します
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeView()),
      );
    });
    return CircularProgressIndicator();
  }

  Future<void> _recordErrorNotification(WidgetRef ref, String errorMessage) async {
    final notificationViewModel = ref.read(notificationViewModelProvider.notifier);
    final errorNotification = NotificationModel(
      title: 'Initialization Error',
      message: 'An error occurred during initialization: $errorMessage',
      type: 'error',
      status: 'unread',
      scheduledTime: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await notificationViewModel.addNotification(errorNotification);
  }
}
