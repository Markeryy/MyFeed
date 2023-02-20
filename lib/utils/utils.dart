import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:overlay_support/overlay_support.dart';

// class for providing utilities

// check for internet connectivity
// no parameters
// no return
void checkInternet() async {
  final result = await Connectivity().checkConnectivity();
  showConnectivitySnackBar(result);
}

// show notification about internet connectivity issues
// takes in connectivity result
// no return
void showConnectivitySnackBar(ConnectivityResult result) {
  // check if user has internet
  final hasInternet = result!=ConnectivityResult.none;
  final color;
  String netNotification = "";
  if (hasInternet) {
    netNotification = "You are connected to the internet";
    color = Colors.green;
  } else {
    netNotification = "You have no internet connection";
    color = Colors.red;
  }
  
  showSimpleNotification(
    Text(netNotification),
    background: color,
    
  );
}

// show snackbar given a text
// takes in snackbar text and context
// no return
void showSnackBar(String snackbarText, BuildContext ctx) {
  ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(snackbarText),
    ),
  );
}