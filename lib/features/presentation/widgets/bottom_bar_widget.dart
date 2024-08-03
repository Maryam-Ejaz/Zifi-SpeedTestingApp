import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomBarWidget extends StatelessWidget {
  // Define URLs for each SVG
  final String _leftUrl = 'https://ztfr.org/'; // Replace with your URL
  final String _centerUrl = 'https://zimogroup.org/'; // Replace with your URL
  final String _rightUrl = 'https://www.zimomeet.com/'; // Replace with your URL

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.0,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bottom Left Image
          GestureDetector(
            onTap: () => _launchURL(_leftUrl),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SvgPicture.asset(
                'assets/icons/ZTFR w.svg',
                color: Colors.white,
                height: 20.0,
                allowDrawingOutsideViewBox: true,
              ),
            ),
          ),
          // Bottom Center Image
          GestureDetector(
            onTap: () => _launchURL(_centerUrl),
            child: SvgPicture.asset(
              'assets/icons/ZIG - ZIMO GROUP W.svg',
              color: Colors.white,
              height: 22.0,
              allowDrawingOutsideViewBox: true,
            ),
          ),
          // Bottom Right Image
          GestureDetector(
            onTap: () => _launchURL(_rightUrl),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SvgPicture.asset(
                'assets/icons/ZIMO MEET masked W.svg',
                color: Colors.white,
                height: 22.0,
                allowDrawingOutsideViewBox: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
