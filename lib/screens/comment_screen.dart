import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myfeed_flutter/resources/firestore_methods.dart';
import 'package:provider/provider.dart';

// models
import '../models/user.dart';
// widgets
import '../widgets/myfeed_appbar.dart';
import '../widgets/comment_widget.dart';
// utils
import '../utils/utils.dart';
// provider
import '../providers/user_provider.dart';

// screen to view comments
class CommentScreen extends StatefulWidget {
  // snap is the map of the chosen post collection to comment on
  final snap;

  const CommentScreen({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

// state of screen
class _CommentScreenState extends State<CommentScreen> {
  final _commentController = TextEditingController();
  final _commentFormKey = GlobalKey<FormState>();  // for comment form validation
  final bool _validateComment = false;

  // dispose to release resources
  // no parameters
  // no return
  @override
  void dispose() {  // free memory
    super.dispose();
    _commentController.dispose();
  }

  // shows a modal bottom sheet for comment
  // takes in user object
  // no return
  void showCommentSheet(AppUser? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          // COMMENT TEXT FIELD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _commentFormKey,
              child: TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Enter comment here',
                  errorText: _validateComment ? 'Value can\'t be empty' : null
                ),
                validator: (value) {
                  // validates if value in controller/textfield is not empty
                  if (value == null || value.isEmpty) {
                    return 'Comment cannot be empty!';
                  }
                  return null;  // case of no error
                },
              ),
            ),
          ),

          // COMMENT BUTTON
          InkWell(
            child: Container(
              margin: const EdgeInsets.all(13),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              width: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.purple],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Comment',
                style: TextStyle(
                  fontSize: 14,
                ),
              )
            ),
            onTap: () async {
              // if comment is validated,
              try {
                if (_commentFormKey.currentState!.validate()) {
                  // send comment details
                  String response = await FirestoreMethods().sendCommentToFirestore(
                    widget.snap["postId"],    // to navigate to the post in database
                    _commentController.text,  // other parameters will be used as data for the comment
                    user!.uid,
                    user.username,
                  );
                  if (response == "Comment uploaded successfully") {
                    showSnackBar("Comment uploaded successfully", context);  // show snackbar for result
                  } else {
                    showSnackBar(response, context);
                  }
                  _commentController.clear();   // clear controller
                  Navigator.of(context).pop();  // remove modal sheet after commenting
                }
              } catch(error) {
                showSnackBar(error.toString(), context);
              }
              
            },
          ),

          // padding to increase height when keyboard opens
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)
          ),
        ],
      ),
    );
  }

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    AppUser? _user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: const MyFeedAppBar(),
      backgroundColor: const Color.fromRGBO(27, 22, 38, 1),
      // LISTVIEW OF COMMENTS (listens to the stream)
      body: StreamBuilder(
        // reference comment snapshots as the stream
        // given the postId of the chosen post (widget.snap["postId"])
        stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap["postId"])
          .collection('comments')
          .orderBy('datePosted')  // sort by date (latest comment: bottom)
          .snapshots(),
        // explicitly cast snapshot to get .docs.length method in itemCount
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          // snapshot is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          // if there are no comments yet
          if (snapshot.data!.docs.isEmpty) {
            return Container(
              padding: const EdgeInsets.only(top: 25),
              width: double.infinity,
              child: const Text(
                'There are no comments yet. Add one?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          // default
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // pass a snap (map) of every comment from the database
              return CommentWidget(
                snap: snapshot.data!.docs[index],
                postReference: widget.snap["postId"],
              );
            }
          );
        },
      ),

      // ADD COMMENT BUTTON
      bottomNavigationBar: InkWell(
        onTap: () {
          showCommentSheet(_user);
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.purple],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Add Comment',
            textAlign: TextAlign.center,
            style: TextStyle(

              fontSize: 15,
            ),
          )

        ),
      ),
    );
  }
}