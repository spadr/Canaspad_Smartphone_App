import 'package:canaspad/data/mock/sensing_data_sample.dart';
import 'package:canaspad/data/models/data_model.dart';
import 'package:canaspad/data/models/numeric_data_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// データキャッシュクラス
class DataCache {
  List<Map<String, dynamic>>? _allData;

  void setAllData(List<Map<String, dynamic>> data) {
    _allData = data;
  }

  List<Map<String, dynamic>>? getAllData() {
    return _allData;
  }

  List<NumericData> getNumericData() {
    if (_allData == null) {
      return [];
    }
    final numericData = _allData!
        .where((data) => (data['data_type'] as String?)?.toLowerCase().contains('numeric') ?? false)
        .map((data) {
          try {
            return NumericData.fromJson(data);
          } catch (e) {
            return null;
          }
        })
        .whereType<NumericData>()
        .toList();
    return numericData;
  }

  Data? getLatestNumericData(String sensorId) {
    if (_allData == null) return null;
    var sensorData = _allData!.firstWhere((data) => data['public_id'] == sensorId, orElse: () => {});
    if (sensorData.isEmpty) return null;

    var dataList = sensorData['data'] as List<dynamic>;
    if (dataList.isEmpty) return null;

    var latestData = dataList.reduce((a, b) => DateTime.parse(a['created_at']).isAfter(DateTime.parse(b['created_at'])) ? a : b);
    return Data.fromJson(latestData);
  }
}

abstract class SupabaseService {
  Future<void> fetchAllData();
  List<NumericData> getNumericData();
  Data? getLatestNumericData(String sensorId);
}

class RealSupabaseService implements SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;
  final DataCache _cache = DataCache();

  @override
  Future<void> fetchAllData() async {
    try {
      final response = await _client.from('sensor').select('''
          public_id,
          "group",
          name,
          data_type,
          created_at,
          updated_at,
          data (
            sensor_id,
            public_id,
            created_at,
            value,
            file_path
          )
        ''').limit(10000, referencedTable: 'data');
      _cache.setAllData(response);
    } catch (e) {
      throw Exception('Error fetching all data: $e');
    }
  }

  @override
  List<NumericData> getNumericData() {
    return _cache.getNumericData();
  }

  @override
  Data? getLatestNumericData(String sensorId) {
    return _cache.getLatestNumericData(sensorId);
  }
}

class MockSupabaseService implements SupabaseService {
  final DataCache _cache = DataCache();

  @override
  Future<void> fetchAllData() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    final mockAllData = mockSensors.map((sensor) {
      final sensorData = mockData.where((data) => data.sensorId == sensor.publicId).toList();
      return {
        'public_id': sensor.publicId,
        'group': sensor.group,
        'name': sensor.name,
        'data_type': sensor.dataType,
        'created_at': sensor.createdAt.toIso8601String(),
        'updated_at': sensor.updatedAt.toIso8601String(),
        'data': sensorData
            .map((data) => {
                  'sensor_id': data.sensorId,
                  'public_id': data.publicId,
                  'created_at': data.createdAt?.toIso8601String(),
                  'value': data.value,
                  'file_path': data.filePath,
                })
            .toList(),
      };
    }).toList();
    _cache.setAllData(mockAllData);
  }

  @override
  List<NumericData> getNumericData() {
    return _cache.getNumericData();
  }

  @override
  Data? getLatestNumericData(String sensorId) {
    return _cache.getLatestNumericData(sensorId);
  }
}
