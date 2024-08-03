import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../Core/models/speed_test_data.dart';
import '../../../Core/providers/ip_provider.dart';
import '../../../Core/providers/location_provider.dart';
import '../../../Core/providers/speed_test_provider.dart';
import '../animations/fade_animation.dart';
import 'package:intl/intl.dart';


class MoreInfoBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final speedTestProvider = Provider.of<SpeedTestProvider>(context);
    final ipProvider = Provider.of<IpProvider>(context);

    final String countryCode = locationProvider.code;
    final String city = locationProvider.city.toString().toUpperCase();
    final String country = locationProvider.country.toString().toUpperCase();
    final String latitude = locationProvider.latitude.toString().toUpperCase();
    final String longitude = locationProvider.longitude.toString();
    final SpeedTestData? Speed = speedTestProvider.data;
    final String? uploadSpeed = Speed?.uploadSpeed.toStringAsFixed(2);
    final String? downloadSpeed = Speed?.downloadSpeed.toStringAsFixed(2);
    final String internalIp = ipProvider.internalIP;
    final String externalIp = ipProvider.externalIP;
    final String macAddress = ipProvider.mac; // Example data
    final String? provider = Speed?.isp.toString().toUpperCase();
    final String router = ipProvider.wifiName.toString().toUpperCase();
    final String? server = Speed?.server.toString().toUpperCase();
    final String ping = ipProvider.ping.toString();


    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d/M/y').format(now);
    String formattedTime = DateFormat('HH:mm').format(now);

    double appBarHeight = MediaQuery.of(context).padding.top;
    double screenHeight = MediaQuery.of(context).size.height - appBarHeight;
    double screenWidth = MediaQuery.of(context).size.width;

    // Sizes and paddings based on screen dimensions
    double titleHeight = screenHeight * 0.01;
    double speedTextSize = screenHeight * 0.125;
    double iconSize = screenHeight * 0.025;
    double textSize = screenHeight * 0.012;
    double buttonSize = screenHeight * 0.12;
    double padding = screenWidth * 0.03;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 35),
            // Title
            FadeAnimation(
              delay: 0.5,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.001),
                child: Text(
                  "MORE INFORMATION",
                  style: GoogleFonts.lato(
                    fontSize: screenHeight * 0.015, // Adjusted font size for title
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Download Speed
            FadeAnimation(
              delay: 0.6,
              child: Container(
                padding: const EdgeInsets.only(top: 30.3),
                child: Text(
                  downloadSpeed!,
                  style: GoogleFonts.lato(
                    fontSize: speedTextSize,
                    height: 0.95,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            FadeAnimation(
              delay: 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "DOWNLOAD",
                    style: GoogleFonts.lato(
                      fontSize: screenHeight * 0.012,
                      letterSpacing: 2,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/icons/ZIFI Download Arrow Green.svg',
                        color: Colors.green,
                        width: 0.1,
                        height: iconSize,
                      ),
                      const SizedBox(width: 12),
                      // Mbps Text Image
                      SvgPicture.asset(
                        'assets/icons/mbps.svg',
                        width: screenWidth * 0.05,
                        height: screenHeight * 0.03,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Upload Speed
            FadeAnimation(
              delay: 0.6,
              child: Container(
                padding: const EdgeInsets.only(top: 25.3),
                child: Text(
                  uploadSpeed!,
                  style: GoogleFonts.lato(
                    fontSize: speedTextSize, // Adjusted for better visibility
                    letterSpacing: 2,
                    height: 0.95,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            FadeAnimation(
              delay: 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "UPLOAD",
                    style: GoogleFonts.lato(
                      fontSize: screenHeight * 0.012,
                      height: 1.4,
                      letterSpacing: 2,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/icons/ZIFI Upload Arrow Purple.svg',
                        color: Colors.blueAccent,
                        width: iconSize,
                        height: iconSize,
                      ),
                      const SizedBox(width: 12),
                      // Mbps Text Image
                      SvgPicture.asset(
                        'assets/icons/mbps.svg',
                        width: screenWidth * 0.05,
                        height: screenHeight * 0.03,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 45),
            // Location Section with 3 Columns
            FadeAnimation(
              delay: 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // First Column: Flag
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CountryFlag.fromCountryCode(
                          countryCode, // Use the country code from the provider
                          width: 26,
                          height: 26,
                          shape: const RoundedRectangle(4),
                        ),
                      ],
                    ),
                  ),
                  //  City Country
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "CITY",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "COUNTRY",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            height: 1.5,
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Third Column: Location Texts
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          city, // Replace with dynamic city data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          country, // Replace with dynamic country data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 21),
            // New Section with Additional Info
            FadeAnimation(
              delay: 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // User Icon Column
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons/ZIFI User Icon.svg',
                          color: Colors.white,
                          width: 25,
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                  // Latitude, Longitude, Internal IP, External IP, MAC Address Columns
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "LATITUDE",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "LONGITUDE",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "INTERNAL IP",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "EXTERNAL IP",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "MAC ADDRESS",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Third Column: Location Texts
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          longitude, // Replace with dynamic city data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          latitude, // Replace with dynamic country data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          internalIp, // Replace with dynamic city data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          externalIp, // Replace with dynamic country data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          macAddress, // Replace with dynamic country data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 21),
            FadeAnimation(
              delay: 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // User Icon Column
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons/ZIFI Wifi Icon W.svg',
                          color: Colors.white,
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  // Router, Provide, server and ping Columns
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "PROVIDER",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "ROUTER NAME",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "SERVER",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "PING",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Third Column: Location Texts
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          provider!, // Replace with dynamic city data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          router, // Replace with dynamic country data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          server!, // Replace with dynamic city data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ping, // Replace with dynamic country data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 21),
            FadeAnimation(
              delay: 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // First Column: Flag
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons/ZIFI User Icon.svg',
                          color: Colors.black,
                          width: 25,
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                  //  City Country
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "DATE",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "TIME",
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            height: 1.5,
                            letterSpacing: 1.2,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Third Column: Location Texts
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          formattedDate, // Replace with dynamic city data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          formattedTime, // Replace with dynamic country data
                          style: GoogleFonts.lato(
                            fontSize: textSize,
                            letterSpacing: 1.2,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
