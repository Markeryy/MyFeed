import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// resources
import '../resources/firestore_methods.dart';
// utils
import '../utils/utils.dart';
// screens
import '../screens/user_profile_screen.dart';

// class for comment widget
class CommentWidget extends StatefulWidget {
  // snap of a comment (given an index)
  final snap;
  final String postReference; // pass the post id to reference the post 

  const CommentWidget({
    Key? key,
    required this.snap,
    required this.postReference,
  }) : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

// state of widget
class _CommentWidgetState extends State<CommentWidget> {

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // HEADER
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
                    child: Text(
                      widget.snap["username"],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push( // go to profile
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            uid: widget.snap["uid"],
                            activateAppbar: true,
                          ),
                        )
                      );
                    },
                  ),
                ),

                // DATE
                Text(DateFormat().add_yMMMd().format(widget.snap["datePosted"].toDate())),

                // DIALOG
                // if current user is the author of the comment, show dialog box
                FirebaseAuth.instance.currentUser!.uid == widget.snap["uid"]
                ? IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    showDialog(context: context, builder: (context) {
                      return Dialog(
                        child: InkWell(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              'Delete Comment',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () async {
                            
                            // try to delete the comment
                            try {
                              // delete the comment given the postId and commentId
                              String response = await FirestoreMethods().deleteCommentFromFirestore(widget.postReference, widget.snap["commentId"]);
                              if (response == "Comment deleted successfully") {
                                showSnackBar("Comment deleted successfully", context);
                              } else {
                                showSnackBar(response, context);
                              }
                            } catch(error) {
                              showSnackBar(error.toString(), context);
                            }
                            Navigator.of(context).pop();  // remove dialog after deleting comment

                          },
                        )
                      );
                    });
                  },
                )
                // ELSE, DO NOT SHOW
                : Container()
              ],
            ),
          ),
          
          // COMMENT CONTENT
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(widget.snap["content"])
          ),
          
        ],
      )
        
        
    );
  }
}