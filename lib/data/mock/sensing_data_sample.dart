import 'dart:math';

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
