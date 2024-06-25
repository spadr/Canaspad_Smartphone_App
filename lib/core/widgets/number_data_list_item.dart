import 'package:flutter/material.dart';

import '../../data/models/number_data_model.dart';

class NumberDataListItem extends StatelessWidget {
  final NumberData numberData;
  final VoidCallback onTap;

  const NumberDataListItem({
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
