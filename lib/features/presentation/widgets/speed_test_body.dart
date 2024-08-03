import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:r_get_ip/r_get_ip.dart';
import 'package:speed_test_port/classes/server.dart';
import 'package:speed_test_port/classes/speed_test_result.dart';
import 'package:speed_test_port/speed_test_port_stream.dart';
import '../../../Core/providers/ip_provider.dart';
import '../../../Core/providers/speed_test_provider.dart';
import '../animations/fade_animation.dart';
import '../screens/more_info_screen.dart';
import 'package:mac_address/mac_address.dart';
import 'package:bluetooth_info/bluetooth_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speed_test_port/speed_test_port.dart';

class SpeedTestBody extends StatefulWidget {
  const SpeedTestBody({super.key});

  @override
  _SpeedTestBodyState createState() => _SpeedTestBodyState();
}

class _SpeedTestBodyState extends State<SpeedTestBody> {
  final FlutterInternetSpeedTest _internetSpeedTest = FlutterInternetSpeedTest()
    ..enableLog();
  bool _testInProgress = false;
  bool _isCancelled = false;
  bool _isServerSelectionProgress = false;
  bool _testCompleted = false;
  double _downloadRate = 0;
  String _downloadSpeedText = '0.00';
  double _uploadRate = 0;
  String _uploadSpeedText = '0.00';
  String _isp = "UNKNOWN";
  String _internalIP = 'UNKNOWN';
  String _externalIP = 'UNKNOWN';
  String mac = "UNKNOWN";
  bool isPermissionGiven = false;
  String pingg = "UNKOWN";
  String wifiName = "UNKOWN";
  String _server= "UNKOWN";
  bool showInfo = false;

  @override
  void initState() {
    super.initState();
    reset();
  }

  Future<void> fetchData() async {
    //measureDownloadSpeed();
    startSpeedTest_();
    startSpeedTest();
    fetchIps();
    fetchMac();
    fetchPing();
    getWifiName();
  }

  Future<void> getWifiName() async {
    final NetworkInfo _networkInfo = NetworkInfo();
    try {
      // Retrieve the WiFi name
      String? wifiName = await _networkInfo.getWifiName();
      wifiName = wifiName?.replaceAll('"', '') ?? "MOBILE NETWORK";
      print(wifiName);
      final ipProvider = Provider.of<IpProvider>(context, listen: false);
      ipProvider.updateWifiName(wifiName!.toString());
    } catch (e) {
      print('Error getting WiFi name: $e');
      return null;
    }
  }

  Future<void> fetchPing() async {
    try {
      final ping = Ping('google.com', count: 1);

      String pingResult = 'UNKNOWN';

      // Listen to the ping stream
      ping.stream.listen((PingData event) {
        final String? res = event.response?.time.toString();

        // Convert time string to milliseconds
        if (res != null) {
          final timeInMilliseconds = _convertTimeToMilliseconds(res);
          pingResult = '${timeInMilliseconds.toString()} ms';
        }
      }, onDone: () {
        // Update the IpProvider with the final ping result
        if(pingResult != "null") {
          final ipProvider = Provider.of<IpProvider>(context, listen: false);
          ipProvider.updatePing(pingResult);
          print('Ping Response Time: $pingResult');
        }
      }, onError: (error) {
        print('Error in ping stream: $error');
      });
    } catch (e) {
      print('Error fetching ping: $e');
    }
  }

  // Helper function to convert time string to milliseconds
  int _convertTimeToMilliseconds(String time) {
    final timeParts = time.split(':');
    final milliseconds = timeParts.length > 2
        ? timeParts[2].split('.')
        : timeParts[0].split('.');

    final seconds = int.parse(milliseconds[0]);
    final microseconds =
        milliseconds.length > 1 ? int.parse(milliseconds[1]) : 0;

    return seconds * 1000 + (microseconds / 1000).round();
  }

  Future<void> fetchMac() async {
    try {
      // Request Bluetooth permissions
      bool isGranted = await isBTPermissionGiven();
      if (!isGranted) {
        return; // Exit if permissions are not granted
      }

      // Fetch MAC address
      String mac = await BluetoothInfo.getDeviceAddress();
      print(mac.toString());

      // Update provider with the fetched MAC address
      final ipProvider = Provider.of<IpProvider>(context, listen: false);
      ipProvider.updateMac(mac: mac.toString());
    } catch (e) {
      print('Error fetching MAC address: $e');
    }
  }

