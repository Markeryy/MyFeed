import 'package:flutter/material.dart';

// class for profile button widget
class ProfileButton extends StatelessWidget {
  final Function()? pressFunction;  // holds the function to call when button is pressed
  final String buttonText;
  
  const ProfileButton({
    Key? key,
    this.pressFunction,
    required this.buttonText
  }) : super(key: key);

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pressFunction,
      child: Container(
        decoration: BoxDecoration(
          gradient: // display different gradient
            buttonText == "Follow"
            ? const LinearGradient(
                colors: [Colors.red, Colors.purple],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft
              )
            : const LinearGradient(
                colors: [Colors.orange, Colors.green],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}