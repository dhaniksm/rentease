import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rentease/screens/auth/login_screen.dart';
import 'package:rentease/screens/admin/admin_main_screen.dart';
import 'package:rentease/screens/user/user_main_screen.dart';
import 'package:rentease/providers/rental_provider.dart';

import 'package:rentease/providers/payment_provider.dart';
import 'package:rentease/providers/dashboard_provider.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/providers/auth_provider.dart';
import 'package:rentease/providers/favorite_provider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cswqooinrsjvhvqqifpn.supabase.co',
    anonKey: 'sb_publishable_xe9F-9q9Qrq-H0h7_B_pjw_mt8aUKTS',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => RentalProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()..loadFavorites()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: supabase.auth.currentUser == null
            ? const LoginScreen()
            : const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
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
      debugPrint('Error checking role: $e');
      if (!mounted) return;
      // Fallback to UserMainScreen if profile fetch fails
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserMainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
