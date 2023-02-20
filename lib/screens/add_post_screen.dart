import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// utilities
import '../utils/utils.dart';
// resources
import '../resources/firestore_methods.dart';
// providers
import '../providers/user_provider.dart';
// models
import '../models/user.dart';

// screen when adding a post
class AddPostScreen extends StatefulWidget {
  const AddPostScreen({ Key? key }) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}
// state of screen
class _AddPostScreenState extends State<AddPostScreen> {
  final _postController = TextEditingController();
  final _postFormKey = GlobalKey<FormState>();  // for validating post text field
  final bool _validatePost = false;

  // dispose to release resources
  // no parameters
  // no return
  @override 
  void dispose() {  
    super.dispose();
    _postController.dispose();
  }

  // function when post button is clicked
  // takes in strings user id and username
  // no return
  void postButtonFunction(String uid, String username) async {
    
    // if post is validated/not empty
    if (_postFormKey.currentState!.validate()) {  
      try {
        String response = await FirestoreMethods().sendPostToFirestore(
          _postController.text,
          uid,
          username
        );

        if (response == "Post uploaded successfully") {
          showSnackBar("Post uploaded successfully", context);  // show snackbar for result
        } else {
          showSnackBar(response, context);
        }
      } catch (error) {
        showSnackBar(error.toString(), context);
      }
      // clear controller after posting
      _postController.clear();
      FocusScope.of(context).unfocus(); // unfocus the keyboard
    }
  }

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    AppUser? _user = Provider.of<UserProvider>(context).getUser;

    return GestureDetector( // to use onTap
      onTap: () => FocusScope.of(context).unfocus(),  // unfocus the keyboard on user tap
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(27, 22, 38, 1),
        body: Column(
          children: [

            // ADD POST TITLE
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: const Color.fromRGBO(166, 78, 70, 1),
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                "Add Post",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
    
            // POST TEXT BOX
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(242, 149, 68, 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Form(  // form for validation
                key: _postFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _postController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'What do you want to post, ${_user?.username}?',
                      border: InputBorder.none,
                      errorText: _validatePost ? 'Value can\'t be empty' : null
                    ),
                    validator: (value) {
                      // validates if value in controller/textfield is not empty
                      if (value == null || value.isEmpty) {
                        return 'Post cannot be empty!';
                      }
                      return null;  // case of no error
                    },
                    
                  ),
                ),
              ),
            ),
    
            // POST BUTTON
            InkWell(
              child: Container(
                alignment: Alignment.center,
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.purple],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
              ),
              onTap: () {
                postButtonFunction(_user!.uid, _user.username);
              },
            ),
    
          ],
        ),
      ),
    );

    
  }
}