import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';    // FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';// FirebaseFirestore

// models
import '../models/user.dart';

// class for providing authentication methods
class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance; // instance of firebase auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // instance of firebase firestore

  // get user details
  // no parameters
  // return an AppUser object
  Future<AppUser> getUserDetails() async {
    User currUser = _auth.currentUser!;   // firebase instance of current user
    // get snap of user given uid
    DocumentSnapshot snap = await _firestore.collection("users").doc(currUser.uid).get();
    return AppUser.fromSnap(snap);  // convert snap to a appuser object
  }

  // create new user
  // no parameters
  // return a string response
  Future<String> registerUser({
    required String email,
    required String password,
    required String username,
    required String aboutme,
  }) async {
    String response = "There is an error adding the user";
    try {
      // check if fields are not empty
      if (email.isNotEmpty || password.isNotEmpty || username.isNotEmpty || aboutme.isNotEmpty) {
        // email and password will be stored in authentication tab
        // register user using _auth method
        UserCredential userCred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        // get the user id from authentication,
        // it will be used as uid in the firestore database
        print("NEW USER (FROM AUTH METHODS): ${userCred.user!.uid}");
        
        // create the user
        AppUser user = AppUser(
          uid: userCred.user!.uid,
          email: email,
          username: username,
          aboutme: aboutme,
          followers: [],
          following: [],
        );

        // add user to firestore database 
        // create collection users if it does not exist (override data if it exists)
        // create document, and set data
        // send the new user in json format
        await _firestore.collection('users').doc(userCred.user!.uid).set(user.toJson());
        response = "Create user success";
      }
    } on FirebaseAuthException catch(firebaseAuthError) {
      if (firebaseAuthError.code == 'invalid-email') {
        response = "Invalid email";
      } else if (firebaseAuthError.code == 'weak-password') {
        response = "Password should be at least 6 characters";
      } else if (firebaseAuthError.code == 'email-already-in-use') {
        response = "Email is already used by another account";
      }
    } catch (error) {
      response = error.toString();
    }
    return response;
  }

  // log in user
  // takes in strings email and password
  // return a string response
  Future<String> loginUser({
    required String email,
    required String password
  }) async {
    String response = "There is an error logging in the user";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        response = "Login user success";
      } else if (email.isEmpty) {
        response = "Please enter email";
      } else if (password.isEmpty) {
        response = "Please enter password";
      }
    } on FirebaseAuthException catch (firebaseAuthError) {
      if (firebaseAuthError.code == "user-not-found") {
        response = "User is not found";
      } else if (firebaseAuthError.code == "wrong-password") {
        response = "Invalid password";
      }
    } catch (error) {
      response = error.toString();
    }
    return response;
  }

  // sign out user
  // no parameters
  // no return
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // change user password
  // takes in string new password and context
  // returns a string response
  Future<String> changePassword(String newPassword, BuildContext context) async {
    String response = "Failed to change password";
    try {
      await _auth.currentUser!.updatePassword(newPassword);
      response = "Password changed successfully, log in again";
    } catch(error) {
      response = error.toString();
    }
    return response;
  }
}