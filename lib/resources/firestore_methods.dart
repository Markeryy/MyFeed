import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

// models
import '../models/post.dart';
import '../models/comment.dart';

// class for providing server methods
class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload user post
  // takes in strings post content, user uid, and username
  // returns a string response
  Future<String> sendPostToFirestore(String content, String uid, String username) async {
    String response = "Error uploading post";
    try {
      //String postUrl = await StorageMethods().uploadPostToStorage('posts');
      //StorageMethods().uploadPostToStorage('posts');
      String postId = const Uuid().v1();   // generate a unique string id (from uuid package)
      Post post = Post(   // create a new post object
        content: content,
        uid: uid,
        username: username,
        postId: postId,
        datePosted: DateTime.now(),
        likes: [],
      );

      // go to collection posts, create postId, send the post in json format
      await _firestore.collection('posts').doc(postId).set(post.toJson());
      response = "Post uploaded successfully";
    } catch (error) {
      response = error.toString();
    }
    return response;
  }

  // delete post
  // takes in a string postId to delete
  // returns a string response
  Future<String> deletePostFromFirestore(String postId) async {
    String response = "Error deleting post";
    try {
      // delete post from database given its postId
      await _firestore.collection('posts').doc(postId).delete();
      response = "Post deleted successfully";
    } catch(error) {
      response = error.toString();
    }

    return response;
  }

  // like a user post
  // takes in strings postId, current user id, and list of users who liked the post
  // no return
  Future<void> likePost({
    required String postId,
    required String currentUserId,
    required List userLikes,
  }) async {
    try {
      // if post is already liked by current user
      if (userLikes.contains(currentUserId)) {
        // update the database
        // use update since only one value will be changed
        // use set if all values should be updated
        await _firestore.collection('posts').doc(postId).update({ 
          // take existing likes from database and remove currentUserId
          'likes': FieldValue.arrayRemove([currentUserId]), 
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({ 
          // take existing likes from database and add currentUserId
          'likes': FieldValue.arrayUnion([currentUserId]), // add currentUserId to likes
        });
      }
    } catch (error) {
      print(error.toString());
    }
  }

  // add comment to a post
  // takes in strings postId, comment, id of user who commented, username of user
  // returns a string response
  Future<String> sendCommentToFirestore(
    String postId,      // take postId to help in database navigation
    String commentText,
    String userId,
    String username
  ) async {
    String response = "Error uploading comment";
    try {
      // create a unique id
      String commentId = const Uuid().v1();

      // create a comment object
      Comment comment = Comment(   // create a new post object
        commentId: commentId,
        content: commentText,
        uid: userId,
        username: username,
        datePosted: DateTime.now(),
      );

      // go to the subcollection comments of a postId in the database
      // pass the comment in json format (map)
      await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set(comment.toJson());
      response = "Comment uploaded successfully";

    } catch(error) {
      response = error.toString();
    }
    return response;
  }

  // delete comment
  // takes in strings postId and commentId
  // returns a string response
  Future<String> deleteCommentFromFirestore(String postId, String commentId) async {
    String response = "Error deleting comment";
    try {
      // delete post from database given its postId
      await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).delete();
      response = "Comment deleted successfully";
    } catch(error) {
      response = error.toString();
    }

    return response;
  }

  // follow a user
  // takes in strings current user id and the id of user to follow
  // returns a string response
  Future<String> followUser(String currentUid, String uidToFollow) async {
    String response = "Error following user";
    try {
      // get the list of following of current user
      DocumentSnapshot snap = await _firestore.collection('users').doc(currentUid).get();
      List following = (snap.data()! as dynamic)["following"];

      // if already following, unfollow (remove from following list in the database)
      if (following.contains(uidToFollow)) {
        // remove the selected user from current user's following
        await _firestore.collection('users').doc(currentUid).update(
          {
            'following': FieldValue.arrayRemove([uidToFollow])
          }
        );
        // remove following of current user from that user to unfollow
        await _firestore.collection('users').doc(uidToFollow).update(
          {
            'followers': FieldValue.arrayRemove([currentUid])
          }
        );
        response = "Unfollowed user successfully";
      } else {
        // add the selected user to current user's following
        await _firestore.collection('users').doc(currentUid).update(
          {
            'following': FieldValue.arrayUnion([uidToFollow])
          }
        );
        // add current user to the selected user's followers
        await _firestore.collection('users').doc(uidToFollow).update(
          {
            'followers': FieldValue.arrayUnion([currentUid])
          }
        );
        response = "Followed user successfully";
      }
    } catch (error) {
      response = error.toString();
    }
    return response;
  }

  // edit current user profile
  // takes in the new profile description
  // returns a string response
  Future<String> editProfile(String newBio) async {
    String response = "Failed to update profile";
    try {
      await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(
        {
          'aboutme': newBio,
        }
      );
      response = "Updated profile successfully";
    } catch(error) {
      response = error.toString();
    }
    return response;
  }

  // edit post
  // takes in strings post id, and new post (edited)
  // returns a string response
  Future<String> editPostFromFirestore(String postId, String editedPost) async {
    String response = "Failed to update post";
    try {
      await _firestore.collection('posts').doc(postId).update(
        {
          'content': editedPost,
        }
      );
      response = "Post updated successfully";
    } catch(error) {
      response = error.toString();
    }
    return response;
  }
}