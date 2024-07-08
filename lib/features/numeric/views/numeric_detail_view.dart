import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../data/models/data_model.dart';
import '../../../data/models/numeric_data_model.dart';

class NumberDetailView extends StatelessWidget {
  final NumericData numericData;

  NumberDetailView({required this.numericData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${numericData.group} - ${numericData.name}'),
      ),
      body: Column(
        children: [
          Text('Sensor: ${numericData.name}'),
          Text('Group: ${numericData.group}'),
          Text('Data Type: ${numericData.dataType}'),
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
                  dataSource: numericData.data,
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
