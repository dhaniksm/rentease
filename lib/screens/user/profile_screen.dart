import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/auth_provider.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/screens/auth/login_screen.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  Future<void> logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.maroon,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: profileProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              )
            : Column(
                children: [
                  // Header Section (Avatar and Name)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: AppColors.maroon.withValues(alpha: 0.1),
                            backgroundImage: profile?.avatarUrl == null
                                ? null
                                : NetworkImage(profile!.avatarUrl!),
                            child: profile?.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.maroon,
                                    size: 64,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile?.fullName.isNotEmpty == true
                              ? profile!.fullName
                              : 'Nama Lengkap',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile?.role == 'admin' ? 'Administrator' : 'Pelanggan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Details Section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Informasi Kontak',
                              style: TextStyle(
                                color: AppColors.maroon,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _ProfileText(
                              icon: Icons.phone,
                              label: 'Nomor Telepon',
                              text: profile?.phoneNumber.isNotEmpty == true
                                  ? profile!.phoneNumber
                                  : 'Belum diatur',
                            ),
                            const SizedBox(height: 20),
                            _ProfileText(
                              icon: Icons.email,
                              label: 'Alamat Email',
                              text: profile?.email.isNotEmpty == true
                                  ? profile!.email
                                  : 'Belum diatur',
                            ),
                            const SizedBox(height: 50),
                            PrimaryButton(text: 'LOGOUT', onPressed: logout),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileText extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const _ProfileText({
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.maroon.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.maroon, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.maroon,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
