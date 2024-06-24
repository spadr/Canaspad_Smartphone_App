import 'package:supabase_flutter/supabase_flutter.dart';

import '../mock_data/sensing_data_sample.dart';
import '../models/data_model.dart';
import '../models/sensing_data_model.dart';
import '../models/sensor_model.dart';

abstract class SupabaseService {
  Future<List<SensingData>> fetchSensingData();
  Future<Data> fetchLatestData(String sensorId);
}

class RealSupabaseService implements SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<SensingData>> fetchSensingData() async {
    try {
      final response = await _client.from('SENSOR').select();
      final sensors = (response as List).map((sensor) => Sensor.fromJson(sensor)).toList();

      List<SensingData> sensingDataList = [];
      for (var sensor in sensors) {
        final dataResponse = await _client.from('DATA').select().eq('sensor_id', sensor.publicId);
        final data = (dataResponse as List).map((data) => Data.fromJson(data)).toList();
        sensingDataList.add(SensingData.fromJson(sensor.toJson(), data));
      }

      return sensingDataList;
    } catch (e) {
      throw Exception('Error fetching sensing data: $e');
    }
  }

  @override
  Future<Data> fetchLatestData(String sensorId) async {
    final response = await _client.from('DATA').select().eq('sensor_id', sensorId).order('created_at', ascending: false).limit(1).single();

    return Data.fromJson(response);
  }
}

class MockSupabaseService implements SupabaseService {
  @override
  Future<List<SensingData>> fetchSensingData() async {
    // モックデータを返す
    return mockSensors.map((sensor) {
      final sensorData = mockData.where((data) => data.sensorId == sensor.publicId).toList();
      return SensingData.fromJson(sensor.toJson(), sensorData);
    }).toList();
  }

  @override
  Future<Data> fetchLatestData(String sensorId) async {
    // モックデータから最新のデータを返す
    final sensorData = mockData.where((data) => data.sensorId == sensorId).toList();
    return sensorData.isNotEmpty
        ? sensorData.last
        : Data(
            sensorId: sensorId,
            publicId: 'mock_data_1',
            createdAt: DateTime.now(),
            value: 25.0,
            filePath: 'path/to/mock_file',
          );
  }
}
