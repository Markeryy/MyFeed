import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfeed_flutter/screens/user_profile_screen.dart';

// widgets
import '../widgets/myfeed_appbar_no_search.dart';

// screen for searching users
class SearchScreen extends StatefulWidget {
  const SearchScreen({ Key? key }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// state of screen
class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchFormKey = GlobalKey<FormState>();  // for validating post text field
  bool _validateSearch = false;
  bool _showUsers = false;

  // dispose to release resources
  // no parameters
  // no return
  @override
  void dispose() {  // release memory
    super.dispose();
    _searchController.dispose();
  }

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(  // still the custom appbar without the search action
      appBar: const MyFeedAppBarNoSearch(),
      backgroundColor: const Color.fromRGBO(27, 22, 38, 1),
      body: Column(
        children: [

          // TEXT FIELD FOR SEARCHING USERS
          Padding(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: _searchFormKey,
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Enter username here',
                  errorText: _validateSearch ? 'Value can\'t be empty' : null
                ),
                validator: (value) {
                  // validates if value in controller/textfield is not empty
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty!';
                  }
                  return null;  // case of no error
                },
                onFieldSubmitted: (_) {
                  if (_searchFormKey.currentState!.validate()) {  
                    setState(() {
                      _showUsers = true;
                    });
                  }
                },
              ),
            ),
          ),
          
          // DISPLAY USERS
          Expanded(
            child: !_showUsers
            ? const Center(child: Text('Try searching for a user!'))
            : FutureBuilder(
              future: FirebaseFirestore.instance  // search users by comparing values through ASCII
                .collection('users')
                .where('username', isGreaterThanOrEqualTo: _searchController.text)
                .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {

                    // remove current user from the choices
                    if (snapshot.data!.docs[index]["uid"] as String != FirebaseAuth.instance.currentUser!.uid) {
                      // if tapped, go to user profile
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => UserProfileScreen(
                              uid: snapshot.data!.docs[index]["uid"],
                            ),),
                          );
                        },
                        child: ListTile(
                          title: Text(snapshot.data!.docs[index]["username"]),
                        ),
                      );
                    } 
                    return Container();

                  },
                );
              },
            ),
          ),



        ],
      ),
    );
  }
}