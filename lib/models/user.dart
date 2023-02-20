import 'package:cloud_firestore/cloud_firestore.dart';

// model for user object
class AppUser {
  // attributes
  final String uid;
  final String email;
  final String username;
  final String aboutme;
  final List followers;
  final List following;

  // constructor
  const AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.aboutme,
    required this.followers,
    required this.following, 
  });

  // convert user to a json object
  // no parameters
  // returns map (json format)
  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "email": email,
    "aboutme": aboutme,
    "followers": followers,
    "following": following,
  };

  // convert a snap from server to comment object
  // takes in a snap object
  // return user model from snapshot (from firestore database)
  static AppUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return AppUser(
      uid: snapshot["uid"],
      email: snapshot["email"],
      username: snapshot["username"],
      aboutme: snapshot["aboutme"],
      followers: snapshot["followers"],
      following: snapshot["following"],
    );
  }

}