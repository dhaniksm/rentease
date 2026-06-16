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
  bool _obscurePassword = true;

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
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
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
        errorMessage = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('AuthException: ', '');
      }
      _showError(errorMessage);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Lupa Kata Sandi?', style: TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan email Anda untuk menerima tautan reset kata sandi.'),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: AppColors.maroon),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.maroon),
              onPressed: () async {
                if (resetEmailController.text.trim().isEmpty) {
                  _showError('Email tidak boleh kosong');
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await context.read<AuthProvider>().resetPassword(resetEmailController.text.trim());
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tautan reset kata sandi telah dikirim ke email Anda.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  _showError('Gagal mengirim tautan reset: ${e.toString()}');
                }
              },
              child: const Text('Kirim', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: SafeArea(
        bottom: false, // Let the white container flow to the bottom
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              child: Column(
                children: [
                  const AppLogo(color: AppColors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Selamat Datang Kembali!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk melanjutkan sewa kendaraan Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Form Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
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
                      RentEaseTextField(
                        controller: emailController,
                        hintText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        color: AppColors.maroon,
                      ),
                      const SizedBox(height: 20),
                      RentEaseTextField(
                        controller: passwordController,
                        hintText: 'Kata Sandi',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        color: AppColors.maroon,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.maroon,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            'Lupa Kata Sandi?',
                            style: TextStyle(
                              color: AppColors.maroon.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                          Text(
                            'Belum Punya Akun?',
                            style: TextStyle(color: Colors.grey.shade600),
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
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: AppColors.maroon,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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
          ],
        ),
      ),
    );
  }
}
