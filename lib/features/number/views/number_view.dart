import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/number_data_list_item.dart';
import '../viewmodels/number_data_state.dart';
import 'number_detail_view.dart';

class NumericView extends ConsumerStatefulWidget {
  @override
  _NumericViewState createState() => _NumericViewState();
}

class _NumericViewState extends ConsumerState<NumericView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(numericDataViewModelProvider.notifier).loadNumericData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(numericDataViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Numeric View'),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, NumericDataState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    } else if (state.data.isEmpty) {
      return Center(child: Text('No data available'));
    } else {
      return ListView.builder(
        itemCount: state.data.length,
        itemBuilder: (context, index) {
          final numericData = state.data[index];
          return NumericDataListItem(
            numericData: numericData,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NumberDetailView(numericData: numericData),
              ),
            ),
          );
        },
      );
    }
  }
}
