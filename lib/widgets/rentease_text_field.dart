import 'package:flutter/material.dart';
import 'package:rentease/utils/app_colors.dart';

class RentEaseTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color color;

  const RentEaseTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.color = AppColors.maroon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        prefixIcon: icon == null ? null : Icon(icon, color: color),
        hintText: hintText,
        hintStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}
