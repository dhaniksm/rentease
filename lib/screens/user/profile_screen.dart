import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        final file = File(pickedFile.path);
        final extension = pickedFile.path.split('.').last;
        await context.read<ProfileProvider>().updateAvatar(file, extension);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _deleteAvatar() async {
    try {
      await context.read<ProfileProvider>().editProfile(avatarUrl: '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus foto profil: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    final profileProvider = context.read<ProfileProvider>();
    final hasAvatar = profileProvider.profile?.avatarUrl != null && profileProvider.profile!.avatarUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.maroon),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Foto Profil', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<ProfileProvider>().editProfile(
              fullName: _nameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
            );
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui profil: $e')),
          );
        }
      }
    }
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
        actions: [
          if (!profileProvider.isLoading)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: AppColors.white,
              ),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    _isEditing = false;
                  } else {
                    _isEditing = true;
                    _nameController.text = profile?.fullName ?? '';
                    _phoneController.text = profile?.phoneNumber ?? '';
                  }
                });
              },
            ),
        ],
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
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 54,
                                backgroundColor: AppColors.maroon.withValues(
                                  alpha: 0.1,
                                ),
                                backgroundImage: profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty
                                    ? null
                                    : NetworkImage(profile!.avatarUrl!),
                                child: profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: AppColors.maroon,
                                        size: 64,
                                      )
                                    : null,
                              ),
                            ),
                            if (_isEditing)
                              GestureDetector(
                                onTap: _showImagePickerOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.maroon,
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(
                                      BorderSide(color: Colors.white, width: 2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!_isEditing) ...[
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
                            profile?.role == 'admin'
                                ? 'Administrator'
                                : 'Pelanggan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else
                          const Text(
                            'Edit Profil',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
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
                        child: _isEditing
                            ? Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Nama Lengkap',
                                        prefixIcon: const Icon(Icons.person, color: AppColors.maroon),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        labelText: 'Nomor Telepon',
                                        prefixIcon: const Icon(Icons.phone, color: AppColors.maroon),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      validator: (value) => value == null || value.trim().isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                                    ),
                                    const SizedBox(height: 40),
                                    PrimaryButton(
                                      text: 'SIMPAN PERUBAHAN',
                                      onPressed: _saveProfile,
                                    ),
                                  ],
                                ),
                              )
                            : Column(
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
