import 'package:flutter/material.dart';

import '../../data/models/numeric_data_model.dart';

class NumericDataListItem extends StatelessWidget {
  final NumericData numberData;
  final VoidCallback onTap;

  const NumericDataListItem({
    Key? key,
    required this.numberData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final latestData = numberData.data.isNotEmpty ? numberData.data.last.value : 'N/A';

    return ListTile(
      title: Text('${numberData.group} - ${numberData.name}'),
      subtitle: Text('Latest Value: $latestData ${numberData.dataType}'),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
