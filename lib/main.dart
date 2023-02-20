import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myfeed_flutter/utils/utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

// providers
import './providers/user_provider.dart';
// screens
import './screens/home_screen.dart';
import './screens/login_screen.dart';

// main function
// no parameters
// no return
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // for firebase
  runApp(const MyApp());
}

// class for main widget (root)
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

// state of main app
class _MyAppState extends State<MyApp> {
  late StreamSubscription internetCheckerSubscription;  // checks internet connectivity

  // initialize state (runs only once)
  // no parameters
  // no return
  @override
  void initState() {
    super.initState();
    internetCheckerSubscription = Connectivity().onConnectivityChanged.listen(showConnectivitySnackBar);
  }

  // dispose to release resources
  // no parameters
  // no return
  @override
  void dispose() {
    internetCheckerSubscription.cancel();
    super.dispose();
  }

  // widget build method
  // takes in context
  // returns the main widget
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(    // for notification widget (internet notification)
      child: MultiProvider(   // to be able to use the UserProvider
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider(),), // _ is used for arguments that are not in use
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),  // run when user sign in or sign out
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.active) {  // connection with stream is active (there is a logged in user)
                if (snapshot.hasData) {
                  return const HomeScreen();
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'),);
                }
              }
              if (snapshot.connectionState == ConnectionState.waiting) {  // loading
                return const Center(child: CircularProgressIndicator(),);
              }
              return const LoginScreen(); // no authenticated user
            },
          ),
        ),
      ),
    );
  }
}

