import 'package:flutter/material.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/screens/user/profile_screen.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.maroon,
      elevation: 0,
      toolbarHeight: 76,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: CircleAvatar(
            backgroundColor: AppColors.maroon.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.maroon),
          ),
        ),
      ),
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: AppColors.maroon,
        ),
      ),
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.menu, size: 28, color: AppColors.maroon),
        ),
      ],
    );
  }
}
