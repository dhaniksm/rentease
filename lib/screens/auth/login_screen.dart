import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/auth_provider.dart';
import 'package:rentease/screens/auth/register_screen.dart';
import 'package:rentease/screens/admin/admin_main_screen.dart';
import 'package:rentease/screens/user/user_main_screen.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/app_logo.dart';
import 'package:rentease/widgets/primary_button.dart';
import 'package:rentease/widgets/rentease_text_field.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      _showError('Email dan Kata Sandi harus diisi');
      return;
    }

    try {
      await context.read<AuthProvider>().login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (!mounted) return;

      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.loadProfile();

      if (!mounted) return;

      if (profileProvider.profile?.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserMainScreen()),
        );
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Email atau kata sandi salah.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak ada koneksi internet.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      }
      _showError(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.maroon,
                borderRadius: BorderRadius.circular(34),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 54),
                  RentEaseTextField(
                    controller: emailController,
                    hintText: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Lupa Kata Sandi?',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RentEaseTextField(
                    controller: passwordController,
                    hintText: 'Kata Sandi',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'LOGIN',
                    isLoading: authProvider.isLoading,
                    onPressed: login,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum Punya Akun?',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
