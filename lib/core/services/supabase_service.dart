import 'package:canaspad/data/mock/sensing_data_sample.dart';
import 'package:canaspad/data/models/data_model.dart';
import 'package:canaspad/data/models/numeric_data_model.dart';
import 'package:canaspad/data/models/sensor_model.dart';
import 'package:canaspad/features/image/models/image_model.dart';
import 'package:canaspad/features/notification/models/notification_model.dart';
import 'package:canaspad/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// データキャッシュクラス
class DataCache {
  List<Map<String, dynamic>>? _allData;
  Map<String, List<ImageData>> _imageDataCache = {};

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

  void cacheImageData(String sensorId, List<ImageData> imageData) {
    _imageDataCache[sensorId] = imageData;
  }

  List<ImageData>? getCachedImageData(String sensorId) {
    return _imageDataCache[sensorId];
  }
}

abstract class SupabaseService {
  Future<void> fetchAllData();
  List<NumericData> getNumericData();
  Data? getLatestNumericData(String sensorId);
  List<Sensor> getSensors();
  Future<List<ImageSensor>> getImageSensors();
  Future<List<ImageData>> getImageDataForSensor(String sensorId, {int minutes = 30});
}

class RealSupabaseService implements SupabaseService {
  final SupabaseClient _client;
  final NotificationViewModel _notificationViewModel;
  final DataCache _cache = DataCache();

  RealSupabaseService(this._client, this._notificationViewModel);

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
      final errorNotification = NotificationModel(
        title: 'Supabase Error',
        message: '$e',
        type: 'error',
        status: 'unread',
        scheduledTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _notificationViewModel.addNotification(errorNotification);
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

  @override
  List<Sensor> getSensors() {
    return mockSensors;
  }

  @override
  Future<List<ImageSensor>> getImageSensors() async {
    final response = await _client.from('sensor').select('''
      *,
      data (
        sensor_id,
        public_id,
        created_at,
        file_path
      )
    ''').eq('data_type', 'jpg').or('data_type.eq.png');

    return response.map((json) => ImageSensor.fromJson(json)).toList();
  }

  @override
  Future<List<ImageData>> getImageDataForSensor(String sensorId, {int minutes = 30}) async {
    final now = DateTime.now();
    final startTime = now.subtract(Duration(minutes: minutes));

    final response = await _client.from('data').select().eq('sensor_id', sensorId).gte('created_at', startTime.toIso8601String()).order('created_at');

    return response.map((json) => ImageData.fromJson(json)).toList();
  }
}

class MockSupabaseService implements SupabaseService {
  final DataCache _cache = DataCache();
  int _counter = 0;
  List<ImageSensor> _mockImageSensors = []; // モックの画像センサーデータを保持
  bool _isInitialized = false; // 初期化フラグをプライベートに変更

  MockSupabaseService() {
    _initializeMockImageSensors();
  }

  // モックの画像センサーデータを初期化する関数
  Future<void> _initializeMockImageSensors() async {
    if (_isInitialized) {
      return;
    }
    _mockImageSensors = await getMockImageSensors();
    _mockImageSensors.forEach((sensor) {
      _cache.cacheImageData(sensor.publicId, sensor.data);
    });
    _isInitialized = true;
  }

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
                  'value': data.value! + _counter,
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

  @override
  List<Sensor> getSensors() {
    return _cache.getAllData()!.map((data) => Sensor.fromJson(data)).toList();
  }

  @override
  Future<List<ImageSensor>> getImageSensors() async {
    await _initializeMockImageSensors();
    return _mockImageSensors;
  }

  @override
  Future<List<ImageData>> getImageDataForSensor(String sensorId, {int minutes = 30}) async {
    // キャッシュされた画像データを取得
    final cachedImageData = _cache.getCachedImageData(sensorId);
    if (cachedImageData != null) {
      return cachedImageData;
    } else {
      // キャッシュがない場合は空リストを返す
      return [];
    }
  }

  bool get isInitialized => _isInitialized;
}
