import 'package:datn/database/firestore/firestore_service.dart';
import 'package:datn/screen/learner/dash_board_learning.dart';
import 'package:datn/screen/learner/dash_board_main.dart';
import 'package:datn/screen/learner/dash_board_other.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DashBoardScreenState();
  }
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int currentPageIndex = 0;
  final List<Widget> _children = [
    const DashBoardMain(),
    const DashBoardLearning(),
    const DashBoardOther()
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirestoreService>(create:(context)=> FirestoreService())
      ],
      child: Scaffold(
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
              NavigationDestination(
                  icon: Icon(Icons.people_alt_outlined), label: 'Đang học'),
              NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined), label: 'Khác'),
            ],
          ),
          appBar: AppBar(
            title: const Text('Learner Screen'),
          ),
          body: _children[currentPageIndex]),
    );
  }
}
