// lib/data/mock/mock_data.dart

import '../../features/sync/models/image_data.dart';
import '../../features/sync/models/numeric_data.dart';
import '../../features/sync/models/numeric_sensor.dart';
import '../../features/sync/models/sensor.dart';

class MockData {
  static List<Sensor> get sensors => [
        // 疑似センサーデータを10個再帰的再帰的に生成
        for (var i = 0; i < 10; i++)
          NumericSensor(
            id: 'sensor$i',
            groupName: 'group$i',
            name: 'sensor$i',
            sensorType: 'numeric',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            data: numericData,
            unit: 'unit',
          ),
      ];

  static List<NumericData> get numericData => [
        // 疑似数値データ
        NumericData(
          id: 'data1',
          timestamp: DateTime.now(),
          value: 25.5,
          createdByUserId: 'user1',
        ),
        // 他の数値データ...
      ];

  static List<ImageData> get imageData => [
        // 疑似画像データ
        ImageData(
          id: 'image1',
          timestamp: DateTime.now(),
          filePath: 'assets/images/mock_image.jpg',
          createdByUserId: 'user1',
        ),
        // 他の画像データ...
      ];
}
