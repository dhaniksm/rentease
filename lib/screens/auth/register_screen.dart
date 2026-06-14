import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/auth_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/app_logo.dart';
import 'package:rentease/widgets/primary_button.dart';
import 'package:rentease/widgets/rentease_text_field.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

  Future<void> register() async {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showError('Semua kolom harus diisi');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showError('Konfirmasi kata sandi tidak sama');
      return;
    }

    try {
      await context.read<AuthProvider>().register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phoneNumber: phoneController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Register berhasil, silakan login'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      if (e.toString().contains('already registered')) {
        errorMessage = 'Email ini sudah terdaftar.';
      } else if (e.toString().contains('Password should be at least')) {
        errorMessage = 'Kata sandi terlalu pendek (minimal 6 karakter).';
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
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 40),
              child: Column(
                children: [
                  const AppLogo(color: AppColors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Buat Akun Baru',
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
                    'Lengkapi data di bawah untuk bergabung',
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
                      RentEaseTextField(
                        controller: fullNameController,
                        hintText: 'Nama Lengkap',
                        icon: Icons.person,
                        color: AppColors.maroon,
                      ),
                      const SizedBox(height: 20),
                      RentEaseTextField(
                        controller: emailController,
                        hintText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        color: AppColors.maroon,
                      ),
                      const SizedBox(height: 20),
                      RentEaseTextField(
                        controller: phoneController,
                        hintText: 'Nomor Telepon',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        color: AppColors.maroon,
                      ),
                      const SizedBox(height: 20),
                      RentEaseTextField(
                        controller: passwordController,
                        hintText: 'Kata Sandi',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        color: AppColors.maroon,
                      ),
                      const SizedBox(height: 20),
                      RentEaseTextField(
                        controller: confirmPasswordController,
                        hintText: 'Konfirmasi Kata Sandi',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        color: AppColors.maroon,
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: 'REGISTER',
                        isLoading: authProvider.isLoading,
                        onPressed: register,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah Punya Akun?',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                color: AppColors.maroon,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
