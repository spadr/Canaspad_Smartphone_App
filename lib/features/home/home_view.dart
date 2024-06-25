import 'package:flutter/material.dart';

import '../environment/views/environment_view.dart';
import '../image/image_view.dart';
import '../notification/notification_view.dart';
import '../number/views/number_view.dart';
import '../setting/setting_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedTabIndex = 0;

  static List<_TabItem> _tabItems = [
    _TabItem(icon: Icons.trending_up, label: 'Number', view: NumberView(), key: Key('NumberTab')),
    _TabItem(icon: Icons.movie, label: 'Image', view: ImageView(), key: Key('ImageTab')),
    _TabItem(icon: Icons.notifications, label: 'Notification', view: NotificationView(), key: Key('NotificationTab')),
    _TabItem(icon: Icons.settings, label: 'Setting', view: SettingView(), key: Key('SettingTab')),
    _TabItem(icon: Icons.eco, label: 'Environment', view: EnvironmentView(), key: Key('EnvironmentTab')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabItems[_selectedTabIndex].view,
      bottomNavigationBar: BottomNavigationBar(
        items: _tabItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon, key: item.key),
                  label: item.label,
                ))
            .toList(),
        currentIndex: _selectedTabIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final Widget view;
  final Key key;

  const _TabItem({required this.icon, required this.label, required this.view, required this.key});
}
