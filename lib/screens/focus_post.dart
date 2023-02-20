import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myfeed_flutter/widgets/comment_widget.dart';
import 'package:myfeed_flutter/widgets/myfeed_appbar.dart';

// widgets
import '../widgets/post_widget.dart';

// screen to view post (with comments)
class FocusPostScreen extends StatefulWidget {
  final snap;

  const FocusPostScreen({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<FocusPostScreen> createState() => _FocusPostScreenState();
}

// state of screen
class _FocusPostScreenState extends State<FocusPostScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> postsStream;

  // initialize state (runs only once)
  // no parameters
  // no return
  @override
  void initState() {
    super.initState();
    getPostStream();
  }

  // get post stream to listen real time
  // no parameters
  // no return
  void getPostStream() async {
    postsStream = FirebaseFirestore.instance
      .collection('posts')
      .snapshots();

  }

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(27, 22, 38, 1),
      appBar: const MyFeedAppBar(),
      body: Container(
        child: Column(
          children: [
            
            // POST DETAILS
            Expanded(
              child: SingleChildScrollView(child: PostWidget(snap: widget.snap, isAlreadyFocused: true,)),
            ),
            
            // POST COMMENTS
            Expanded(
              flex: 2,
              child: StreamBuilder(
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
                        style: TextStyle(fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  // default
                  return Column(
                    children: [
                      
                      // COMMENT SECTION TITLE
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: const Text(
                          'Comment Section',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),

                      // COMMENTS
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            // pass a snap (map) of every comment from the database
                            return CommentWidget(
                              snap: snapshot.data!.docs[index],
                              postReference: widget.snap["postId"],
                            );
                          }
                        ),
                      ),

                    ],
                  );
                  
                },
              ),
              
            ),
          ],
        ),
      )
      
    );
  }
}