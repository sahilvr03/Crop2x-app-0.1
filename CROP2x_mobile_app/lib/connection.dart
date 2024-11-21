import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cropx/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class Connection extends StatefulWidget {
  const Connection({Key? key}) : super(key: key);
  @override
  State<Connection> createState() => _ConnectivityState();
}

class _ConnectivityState extends State<Connection> {
  late StreamSubscription subscription;
  late StreamSubscription internetSubscription;
  bool hasInternet = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  @override
  void dispose() {
    subscription.cancel();
    internetSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _showConnectivitySnackbar(result);

    subscription = Connectivity()
        .onConnectivityChanged
        .listen(_showConnectivitySnackbar);

    internetSubscription = InternetConnectionChecker()
        .onStatusChange
        .listen((status) async {
      final hasInternet = status == InternetConnectionStatus.connected;
      setState(() {
        this.hasInternet = hasInternet;
      });

      if (hasInternet) {
        navigateToScreen(splashscreen());
      } else {
        navigateToScreen(splashscreen());
      }
    });
  }

  void _showConnectivitySnackbar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    final message = hasInternet
        ? result == ConnectivityResult.mobile
            ? 'You are connected to Mobile network'
            : 'You are connected to WiFi network'
        : 'You have no internet connection';
    final color = hasInternet ? Color.fromARGB(255, 0x00, 0x60, 0x4F) : Colors.red;
    _showSnackbar(context, message, color);
  }

  void navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => screen),
    );
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    // Define your widget tree here
    return Scaffold(
    );
  }
}
