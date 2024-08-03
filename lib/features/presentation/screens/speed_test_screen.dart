import 'package:flutter/material.dart';
import '../widgets/bottom_bar_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/speed_test_body.dart';

class SpeedTestScreen extends StatelessWidget {
  const SpeedTestScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showBackButton: false, paddingLogo: 50,),
      backgroundColor: const Color(0xff000000),
      body: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              child: SpeedTestBody(),
            ),
          ),
          BottomBarWidget(),
        ],
      ),
    );
  }
}



