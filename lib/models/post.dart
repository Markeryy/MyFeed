import 'package:cloud_firestore/cloud_firestore.dart';

// model for post object
class Post {
  // attributes
  final String postId;
  final String content;   // content of post
  final String uid;       // uid of user who posted
  final String username;       // username of user who posted
  final DateTime datePosted;
  final likes;  // list of uids who liked the post
  bool isForFriends;

  // constructor
  Post({
    required this.postId,
    required this.content,
    required this.uid,
    required this.username,
    required this.datePosted,
    required this.likes, 
    this.isForFriends = false
  });

  // convert post to a json object
  // no parameters
  // returns map (json format)
  Map<String, dynamic> toJson() => {
    "postId": postId,
    "content": content,
    "uid": uid,
    "username": username,
    "datePosted": datePosted,
    "likes": likes,
    "isForFriends": isForFriends,
  };

  // convert a snap from server to comment object
  // takes in a snap object
  // return post model from snapshot (from firestore database)
  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      postId: snapshot["postId"],
      content: snapshot["content"],
      uid: snapshot["uid"],
      username: snapshot["username"],
      datePosted: snapshot["datePosted"],
      likes: snapshot["likes"],
      isForFriends: snapshot["isForFriends"],
    );
  }

}