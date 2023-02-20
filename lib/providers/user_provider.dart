import 'package:flutter/material.dart';
import 'package:myfeed_flutter/resources/auth_methods.dart';

// models
import '../models/user.dart';

// user provider class
class UserProvider with ChangeNotifier {
  AppUser? _user; // private
  final AuthMethods _authMethods = AuthMethods(); // initialize auth methods
  
  // getter
  AppUser? get getUser => _user; // change to AppUser? if error // OLD: AppUserAppUser get getUser => _user!;

  // get user details and update the _user attribute
  // no parameters
  // no return
  Future<void> refreshUser() async {
    AppUser user = await _authMethods.getUserDetails(); 
    _user = user;
    notifyListeners();  // send a signal to listeners
  }
}