import 'package:flutter/material.dart';
import 'package:rentease/utils/app_colors.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.maroon,
      foregroundColor: AppColors.white,
      elevation: 0,
      toolbarHeight: 76,
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: CircleAvatar(
          backgroundColor: AppColors.white,
          child: Icon(Icons.person, color: AppColors.maroon),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: const [
        Icon(Icons.menu, size: 34),
        SizedBox(width: 16),
      ],
    );
  }
}
