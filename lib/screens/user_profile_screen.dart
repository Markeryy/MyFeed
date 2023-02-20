import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/firestore.dart';

// resources
import '../resources/firestore_methods.dart';
import '../resources/auth_methods.dart';
// screens
import './login_screen.dart';
import './followers_screen.dart';
import './following_screen.dart';
// widgets
import '../widgets/profile_button.dart';
import '../widgets/myfeed_appbar.dart';
import '../widgets/post_widget.dart';
// utils
import '../utils/utils.dart';

// screen for viewing user profile
class UserProfileScreen extends StatefulWidget {
  final String uid;   // to determine user
  bool activateAppbar;
  UserProfileScreen({
    Key? key,
    required this.uid,
    this.activateAppbar = false,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

// state of screen
class _UserProfileScreenState extends State<UserProfileScreen> {
  var profileData = {}; // initialize data
  var numberOfPosts = 0;
  var followersLength = 0;
  var followingLength = 0;
  var aboutMe = "";
  bool isFollowing = false;
  bool isLoading = false;

  final _newBioController = TextEditingController();
  final _newBioFormKey = GlobalKey<FormState>();  // for validating bio text field
  final bool _validateBio = false;

  late Stream<QuerySnapshot<Map<String, dynamic>>> userPostsStream;
  late final queryUserPost;

  // for changing password
  final _newPassController = TextEditingController();
  final _newPassFormKey = GlobalKey<FormState>();
  final bool _validateNewPass = false;
  
  // initialize state (runs only once)
  // no parameters
  // no return
  @override
  void initState() {
    super.initState();
    getDataFromFirestore(); // initialize data for display
    userPostsStream = FirebaseFirestore.instance  // initialize stram
      .collection('posts')
      .where('uid', isEqualTo: widget.uid)
      .orderBy('datePosted', descending: true)  // sort by date (latest post: top)
      .snapshots();
    queryUserPost = FirebaseFirestore.instance  // initialize stram
      .collection('posts')
      .where('uid', isEqualTo: widget.uid)
      .orderBy('datePosted', descending: true);  // sort by date (latest post: top)
  }

  // dispose to release resources
  // no parameters
  // no return
  @override
  void dispose() {
    super.dispose();
    _newBioController.dispose();
    _newPassController.dispose();
  }

  // get user data from firestore
  // no parameters
  // no return
  void getDataFromFirestore() async {
    if (mounted) {  // do not call if widget is not part of widget tree anymore
      setState(() { // to prevent setState() called after dispose() error
        isLoading = true;
      });
    }
    
    try {
      // get document snapshot of the given uid
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      profileData = userSnap.data()!;  // set get the data (map) from snapshot
      
      followersLength = userSnap.data()!["followers"].length; // initialize length
      followingLength = userSnap.data()!["following"].length; // initialize length
      aboutMe = userSnap.data()!["aboutme"];  // get bio from database
      // boolean if current user is following this profile
      isFollowing = userSnap.data()!["followers"].contains(FirebaseAuth.instance.currentUser!.uid);

      // get number of posts (for item count)
      var userNoOfPostsDatabase = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
      numberOfPosts = userNoOfPostsDatabase.docs.length;

      //setState(() {});  // reflect changes
    } catch (error) {
      showSnackBar(error.toString(), context);
    }

    if (mounted) {   // do not call if widget is not part of widget tree anymore
      setState(() { // to prevent setState() called after dispose() error
        isLoading = false;
      });
    }
  }

  // call when follow/unfollow is clicked
  // no parameters
  // no return
  void followUser() async {
    
    try {
      // get the number of following of the current user
      DocumentSnapshot<Map<String, dynamic>> currentUserSnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
      // check if the current following is greater than or equal to 8
      // users can only follow up to 8 other users
      var currentFollowers = (currentUserSnap.data()!["following"] as List<dynamic>).length;
      if (currentFollowers >= 8 && !isFollowing) {
        showSnackBar("You can only follow up to 8 users.", context);
        return;
      }
    } catch(error) {
      print(error.toString());
    }
    
    try {
      String response = await FirestoreMethods().followUser(
        FirebaseAuth.instance.currentUser!.uid, // current user
        widget.uid                              // current profile
      );

      if (response == "Unfollowed user successfully") {
        showSnackBar("Unfollowed user successfully", context);  // show snackbar for result
        setState(() {
          isFollowing = false;
          followersLength--;
        });
      } else if (response == "Followed user successfully") {
        showSnackBar("Followed user successfully", context);
        setState(() {
          isFollowing = true;
          followersLength++;
        });
      } else {
        showSnackBar(response, context);
      }
    } catch (error) {
      showSnackBar(error.toString(), context);
    }
    
  }

  // call when edit profile is clicked
  // no parameters
  // no return
  void showProfileOptions() {
    showDialog(context: context, builder: (context) {
      return Dialog(
        child: ListView(
          shrinkWrap: true,
          children: [
            'Edit Bio',
            'Change Password',
          ].map((children) => InkWell(
            onTap: () {

              if (children == "Edit Bio") {
                showEditProfileSheet();
              } else if (children == "Change Password") {
                showChangePassword();
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
  }

  // call when user wants to edit profile
  // no parameters
  // no return
  void showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // NEW BIO TEXT FIELD
          Form(
            key: _newBioFormKey,
            child: TextFormField(
              controller: _newBioController,
              decoration: InputDecoration(
                hintText: 'Enter new bio',
                errorText: _validateBio ? 'Value can\'t be empty' : null
              ),
              validator: (value) {
                // validates if value in controller/textfield is not empty
                if (value == null || value.isEmpty) {
                  return 'New bio cannot be empty!';
                }
                return null;  // case of no error
              },
              onFieldSubmitted: (newBio) async {
                // change aboutMe locally
                String response = "Fail updating profile";
                try {
                  response = await FirestoreMethods().editProfile(newBio);
                  if (response == "Updated profile successfully") {
                    setState(() {
                      aboutMe = newBio;
                    });
                  }
                  showSnackBar("Updated profile successfully", context);
                } catch(error) {
                  showSnackBar(error.toString(), context);
                }
                _newBioController.clear();
                Navigator.of(context).pop();  // remove modal sheet
                Navigator.of(context).pop();  // remove dialog box
              },
            ),
          ),

          // padding to increase height when keyboard opens
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)
          ),
        ],
      ),
    ));
  }

  // call when user wants to change password
  // no parameters
  // no return
  void showChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // NEW PASSWORD TEXT FIELD
          Container(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _newPassFormKey,
              child: TextFormField(
                controller: _newPassController,
                decoration: InputDecoration(
                  hintText: 'Enter new password here',
                  errorText: _validateNewPass ? 'Value can\'t be empty' : null
                ),
                validator: (value) {
                  // validates if value in controller/textfield is not empty
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty!';
                  }
                  if (value.length<6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;  // case of no error
                },
              ),
            ),
          ),

          // CONFIRM BUTTON
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () async {
              if (_newPassFormKey.currentState!.validate()) {
                try {
                  String response = await AuthMethods().changePassword(_newPassController.text, context);
                  Navigator.pop(context); // close modal sheet
                  Navigator.pop(context); // close dialog box
                  AuthMethods().signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen())
                  );
                  showSnackBar(response, context);
                } catch(error) {
                  showSnackBar(error.toString(), context);
                }
              }
            },
          ),

