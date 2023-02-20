import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// widgets
import '../widgets/myfeed_appbar_no_search.dart';

// screen to view followers
class FollowerScreen extends StatefulWidget {
  final String clickedUserId;

  const FollowerScreen({
    Key? key,
    required this.clickedUserId,
  }) : super(key: key);

  @override
  State<FollowerScreen> createState() => _FollowerScreenState();
}

// state of screen
class _FollowerScreenState extends State<FollowerScreen> {
  late List<String> followerUserIds;
  late List<String> followerUsernames;
  late bool noFollowers;
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

    followerUserIds = [];
    followerUsernames = [];
    noFollowers = false;
    
    try {
      // get the uids of followers of the selected user
      DocumentSnapshot<Map<String, dynamic>> snapFollowers = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clickedUserId).get();
      (snapFollowers.data()!["followers"] as List<dynamic>).forEach((element) {
        followerUserIds.add(element);
      });

      // given that uid, get its username
      if (followerUserIds.isNotEmpty) {
      QuerySnapshot<Map<String, dynamic>> snapUsers = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: followerUserIds)
        .get();

        for (var element in snapUsers.docs) {
          followerUsernames.add(element["username"]);
        }
      } else {
        noFollowers = true;
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
      noFollowers 
      ? Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: const Text('No followers yet.'),
      )
      : Column(
        children: [

          // FOLLOWERS TITLE
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: const Text('Followers'),
          ),

          // LIST OF FOLLOWERS
          Expanded(
            child: ListView.builder(
              itemCount: followerUsernames.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(followerUsernames[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}