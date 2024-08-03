import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/providers/location_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final double paddingLogo;

  const CustomAppBar({required this.showBackButton, required this.paddingLogo});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(55.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late Future<String> _countryCodeFuture;
  late String countryCode;

  @override
  void initState() {
    super.initState();
    _countryCodeFuture = _getCountryCode();
  }

  Future<String> _getCountryCode() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    countryCode = locationProvider.code;
    return locationProvider.code;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _countryCodeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for countryCode
          return AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: widget.showBackButton
                ? Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.05 * 0.15),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Arrow Back W Web.svg',
                  color: Colors.white,
                  width: MediaQuery.of(context).size.height * 0.05 * 0.5,
                  height: MediaQuery.of(context).size.height * 0.05 * 0.5,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
                : null,
            title: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(widget.paddingLogo, 0, 0, 0),
                child: SvgPicture.asset(
                  'assets/icons/Zifi W.svg',
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.05 * 0.55,
                ),
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.05 * 0.30),
                child: CountryFlag.fromCountryCode(
                  'Unknown', // Placeholder until data is available
                  width: 32,
                  height: 40,
                  shape: const RoundedRectangle(4),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          // Handle errors if any
          print('Error fetching countryCode: ${snapshot.error}');
          return AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: widget.showBackButton
                ? Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.05 * 0.15),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Arrow Back W Web.svg',
                  color: Colors.white,
                  width: MediaQuery.of(context).size.height * 0.05 * 0.5,
                  height: MediaQuery.of(context).size.height * 0.05 * 0.5,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
                : null,
            title: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(widget.paddingLogo, 0, 0, 0),
                child: SvgPicture.asset(
                  'assets/icons/Zifi W.svg',
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.05 * 0.55,
                ),
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.05 * 0.30),
                child: CountryFlag.fromCountryCode(
                  countryCode, // Placeholder until data is available
                  width: 32,
                  height: 40,
                  shape: const RoundedRectangle(4),
                ),
              ),
            ],
          );
        } else {
          final countryCode = snapshot.data ?? 'Unknown';

          return AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: widget.showBackButton
                ? Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.05 * 0.15),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/Arrow Back W Web.svg',
                  color: Colors.white,
                  width: MediaQuery.of(context).size.height * 0.05 * 0.5,
                  height: MediaQuery.of(context).size.height * 0.05 * 0.5,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
                : null,
            title: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(widget.paddingLogo, 0, 0, 0),
                child: SvgPicture.asset(
                  'assets/icons/Zifi W.svg',
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.05 * 0.55,
                ),
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.05 * 0.30),
                child: CountryFlag.fromCountryCode(
                  countryCode,
                  width: 32,
                  height: 40,
                  shape: const RoundedRectangle(4),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
