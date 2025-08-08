import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
   required this.textEditingController,
   required this.labelText,
   this.obscureText,
   required this.validator
  });

  final TextEditingController textEditingController;
  final String labelText;
  final bool? obscureText;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField( //kullanıcıdan email şifre alır
    obscureText: obscureText ?? false,
      controller: textEditingController,
      decoration:  InputDecoration(labelText: labelText),
      validator: validator
    );
  }
}