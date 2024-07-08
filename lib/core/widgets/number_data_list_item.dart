import 'package:flutter/material.dart';

import '../../data/models/numeric_data_model.dart';

class NumericDataListItem extends StatelessWidget {
  final NumericData numericData;
  final VoidCallback onTap;

  const NumericDataListItem({
    Key? key,
    required this.numericData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final latestData = numericData.data.isNotEmpty ? numericData.data.last.value : 'N/A';

    return ListTile(
      title: Text('${numericData.group} - ${numericData.name}'),
      subtitle: Text('Latest Value: $latestData ${numericData.dataType}'),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
