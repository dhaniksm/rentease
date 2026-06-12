import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/auth_provider.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/screens/auth/login_screen.dart';
import 'package:rentease/screens/payment/admin_payment_screen.dart';
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
    Future.microtask(() => context.read<ProfileProvider>().loadProfile());
  }

  Future<void> logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 80,
            padding: const EdgeInsets.fromLTRB(46, 72, 46, 70),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(34),
            ),
            child: profileProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.white))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.white,
                        backgroundImage: profile?.avatarUrl == null ? null : NetworkImage(profile!.avatarUrl!),
                        child: profile?.avatarUrl == null
                            ? const Icon(Icons.person, color: AppColors.maroon, size: 54)
                            : null,
                      ),
                      const SizedBox(height: 66),
                      _ProfileText(text: profile?.fullName.isNotEmpty == true ? profile!.fullName : 'Nama User'),
                      const SizedBox(height: 22),
                      _ProfileText(text: profile?.phoneNumber.isNotEmpty == true ? profile!.phoneNumber : 'Nomor Telepon'),
                      const SizedBox(height: 22),
                      _ProfileText(text: profile?.email.isNotEmpty == true ? profile!.email : 'Email'),
                      if (profile?.role == 'admin') ...[
                        const SizedBox(height: 22),
                        PrimaryButton(
                          text: 'ADMIN PAYMENT',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminPaymentScreen()),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 70),
                      PrimaryButton(text: 'LOGOUT', onPressed: logout),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProfileText extends StatelessWidget {
  final String text;

  const _ProfileText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