  Future<bool> isBTPermissionGiven() async {
    if (Platform.isAndroid) {
      var isAndroidS = (int.tryParse(
                  (await DeviceInfoPlugin().androidInfo).version.release) ??
              0) >=
          12;
      if (isAndroidS) {
        // For Android 12 and above
        var scanStatus = await Permission.bluetoothScan.status;
        var connectStatus = await Permission.bluetoothConnect.status;
        if (scanStatus.isGranted && connectStatus.isGranted) {
          return true;
        } else {
          var response = await [
            Permission.bluetoothScan,
            Permission.bluetoothConnect
          ].request();
          return response[Permission.bluetoothScan]?.isGranted == true &&
              response[Permission.bluetoothConnect]?.isGranted == true;
        }
      } else {
        // For Android versions below 12
        // Bluetooth permission isn't required for versions below Android 12 for getting MAC address
        return true;
      }
    }
    return false;
  }

  Future<void> fetchIps() async {
    try {
      _internalIP = await RGetIp.internalIP ?? 'Unknown';
      _externalIP = await RGetIp.externalIP ?? 'Unknown';

      final ipProvider = Provider.of<IpProvider>(context, listen: false);
      ipProvider.updateExternalIP(externalIP: _externalIP);
      ipProvider.updateInternalIP(internalIP: _internalIP);
    } catch (e) {
      print('Error fetching IPs: $e');
    }
  }

