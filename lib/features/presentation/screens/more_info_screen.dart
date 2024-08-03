import 'package:flutter/material.dart';
import '../widgets/bottom_bar_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/more_info_body.dart';


class MoreInfoScreen extends StatelessWidget {
  const MoreInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: true, paddingLogo: 10,),
      backgroundColor: const Color(0xff000000),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: MoreInfoBody(),
            ),
          ),
          // BottomBarWidget will stay at the bottom of the screen
          BottomBarWidget(),
        ],
      ),
    );
  }
}
