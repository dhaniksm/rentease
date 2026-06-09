import 'package:flutter/material.dart';
import 'package:rentease/utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final Color color;

  const AppLogo({super.key, this.color = AppColors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.directions_car_filled, size: 70, color: color),
        Text(
          'RENTEASE',
          style: TextStyle(
            color: color,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
