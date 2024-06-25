import 'package:flutter/material.dart';

import '../../models/sensing_data_model.dart';

class NumberDataListItem extends StatelessWidget {
  final SensingData sensingData;
  final VoidCallback onTap;

  const NumberDataListItem({
    Key? key,
    required this.sensingData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final latestData = sensingData.data.isNotEmpty ? sensingData.data.last.value : 'N/A';

    return ListTile(
      title: Text('${sensingData.group} - ${sensingData.name}'),
      subtitle: Text('Latest Value: $latestData ${sensingData.dataType}'),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
