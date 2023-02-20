import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:provider/provider.dart';

// widgets
import '../widgets/post_widget.dart';
// models
import '../models/user.dart';
// provider
import '../providers/user_provider.dart';

// screen to view posts (public posts)
class PostsScreen extends StatefulWidget {
  const PostsScreen({ Key? key }) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

// state of screen
class _PostsScreenState extends State<PostsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> postsStream;
  late final queryPost;

  // initialize state (runs only once)
  // no parameters
  // no return
  @override
  void initState() {  // put the stream outside to initialize only once
    super.initState();
    postsStream = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('datePosted', descending: true)  // sort by date (latest post: top)
      .snapshots();
    queryPost = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('datePosted', descending: true);
  } 

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    AppUser? _user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(27, 22, 38, 1),
      body: StreamBuilder(  // listen to updates from the firestore database
        stream: postsStream,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {  // if loading
            return const Center(child: CircularProgressIndicator(),);
          }

          // FIRESTORE LISTVIEW (WITH PAGINATION)
          return FirestoreListView(
            query: queryPost,
            pageSize: 8, // load 8 posts at a time
            itemBuilder: (context, snapshot) {
              return PostWidget(
                snap: snapshot.data(),
                
              );
            }
          );

          // DEFAULT LISTVIEW OPTION
          // return ListView.builder(  // list of posts
          //   itemCount: snapshot.data!.docs.length,  // number of data in the database (docs = list of document id)
          //   itemBuilder: (context, index) {
          //     return PostWidget(
          //       snap: snapshot.data!.docs[index].data(),  // send snapshot per index
          //     );
          //   }
          // );
        },
      ),
    );
  }
}