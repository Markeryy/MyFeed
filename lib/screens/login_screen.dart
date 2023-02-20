import 'package:flutter/material.dart';

// resources
import '../resources/auth_methods.dart';
// utilities
import '../utils/utils.dart';
// widgets
import '../widgets/text_field_input.dart';
import '../widgets/myfeed_appbar_no_search.dart';
// screens
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';

// screen for logging in user
class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// state of screen
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // dispose to release resources
  // no parameters
  // no return
  @override
  void dispose() {
    super.dispose();  
    _emailController.dispose();
    _passwordController.dispose();
  }

  // called when log in button is clicked
  // no parameters
  // no return
  void loginUser() async {
    setState(() { // start loading
      _isLoading = true;
    });

    // login the user given details from the controller
    String result = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (result == "Login user success") {
      print("LOGIN SUCCESS");
      Navigator.of(context).pushReplacement(  // go to home screen
        MaterialPageRoute(builder: (context) => const HomeScreen())
      );
    } else {
      // show error in snackbar
      showSnackBar(result, context);
    }

    setState(() { // end loading
      _isLoading = false;
    });
  }

  // called when sign up button is clicked
  // no parameters
  // no return
  void openSignUpScreen() {
    // navigate to signup screen
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
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

              // ROW OF BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  // LOG IN BUTTON
                  _isLoading // check if loading
                  ? const Center(child: CircularProgressIndicator(),)
                  : InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.purple],
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ), 
                    onTap: loginUser,
                  ),

                  // SIGN UP BUTTON
                  InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.purple],
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ), 
                    onTap: openSignUpScreen,
                  ),

                ],
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