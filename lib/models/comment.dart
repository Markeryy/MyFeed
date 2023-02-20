import 'package:cloud_firestore/cloud_firestore.dart';

// model for comment object
class Comment {
  // attributes
  final String commentId;
  final String content;   // content of comment
  final String uid;       // uid of user who posted
  final String username;       // username of user who posted
  final DateTime datePosted;

  // constructor
  const Comment({
    required this.commentId,
    required this.content,
    required this.uid,
    required this.username,
    required this.datePosted,
  });

  // convert comment to a json object
  // no parameters
  // returns map (json format)
  Map<String, dynamic> toJson() => {
    "commentId": commentId,
    "content": content,
    "uid": uid,
    "username": username,
    "datePosted": datePosted,
  };

  // convert a snap from server to comment object
  // takes in a snap object
  // return comment model from snapshot (from firestore database)
  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Comment(
      commentId: snapshot["commentId"],
      content: snapshot["content"],
      uid: snapshot["uid"],
      username: snapshot["username"],
      datePosted: snapshot["datePosted"],
    );
  }

}