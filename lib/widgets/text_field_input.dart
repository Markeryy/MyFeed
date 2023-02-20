import 'package:flutter/material.dart';

// class for login text field widget
class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPass;  // determine if text field is password
  final String hintText;
  final TextInputType textInputType;

  const LoginTextField({
    Key? key,
    required this.controller,
    this.isPass = false,  // default = false
    required this.hintText,
    required this.textInputType
  }) : super(key: key);

  // widget build method
  // takes in context
  // returns the widget
  @override
  Widget build(BuildContext context) {
    final textBorder = OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: textBorder,
        focusedBorder: textBorder,
        enabledBorder: textBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isPass,  // if textfield is password, hide text
    );
  }
}