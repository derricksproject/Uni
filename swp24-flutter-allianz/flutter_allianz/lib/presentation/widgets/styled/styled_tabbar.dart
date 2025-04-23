import 'package:flutter/material.dart';


/// This widget wraps a `TabBar` and provides a custom-styled tab bar.
///
/// **Author**: Timo Gehrke
class StyledTabBar extends StatelessWidget implements PreferredSizeWidget{
  final List<Tab> tabs;
  final TabController? controller;

  const StyledTabBar({
    super.key, 
    required this.tabs,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final TabController tabController = controller ?? DefaultTabController.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: tabController,
            tabs: tabs,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            isScrollable: true,
          ),
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(1);
}