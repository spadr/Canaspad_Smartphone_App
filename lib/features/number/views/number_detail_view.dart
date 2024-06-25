import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../data/models/data_model.dart';
import '../../../data/models/number_data_model.dart';

class NumberDetailView extends StatelessWidget {
  final NumberData numberData;

  NumberDetailView({required this.numberData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${numberData.group} - ${numberData.name}'),
      ),
      body: Column(
        children: [
          Text('Sensor: ${numberData.name}'),
          Text('Group: ${numberData.group}'),
          Text('Data Type: ${numberData.dataType}'),
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
                  dataSource: numberData.data,
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
