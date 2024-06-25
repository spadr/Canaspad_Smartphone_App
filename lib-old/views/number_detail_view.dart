import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/data_model.dart';
import '../models/sensing_data_model.dart';

class NumberDetailView extends StatelessWidget {
  final SensingData sensingData;

  NumberDetailView({required this.sensingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${sensingData.group} - ${sensingData.name}'),
      ),
      body: Column(
        children: [
          Text('Sensor: ${sensingData.name}'),
          Text('Group: ${sensingData.group}'),
          Text('Data Type: ${sensingData.dataType}'),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                title: AxisTitle(text: 'Time'),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: 'Value'),
              ),
              series: <CartesianSeries>[
                LineSeries<Data, DateTime>(
                  dataSource: sensingData.data,
                  xValueMapper: (Data data, _) => data.createdAt,
                  yValueMapper: (Data data, _) => data.value,
                )
              ],
              title: ChartTitle(text: 'Time Series Data'),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
        ],
      ),
    );
  }
}
