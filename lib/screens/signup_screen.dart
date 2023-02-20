import 'package:flutter/material.dart';

// auth methods
import '../resources/auth_methods.dart';
// utilities
import '../utils/utils.dart';
// widgets
import '../widgets/text_field_input.dart';
import '../widgets/myfeed_appbar_no_search.dart';
// screens
import './home_screen.dart';

// screen for signing up
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({ Key? key }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// state of screen
class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _aboutmeController = TextEditingController();
  bool _isLoading = false;

  // dispose to release resources
  // no parameters
  // no return
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _aboutmeController.dispose();
  }

  // called when sign up button is clicked
  // no parameters
  // no return
  void signUpUser() async {
    setState(() { // start loading
      _isLoading = true;
    });

    // pass the values from textfield to authenticate
    String result = await AuthMethods().registerUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      aboutme: _aboutmeController.text,
    );

    setState(() { // end loading
      _isLoading = false;
    });

    // if there is an error, show snackbar
    if (result != "Create user success!") {
      showSnackBar(result, context);
    } else {
      // go to home screen (automatic log in)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen())
      );
    }
  }

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyFeedAppBarNoSearch(),
      backgroundColor: const Color.fromRGBO(27, 22, 38, 1),
      body: SafeArea( // safe area for screen
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,  // full width of device
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,  // center elements
            children: [
              // SPACING
              Flexible(
                child: Container(),
                flex: 2,
              ),

              // LOGO
              const Text(
                'MyFeed',
                style: TextStyle(
                  fontSize: 60,
                ),
              ),
              const SizedBox(height: 32,),

              // EMAIL TEXT FIELD
              LoginTextField(
                hintText: 'Enter email',
                textInputType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 20,),

              // PASSWORD TEXT FIELD
              LoginTextField(
                hintText: 'Enter password',
                textInputType: TextInputType.text,
                controller: _passwordController,
                isPass: true,
              ),
              const SizedBox(height: 20,),

              // DISPLAY NAME TEXT FIELD
              LoginTextField(
                hintText: 'Enter display name',
                textInputType: TextInputType.text,
                controller: _usernameController,
              ),
              const SizedBox(height: 20,),

              // ABOUT ME TEXT FIELD
              LoginTextField(
                hintText: 'About you',
                textInputType: TextInputType.text,
                controller: _aboutmeController,
              ),
              const SizedBox(height: 20,),

              // CREATE ACCOUNT BUTTON
              _isLoading // check if loading
              ? const Center(child: CircularProgressIndicator(),)
              : InkWell(
                child: Container(
                  alignment: Alignment.center,
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  child: const Text('Create account'),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.purple],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ), 
                onTap: signUpUser,
              ),


              // SPACING
              Flexible(
                child: Container(),
                flex: 2,
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}