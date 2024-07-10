import 'dart:math';

import 'package:canaspad/core/utils/image_generator.dart';
import 'package:canaspad/features_old/image/models/image_model.dart';

import '../models/data_model.dart';
import '../models/sensor_model.dart';

final mockSensors = [
  for (int i = 1; i <= 10; i++)
    Sensor(
      publicId: 'temperature_sensor_$i',
      group: 'Ridge $i',
      name: 'Temperature Sensor $i',
      dataType: 'Numeric<float>',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  for (int i = 1; i <= 10; i++)
    Sensor(
      publicId: 'humidity_sensor_$i',
      group: 'Ridge $i',
      name: 'Humidity Sensor $i',
      dataType: 'Numeric<float>',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  for (int i = 1; i <= 10; i++)
    Sensor(
      publicId: 'water_level_sensor_$i',
      group: 'Ridge $i',
      name: 'Water Level Sensor $i',
      dataType: 'Numeric<float>',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  for (int i = 1; i <= 10; i++)
    Sensor(
      publicId: 'co2_sensor_$i',
      group: 'Ridge $i',
      name: 'CO2 Sensor $i',
      dataType: 'Numeric<float>',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  for (int i = 1; i <= 10; i++)
    Sensor(
      publicId: 'light_sensor_$i',
      group: 'Ridge $i',
      name: 'Light Sensor $i',
      dataType: 'Numeric<float>',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
];

final random = Random();

final mockData = [
  for (int i = 0; i < 144; i++)
    for (int j = 1; j <= 10; j++)
      Data(
        sensorId: 'temperature_sensor_$j',
        publicId: 'temperature_data_${j}_$i',
        createdAt: DateTime.now().subtract(Duration(minutes: i * 10)),
        value: 20 + random.nextDouble() * 10,
        filePath: null,
      ),
  for (int i = 0; i < 144; i++)
    for (int j = 1; j <= 10; j++)
      Data(
        sensorId: 'humidity_sensor_$j',
        publicId: 'humidity_data_${j}_$i',
        createdAt: DateTime.now().subtract(Duration(minutes: i * 10)),
        value: 40 + random.nextDouble() * 20,
        filePath: null,
      ),
  for (int i = 0; i < 144; i++)
    for (int j = 1; j <= 10; j++)
      Data(
        sensorId: 'water_level_sensor_$j',
        publicId: 'water_level_data_${j}_$i',
        createdAt: DateTime.now().subtract(Duration(minutes: i * 10)),
        value: 20 + random.nextDouble() * 30,
        filePath: null,
      ),
  for (int i = 0; i < 144; i++)
    for (int j = 1; j <= 10; j++)
      Data(
        sensorId: 'co2_sensor_$j',
        publicId: 'co2_data_${j}_$i',
        createdAt: DateTime.now().subtract(Duration(minutes: i * 10)),
        value: 300 + random.nextDouble() * 200,
        filePath: null,
      ),
  for (int i = 0; i < 144; i++)
    for (int j = 1; j <= 10; j++)
      Data(
        sensorId: 'light_sensor_$j',
        publicId: 'light_data_${j}_$i',
        createdAt: DateTime.now().subtract(Duration(minutes: i * 10)),
        value: 500 + random.nextDouble() * 1000,
        filePath: null,
      ),
];

// モックの画像センサーデータ
final mockImageSensors = [
  for (int i = 1; i <= 5; i++)
    ImageSensor(
      publicId: 'camera_sensor_$i',
      group: 'Area $i',
      name: 'Camera Sensor $i',
      dataType: 'jpg',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now(),
      data: List.generate(
          10,
          (index) => ImageData(
                sensorId: 'camera_sensor_$i',
                publicId: 'image_data_${i}_$index',
                createdAt: DateTime.now().subtract(Duration(minutes: index * 30)),
                image: null,
                filePath: 'https://picsum.photos/seed/${i * 10 + index}/300/200',
              )),
    ),
];

// モックの画像センサーデータを取得する非同期関数
Future<List<ImageSensor>> getMockImageSensors() async {
  List<ImageSensor> sensors = [];
  for (int i = 1; i <= 10; i++) {
    List<ImageData> sensorData = [];
    for (int j = 0; j < 100; j++) {
      final createdAt = DateTime.now().subtract(Duration(minutes: j * 30));
      final image = await ImageGenerator.generateImage('Mock Image ${i}_$j', width: 300, height: 200); // ImageGeneratorで画像生成
      sensorData.add(ImageData(
        sensorId: 'camera_sensor_$i',
        publicId: 'image_data_${i}_$j',
        createdAt: createdAt,
        image: image, // 生成した画像をセット
        filePath: 'https://picsum.photos/seed/${i * 10 + j}/300/200', // 本番環境用のパスも保持
      ));
    }
    sensors.add(ImageSensor(
      publicId: 'camera_sensor_$i',
      group: 'Area $i',
      name: 'Camera Sensor $i',
      dataType: 'jpg',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now(),
      data: sensorData,
    ));
  }
  return sensors;
}
