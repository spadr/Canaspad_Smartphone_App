import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/secure_storage_service.dart';
import 'environment_detail_view.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class EnvironmentView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageService = ref.watch(secureStorageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Environment'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EnvironmentDetailView(
                    environmentData: {
                      'anon_key': null,
                      'supabase_url': null,
                      'env_name': null,
                      'password': null,
                      'email_address': null,
                      'front_end_url': null,
                      'selected': null,
                      'session': null,
                    },
                    index: -1,
                    onSave: (newData) async {
                      final existingData = await storageService.getEnvironmentSettings('envSettings');
                      List<dynamic> settingsList = existingData != null ? jsonDecode(existingData) : [];
                      settingsList.add(newData);
                      await storageService.saveEnvironmentSettings('envSettings', jsonEncode(settingsList));
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: storageService.getEnvironmentSettings('envSettings'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading settings'));
          }
          List<dynamic> settingsList = jsonDecode(snapshot.data!);
          return ListView.builder(
            itemCount: settingsList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(settingsList[index]['env_name'] ?? 'Environment ${index + 1}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EnvironmentDetailView(
                        environmentData: settingsList[index],
                        index: index,
                        onSave: (updatedData) async {
                          settingsList[index] = updatedData;
                          await storageService.saveEnvironmentSettings('envSettings', jsonEncode(settingsList));
                        },
                        onDelete: () async {
                          settingsList.removeAt(index);
                          await storageService.saveEnvironmentSettings('envSettings', jsonEncode(settingsList));
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
