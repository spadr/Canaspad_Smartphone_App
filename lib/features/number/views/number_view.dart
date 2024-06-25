import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/number_data_list_item.dart';
import '../viewmodels/number_data_state.dart';
import 'number_detail_view.dart';

class NumberView extends ConsumerStatefulWidget {
  @override
  _NumberViewState createState() => _NumberViewState();
}

class _NumberViewState extends ConsumerState<NumberView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(numberDataViewModelProvider.notifier).loadNumberData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(numberDataViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Number View'),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, NumberDataState state) {
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
          final numberData = state.data[index];
          return NumberDataListItem(
            numberData: numberData,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NumberDetailView(numberData: numberData),
              ),
            ),
          );
        },
      );
    }
  }
}
