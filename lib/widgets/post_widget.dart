import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // for date formatting
import 'package:provider/provider.dart';

// provider
import '../providers/user_provider.dart';
// models
import '../models/user.dart';
// utils
import '../utils/utils.dart';
// screens
import '../screens/focus_post.dart';
import '../screens/user_profile_screen.dart';
// widgets
import '../screens/comment_screen.dart';
// resources
import '../resources/firestore_methods.dart';

// class for post widget
class PostWidget extends StatefulWidget {
  // snap is a map from the database
  // access elements by snap["attribute"] from post collection (iterated in posts screen)
  final snap;
  bool isAlreadyFocused;  // to remove certain widgets on post focus
  bool isFromProfile;

  PostWidget({
    Key? key,
    required this.snap,
    this.isAlreadyFocused = false,
    this.isFromProfile = false,
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

// state of widget
class _PostWidgetState extends State<PostWidget> {

  final _editPostController = TextEditingController();
  final _editPostFormKey = GlobalKey<FormState>();  // for validating post text field
  final bool _validateEditPost = false;

  // dispose to release resources
  // no parameters
  // no return
  @override
  void dispose() {  // release memory
    super.dispose();
    _editPostController.dispose();
  }

  // call when delete dialog is tapped
  // takes in postId
  // no return
  void deletePost(String postId) async {
    try {
      String response = await FirestoreMethods().deletePostFromFirestore(postId);
      if (response == "Post deleted successfully") {
        showSnackBar("Post deleted successfully", context);
      } else {
        showSnackBar(response, context);
      }
    } catch(error) {
      showSnackBar(error.toString(), context);
    }
  }

  // call when edit dialog is tapped
  // no parameters
  // no return
  void showEditPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EDIT POST TEXT FIELD
            Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _editPostFormKey,
                child: TextFormField(
                  controller: _editPostController,
                  decoration: InputDecoration(
                    hintText: 'Enter new post here',
                    errorText: _validateEditPost ? 'Value can\'t be empty' : null
                  ),
                  validator: (value) {
                    // validates if value in controller/textfield is not empty
                    if (value == null || value.isEmpty) {
                      return 'Post cannot be empty!';
                    }
                    return null;  // case of no error
                  },
                  onFieldSubmitted: (_) {
                    if (_editPostFormKey.currentState!.validate()) {
                      editPost(widget.snap["postId"], _editPostController.text);
                      _editPostController.clear();
                      Navigator.of(context).pop();  // to remove modal sheet
                      Navigator.of(context).pop();  // to remove dialog box
                    }
                  },
                ),
              ),
            ),

            // padding to increase height when keyboard opens
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)
            ),
          ],
        );
      }
    );
  }

  // call when user submits text field in modal sheet
  // takes in strings postId and the new post
  // no returns
  void editPost(String postId, String editedPost) async {
    try {
      String response = await FirestoreMethods().editPostFromFirestore(postId, editedPost);
      if (response == "Post updated successfully") {
        showSnackBar("Post updated successfully", context);
      } else {
        showSnackBar(response, context);
      }
    } catch(error) {
      showSnackBar(error.toString(), context);
    }
  }

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    AppUser? _user = Provider.of<UserProvider>(context).getUser;

    // MAIN BODY
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.withOpacity(0.8), Colors.red.withOpacity(0.8)],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),

      child: _user == null   // check if user is null to avoid errors
        ? const Center(child: CircularProgressIndicator(),)
        : Column(
        children: [

          // POST HEADER
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.3),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            padding: FirebaseAuth.instance.currentUser!.uid == widget.snap["uid"]
            ? const EdgeInsets.only(left: 10)
            : const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              children: [

                // USERNAME
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (widget.isFromProfile) {   // if this post is from profile, go focus
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => FocusPostScreen(
                            snap: widget.snap,
                          ),),
                        );
                      } else {
                        Navigator.of(context).push( // else go to profile
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(
                              uid: widget.snap["uid"],
                              activateAppbar: true,
                            ),
                          )
                        );
                      }
                    },
                    child: Text(
                      widget.snap["username"],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )
                ),

                // DATE POSTED
                Text(DateFormat().add_yMMMd().format(widget.snap["datePosted"].toDate())), 
  
                // DIALOG BOX
                // if current user is the author of the post, show dialog box
                FirebaseAuth.instance.currentUser!.uid == widget.snap["uid"]
                ? IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    showDialog(context: context, builder: (context) {
                      return Dialog(
  
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            'Delete',
                            'Edit',
                          ].map((children) => InkWell(
                            onTap: () {
  
                              if (children == "Delete") {
                                deletePost(widget.snap["postId"]);
                                Navigator.pop(context); // remove dialog box
                              } else if (children == "Edit") {
                                showEditPostSheet();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                children,
                                textAlign: TextAlign.center,
                              )
                            ),
                          )).toList(),
                        ),
  
                      );
                    });
                  },
                )
                // ELSE, DO NOT SHOW
                : Container()
              ]
            ),
          ),
  
          // POST CONTENT
          Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.snap["content"],
            ),
          ),
  
          // ROW OF ICONS
          widget.isAlreadyFocused // check if widget is already focused
          ? Container() // do not show row of icons if already focused
          : Row(
            children: [
              IconButton( // LIKE
                // check if user already likes the post
                icon: widget.snap["likes"].contains(_user.uid)
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border,),
                onPressed: () async {
                  // call like method from firestore_methods
                  await FirestoreMethods().likePost(
                    postId: widget.snap["postId"],
                    currentUserId: _user.uid,
                    userLikes: widget.snap["likes"],
                  );
                },   
              ),
              IconButton( // COMMENT
                icon: const Icon(Icons.comment,),
                onPressed: () {
                  // go to comment screen
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CommentScreen(
                      snap: widget.snap  // send the snap
                    ),)
                  );
                },   
              ),
              IconButton( // FOCUS POST (VIEW)
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FocusPostScreen(
                      snap: widget.snap,
                    ),),
                  );
                },
              )
            ]
          ),
  
          // NUMBER OF LIKES
          Container(
            padding: const EdgeInsets.all(5),
            color: const Color.fromRGBO(42, 38, 64, 0.4),
            width: double.infinity,
            child: Text(
              widget.snap["likes"].length == 1
              ? '${widget.snap["likes"].length} like'
              : '${widget.snap["likes"].length} likes',
              textAlign: TextAlign.left,
            ),
          )
  
        ],
      ),
    );
  }
}