          // padding to increase height when keyboard opens
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)
          ),
        ],
      )
    );
  }

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    return isLoading
    ? const Center(child: CircularProgressIndicator(),)
    : Scaffold(
      backgroundColor: const Color.fromRGBO(27, 22, 38, 1),
      // add custom app bar if not our own profile
      // our own profile comes with a appbar (from pageviewer)
      appBar: widget.uid == FirebaseAuth.instance.currentUser!.uid && !widget.activateAppbar
      ? null  // avoid duplicate appbar because of pageview behavior
      : const MyFeedAppBar(),
      
      body: Column(
        children: [

          // PROFILE HEADER
          Container(
            color: Colors.blue.withOpacity(0.2),
            width: double.infinity,
            child: Column(
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.brown],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
                  ),
                  child: Column(
                    children: [
                      // USERNAME
                      Text(
                        profileData["username"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10,),

                      // DESCRIPTION
                      Text(
                        aboutMe,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // ROW OF DETAILS
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      
                      // FOLLOWERS
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            'Followers: $followersLength',
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => FollowerScreen(clickedUserId: widget.uid),)
                          );
                        },
                      ),

                      // FOLLOWING
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Following: $followingLength',
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => FollowingScreen(clickedUserId: widget.uid),)
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // IF THIS IS OUR OWN PROFILE
                FirebaseAuth.instance.currentUser!.uid == widget.uid ?
                // PROFILE BUTTON (Edit Profile)
                ProfileButton(
                  buttonText: 'Edit Profile',
                  pressFunction: () {
                    showProfileOptions();
                  },
                )
                : isFollowing ? // if not our profile, check if we are following that user
                // PROFILE BUTTON (Unfollow)
                ProfileButton(
                  buttonText: 'Unfollow',
                  pressFunction: followUser,
                )
                // PROFILE BUTTON (Follow)
                : ProfileButton(
                  buttonText: 'Follow',
                  pressFunction: followUser,
                ),

                const SizedBox(height: 10,),

                // IF THIS IS OUR OWN PROFILE
                FirebaseAuth.instance.currentUser!.uid == widget.uid 
                ? ProfileButton( // PROFILE BUTTON (LOG OUT)
                  buttonText: 'Log Out',
                  pressFunction: () async {
                    await AuthMethods().signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen()
                      ),
                    );
                  },
                )
                : Container(),

                const Padding(padding: EdgeInsets.only(bottom: 20))

              ],
            ),
          ),

          // POSTS OF THIS USER
          Expanded(
            child: StreamBuilder(  // listen to updates from the firestore database
              stream: userPostsStream,
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {  // if loading
                  return const Center(child: CircularProgressIndicator(),);
                }
                if (!snapshot.hasData) {  // if loading
                  print(snapshot.error);
                  return const Center(child: Text('No posts yet!'),);
                } else {

                  // FIRESTORE LISTVIEW (WITH PAGINATION)
                  return FirestoreListView(
                    query: queryUserPost,
                    pageSize: 8, // load 8 posts at a time
                    itemBuilder: (context, snapshot) {
                      return PostWidget(
                        snap: snapshot.data(),
                      );
                    }
                  );

                  // DEFAULT LISTVIEW OPTION
                  // return ListView.builder(  // list of posts (public)
                  //   itemCount: snapshot.data!.docs.length,  // number of data in the database (docs = list of document id)
                  //   itemBuilder: (context, index) {
                  //     return PostWidget(
                  //       snap: snapshot.data!.docs[index].data(),  // send snapshot per index
                  //     );
                  //   }
                  // );
                }
                
              },
            ),
          )

        ],
      ),
    );
  }
}