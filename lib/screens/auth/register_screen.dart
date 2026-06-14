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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.maroon,
                borderRadius: BorderRadius.circular(34),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 34),
                  RentEaseTextField(
                    controller: fullNameController,
                    hintText: 'Nama Lengkap',
                    icon: Icons.person,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 20),
                  RentEaseTextField(
                    controller: emailController,
                    hintText: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 20),
                  RentEaseTextField(
                    controller: phoneController,
                    hintText: 'Nomor Telepon',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 20),
                  RentEaseTextField(
                    controller: passwordController,
                    hintText: 'Kata Sandi',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 20),
                  RentEaseTextField(
                    controller: confirmPasswordController,
                    hintText: 'Konfirmasi Kata Sandi',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    text: 'REGISTER',
                    isLoading: authProvider.isLoading,
                    onPressed: register,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah Punya Akun?',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
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
