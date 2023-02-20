import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// widgets
import '../widgets/myfeed_appbar_no_search.dart';

// screen to view following
class FollowingScreen extends StatefulWidget {
  final String clickedUserId;

  const FollowingScreen({
    Key? key,
    required this.clickedUserId,
  }) : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

// state of screen
class _FollowingScreenState extends State<FollowingScreen> {
  late List<String> followingUserIds;
  late List<String> followingUsernames;
  late bool noFollowing;
  bool isLoading = false;

  // initialize state (runs only once)
  // no parameters
  // no return
  @override
  void initState() {
    super.initState();
    getUsers();
  }

  // get the user id and usernames and store to list
  // no parameters
  // no return
  void getUsers() async {
    setState(() {
      isLoading = true;
    });

    followingUserIds = [];
    followingUsernames = [];
    noFollowing = false;
    
    try {
      // get the uids of followers of the selected user
      DocumentSnapshot<Map<String, dynamic>> snapFollowers = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clickedUserId).get();
      (snapFollowers.data()!["following"] as List<dynamic>).forEach((element) {
        followingUserIds.add(element);
      });

      // given that uid, get its username
      if (followingUserIds.isNotEmpty) {
      QuerySnapshot<Map<String, dynamic>> snapUsers = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: followingUserIds)
        .get();

        for (var element in snapUsers.docs) {
          followingUsernames.add(element["username"]);
        }
      } else {
        noFollowing = true;
      }
    } catch(error) {
      print(error);
    }

    setState(() {
      isLoading = false;
    });
  } 

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyFeedAppBarNoSearch(),
      backgroundColor: const Color.fromRGBO(27, 22, 38, 1),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : 
      noFollowing
      ? Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: const Text('No followed users yet.'),
      )
      : Column(
        children: [

          // FOLLOWING TITLE
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: const Text('Following'),
          ),

          // LIST OF FOLLOWING
          Expanded(
            child: ListView.builder(
              itemCount: followingUsernames.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(followingUsernames[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}