  Future<String> fetchClientISP() async {
    final Uri serverUrl = Uri.parse(
        'https://api.fast.com/netflix/speedtest/v2?https=true&token=YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm&urlCount=5');

    try {
      // Perform HTTP GET request
      var response = await http.get(serverUrl);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Extract ISP information
        final String isp = data['client']?['isp'];
        print('Client ISP: $isp');

        return isp;
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return "UNKNOWN";
      }
    } catch (e) {
      print('Exception during HTTP request: $e');
      return "UNKONOWN";
    }
  }

  // Future<void> measureDownloadSpeed() async {
  //   var streamedResponse;
  //   final stopwatch = Stopwatch()..start();
  //   setState(() {
  //     _testCompleted = false;
  //     _testInProgress = true;
  //   });
  //   int totalBytes = 0;
  //   double lastUpdateTime = 0; // Last time speed was updated
  //   const updateInterval = 0.5; // Update interval in seconds
  //
  //   try {
  //     try {
  //       String url = 'http://v6.speedtest.belwue.net/100M';
  //       final request = http.Request('GET', Uri.parse(url));
  //       streamedResponse = await request.send();
  //     }
  //     catch (e) {
  //       String url = 'http://speedtest.serverius.net/files/10mb.bin';
  //       final request = http.Request('GET', Uri.parse(url));
  //       streamedResponse = await request.send();
  //     }
  //
  //     // Timer for periodic updates
  //     Timer timer = Timer.periodic(Duration(seconds: updateInterval.toInt()), (Timer t) {
  //       final elapsedTime = stopwatch.elapsedMilliseconds / 1000; // seconds
  //       if (elapsedTime - lastUpdateTime >= updateInterval) {
  //         final speed = (totalBytes * 8) / (elapsedTime * 1024 * 1024); // Mbps
  //         setState(() {
  //           _downloadSpeedText = speed.toStringAsFixed(2);
  //         });
  //         print('Download Speed: ${speed.toStringAsFixed(2)} Mbps');
  //         lastUpdateTime = elapsedTime; // Update the last update time
  //       }
  //     });
  //
  //     await streamedResponse.stream.listen(
  //           (List<int> chunk) {
  //         totalBytes += chunk.length;
  //       },
  //       onDone: () {
  //         stopwatch.stop();
  //         timer.cancel(); // Cancel the timer once done
  //         final elapsedTime = stopwatch.elapsedMilliseconds / 1000; // seconds
  //         final speed = (totalBytes * 8) / (elapsedTime * 1024 * 1024); // Mbps
  //         setState(() {
  //           print("_____________________________here__________________________________");
  //
  //           _downloadRate = speed;
  //           _downloadSpeedText = _downloadRate.toStringAsFixed(2);
  //           _testInProgress = false;
  //           _testCompleted = true;
  //         });
  //         try{
  //           final speedTestProvider = Provider.of<SpeedTestProvider>(context, listen: false);
  //           speedTestProvider.updateSpeedTestData(
  //               downloadSpeed: _downloadRate,
  //               uploadSpeed: _uploadRate,
  //               isp: _isp,
  //               server: _server ?? 'UNKNOWN'
  //           );
  //           print('Data updated in provider.');
  //         } catch (e) {
  //           print('Exception during speed test: $e');
  //           setState(() {
  //             _testInProgress = false;
  //           });
  //         }
  //         print('Final Download Speed: ${_downloadSpeedText} Mbps and rate: ${_downloadRate}');
  //         print('Download completed in ${stopwatch.elapsed.inSeconds} seconds');
  //       },
  //       onError: (error) {
  //         print('Error: $error');
  //         timer.cancel(); // Cancel the timer if an error occurs
  //       },
  //       cancelOnError: true,
  //     );
  //
  //
  //   } catch (e) {
  //     print('Exception: $e');
  //   }
  // }

  // Future<void> measureDownloadSpeed() async {
  //   String url = 'http://v6.speedtest.belwue.net/100M';
  //   final stopwatch = Stopwatch()..start();
  //   setState(() {
  //     _testCompleted = false;
  //     _testInProgress = true;
  //   });
  //   int totalBytes = 0;
  //   double lastUpdateTime = 0; // Last time speed was updated
  //   const updateInterval = 0.1; // Update interval in seconds
  //
  //   try {
  //     final request = http.Request('GET', Uri.parse(url));
  //     final streamedResponse = await request.send();
  //
  //     // Timer for periodic updates
  //     Timer timer = Timer.periodic(Duration(milliseconds: (updateInterval * 1000).toInt()), (Timer t) {
  //       final elapsedTime = stopwatch.elapsedMilliseconds / 1000; // seconds
  //       if (elapsedTime - lastUpdateTime >= updateInterval) {
  //         final speed = (totalBytes * 8) / (elapsedTime * 1024 * 1024); // Mbps
  //         setState(() {
  //           _downloadSpeedText = speed.toStringAsFixed(2);
  //         });
  //         print('Download Speed: ${speed.toStringAsFixed(2)} Mbps');
  //         lastUpdateTime = elapsedTime; // Update the last update time
  //       }
  //     });
  //
  //     streamedResponse.stream.listen(
  //           (List<int> chunk) {
  //         totalBytes += chunk.length;
  //       },
  //       onDone: () {
  //         stopwatch.stop();
  //         timer.cancel(); // Cancel the timer once done
  //         final elapsedTime = stopwatch.elapsedMilliseconds / 1000; // seconds
  //         final speed = (totalBytes * 8) / (elapsedTime * 1024 * 1024); // Mbps
  //         setState(() {
  //           _downloadRate = speed;
  //           _downloadSpeedText = _downloadRate.toStringAsFixed(2);
  //           _testInProgress = false;
  //           _testCompleted = true;
  //         });
  //         print('Final Download Speed: ${_downloadSpeedText} Mbps and rate: ${_downloadRate}');
  //         print('Download completed in ${stopwatch.elapsed.inSeconds} seconds');
  //       },
  //       onError: (error) {
  //         print('Error: $error');
  //         timer.cancel(); // Cancel the timer if an error occurs
  //       },
  //       cancelOnError: true,
  //     );
  //   } catch (e) {
  //     print('Exception: $e');
  //     setState(() {
  //       _testInProgress = false;
  //     });
  //   }
  // }

  ////////// new
  Future<void> startSpeedTest() async {
    final speedTestStream = SpeedTestPortStream();
    String? ping;
    String? server;
    String? uploadSpeed;


    try {
      print('Fetching settings...');
      var settings = await speedTestStream.getSettings().first;
      print('Settings fetched: ${settings.servers.length} servers available');

      List<Server> serversTested = [];
      print('Starting server latency test...');
      await for (var srv in speedTestStream.getServersWithLatency(servers: settings.servers)) {
        serversTested.add(srv);
        print('Server tested: ${srv.toString()} with latency ${srv.latency}');
      }

      serversTested.sort((a, b) => a.latency.compareTo(b.latency));
      var bestServers = serversTested.take(1); // Use the best server for testing
      print('Top server selected for download and upload speed tests');


      // // Download Speed Test
      // List<SpeedTestResult> downloadResults = [];
      // print('Starting download speed test...');
      // await for (var result in speedTestStream.testDownloadSpeed(servers: bestServers.toList())) {
      //   switch (result.type) {
      //     case SpeedTestResultType.Try:
      //     // Update download speed in real-time
      //       setState(() {
      //         _downloadSpeedText = result.speed?.toStringAsFixed(2) ?? '0.0';
      //       });
      //       print('Current download speed: ${_downloadSpeedText} Mb/s');
      //       break;
      //     case SpeedTestResultType.ServerDone:
      //       print('Download speed test result from server ${result.server}: ${result.speed?.toStringAsFixed(2) ?? 'N/A'} Mb/s');
      //       downloadResults.add(result);
      //       break;
      //     case SpeedTestResultType.TestDone:
      //       downloadResults.sort((a, b) => a.server.latency.compareTo(b.server.latency));
      //       var bestTest = downloadResults.firstWhere((r) => !r.withException);
      //       setState(() {
      //         _downloadRate = bestTest.speed;
      //       });
      //       downloadSpeed = bestTest.speed?.toStringAsFixed(2) ?? '0.0';
      //       server = bestTest.server.name.toString();
      //       ping = bestTest.server.latency.toString();
      //       print('Best download speed: ${downloadSpeed} Mb/s from server ${server} with ping ${ping}');
      //       break;
      //     default:
      //       break;
      //   }
      // }

      //Upload Speed Test

      print('Starting upload speed test with server ${server}...');
      List<SpeedTestResult> uploadResults = [];
      await for (var result in speedTestStream.testUploadSpeed(servers: [bestServers.first])) {
        switch (result.type) {
          case SpeedTestResultType.ServerDone:
            print('Upload speed test result from server ${result.server}: ${result.speed?.toStringAsFixed(2) ?? 'N/A'} Mb/s');
            uploadResults.add(result);
            break;
          case SpeedTestResultType.TestDone:
            var bestUploadTest = uploadResults.firstWhere((r) => !r.withException);
            server = bestUploadTest.server.name.toString();
            uploadSpeed = bestUploadTest.speed?.toStringAsFixed(2) ?? '0.0';
            print('Best upload speed: ${uploadSpeed} Mb/s');
            break;
          default:
            break;
        }
      }


      // Update state with results
      setState(() {
        _uploadRate = double.tryParse(uploadSpeed ?? '0.0') ?? 0.0;
        _uploadSpeedText = _uploadRate.toStringAsFixed(2);
        _server = server!;
        showInfo = true;
      });

      _isp = await fetchClientISP();
      final speedTestProvider = Provider.of<SpeedTestProvider>(context, listen: false);
      speedTestProvider.updateSpeedTestData(
          downloadSpeed: _downloadRate,
          uploadSpeed: _uploadRate,
          isp: _isp,
          server: _server ?? 'UNKNOWN'
      );

      print('Speed test completed.');
    } catch (e) {
      print('Exception during speed test: $e');
    }
  }


  // Future<void> startSpeedTest() async {
  //   final speedTestStream = SpeedTestPortStream();
  //   String? ping;
  //   String? server;
  //   String? uploadSpeed;
  //
  //   try {
  //     print('Fetching settings...');
  //     var settings = await speedTestStream.getSettings().first;
  //     print('Settings fetched: ${settings.servers.length} servers available');
  //
  //     List<Server> serversTested = [];
  //     print('Starting server latency test...');
  //     await for (var srv in speedTestStream.getServersWithLatency(servers: settings.servers)) {
  //       serversTested.add(srv);
  //       print('Server tested: ${srv.toString()} with latency ${srv.latency}');
  //     }
  //
  //     serversTested.sort((a, b) => a.latency.compareTo(b.latency));
  //     var bestServers = serversTested.take(1); // Use the best server for testing
  //     print('Top server selected for download and upload speed tests');
  //
  //
  //     // // Download Speed Test
  //     // List<SpeedTestResult> downloadResults = [];
  //     // print('Starting download speed test...');
  //     // await for (var result in speedTestStream.testDownloadSpeed(servers: bestServers.toList())) {
  //     //   switch (result.type) {
  //     //     case SpeedTestResultType.Try:
  //     //     // Update download speed in real-time
  //     //       setState(() {
  //     //         _downloadSpeedText = result.speed?.toStringAsFixed(2) ?? '0.0';
  //     //       });
  //     //       print('Current download speed: ${_downloadSpeedText} Mb/s');
  //     //       break;
  //     //     case SpeedTestResultType.ServerDone:
  //     //       print('Download speed test result from server ${result.server}: ${result.speed?.toStringAsFixed(2) ?? 'N/A'} Mb/s');
  //     //       downloadResults.add(result);
  //     //       break;
  //     //     case SpeedTestResultType.TestDone:
  //     //       downloadResults.sort((a, b) => a.server.latency.compareTo(b.server.latency));
  //     //       var bestTest = downloadResults.firstWhere((r) => !r.withException);
  //     //       downloadSpeed = bestTest.speed?.toStringAsFixed(2) ?? '0.0';
  //     //       server = bestTest.server.name.toString();
  //     //       ping = bestTest.server.latency.toString();
  //     //       print('Best download speed: ${downloadSpeed} Mb/s from server ${server} with ping ${ping}');
  //     //       break;
  //     //     default:
  //     //       break;
  //     //   }
  //     // }
  //
  //     // Upload Speed Test
  //
  //       print('Starting upload speed test with server ${server}...');
  //       List<SpeedTestResult> uploadResults = [];
  //       await for (var result in speedTestStream.testUploadSpeed(servers: [bestServers.first])) {
  //         switch (result.type) {
  //           case SpeedTestResultType.ServerDone:
  //             print('Upload speed test result from server ${result.server}: ${result.speed?.toStringAsFixed(2) ?? 'N/A'} Mb/s');
  //             uploadResults.add(result);
  //             break;
  //           case SpeedTestResultType.TestDone:
  //             var bestUploadTest = uploadResults.firstWhere((r) => !r.withException);
  //             server = bestUploadTest.server.name.toString();
  //             uploadSpeed = bestUploadTest.speed?.toStringAsFixed(2) ?? '0.0';
  //             print('Best upload speed: ${uploadSpeed} Mb/s');
  //             break;
  //           default:
  //             break;
  //         }
  //       }
  //
  //
  //     // Update state with results
  //     setState(() {
  //       _uploadRate = double.tryParse(uploadSpeed ?? '0.0') ?? 0.0;
  //       _uploadSpeedText = _uploadRate.toStringAsFixed(2);
  //       _server = server;
  //       showInfo = true;
  //     });
  //
  //     _isp = await fetchClientISP();
  //
  //     print('Speed test completed.');
  //   } catch (e) {
  //     print('Exception during speed test: $e');
  //   }
  // }



  Future<void> startSpeedTest_() async {
    setState(() {
      _testInProgress = true;
      _testCompleted = false; // Reset test completed state
      _isCancelled = false;
    });

    try {
      await _internetSpeedTest.startTesting(
        onStarted: () {
          setState(() {
            _testInProgress = true;
          });
        },
        onCompleted: (TestResult download, TestResult upload) {
          if(_testInProgress == true) {
            setState(() {
              print("**********here************");
              _downloadRate = download.transferRate;
              _downloadSpeedText = download.transferRate.toStringAsFixed(2);
            });
          }
          final speedTestProvider =
              Provider.of<SpeedTestProvider>(context, listen: false);
          speedTestProvider.updateSpeedTestData(
              downloadSpeed: _downloadRate,
              uploadSpeed: _uploadRate,
              isp: _isp,
          server: _server);
        },
        onProgress: (double percent, TestResult data) {
          if(_testInProgress == true) {
            setState(() {
              _downloadSpeedText = data.transferRate.toStringAsFixed(2);
            });
          }
        },
        onError: (String errorMessage, String speedTestError) {
          print('Error: $errorMessage, $speedTestError');
          setState(() {
            _testInProgress = false;
          });
        },
        onDefaultServerSelectionInProgress: () {
          setState(() {
            _isServerSelectionProgress = true;
          });
        },
        onDefaultServerSelectionDone: (Client? client) {
          setState(() {
            _isServerSelectionProgress = false;
            _isp = client!.isp!;
          });
        },
        onDownloadComplete: (TestResult data) {
          setState(() {
            _downloadRate = data.transferRate;
            _downloadSpeedText = data.transferRate.toStringAsFixed(2);
            _testInProgress = false; // Test is completed
            _testCompleted = true; // Mark test as completed

            final speedTestProvider = Provider.of<SpeedTestProvider>(context, listen: false);
            speedTestProvider.updateSpeedTestData(
                downloadSpeed: _downloadRate,
                uploadSpeed: _uploadRate,
                isp: _isp,
                server: _server ?? 'UNKNOWN'
            );
          });
        },
        // onUploadComplete: (TestResult data) {
        //   setState(() {
        //     _uploadRate = data.transferRate;
        //     _uploadSpeedText = data.transferRate.toStringAsFixed(2);
        //   });
        // },
        onCancel: () {
          reset();
        },
      );
    } catch (e) {
      print('Exception during speed test: $e');
      setState(() {
        _testInProgress = false;
      });
    }
  }

  void reset() {
    setState(() {
      _testInProgress = false;
      _testCompleted = false; // Reset test completed state
      _downloadRate = 0;
      _uploadRate = 0;
      _downloadSpeedText = '0.00';
      _uploadSpeedText = '0.00';
    });
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = MediaQuery.of(context).padding.top;
    double screenHeight = MediaQuery.of(context).size.height - appBarHeight;
    double screenWidth = MediaQuery.of(context).size.width;

    // double titleHeight = screenHeight * 0.01;
    // double speedTextSize = screenHeight * 0.05;
    // double iconSize = screenHeight * 0.08;
    double buttonSize = screenHeight * 0.12;
    double padding = screenWidth * 0.03;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 25),
            // Title Image
            FadeAnimation(
              delay: 0.5,
              child: Container(
                padding: EdgeInsets.all(padding),
                child: Text(
                  "YOUR INTERNET SPEED",
                  style: GoogleFonts.lato(
                    fontSize: screenHeight * 0.015,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 130),
            // Download Speed
            FadeAnimation(
              delay: 0.6,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Text(
                  _downloadSpeedText,
                  style: GoogleFonts.lato(
                    fontSize: screenHeight * 0.125,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            FadeAnimation(
              delay: 0.7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/icons/mbps.svg',
                    width: screenWidth * 0.05,
                    height: screenHeight * 0.03,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 65),
            // "MORE INFORMATION" Button or Empty Box
            _testCompleted
                ? FadeAnimation(
                    delay: 0.8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoreInfoScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "MORE INFORMATION",
                        style: GoogleFonts.lato(
                          fontSize: screenHeight * 0.0155,
                          letterSpacing: 2,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height:
                        20), // Show an empty SizedBox if the test is not completed
            SizedBox(height: 60),
            // Start Speed Test Button
            FadeAnimation(
              delay: 1,
              child: GestureDetector(
                onTap: () {
                  if (!_testInProgress) {
                    fetchData();
                  }
                },
                child: _testInProgress
                    ? Container(
                        width: buttonSize,
                        height: buttonSize,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/ZIFI Circle Download Green.svg',
                            color: Colors.green,
                            width: buttonSize * 1.5,
                            height: buttonSize * 1.5,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(buttonSize / 2)),
                          border: Border.all(
                              width: 2.0, color: const Color(0xffffff00)),
                        ),
                        child: Center(
                          child: Text(
                            "GO",
                            style: GoogleFonts.lato(
                              fontSize: screenHeight * 0.037,
                              letterSpacing: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
