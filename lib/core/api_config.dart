class ApiConfig {
  // Ubah ke true saat melakukan testing di emulator lokal (pastikan backend menyala!)
  static const bool useLocalBackend = false;

  // URL untuk Localhost di Android Emulator adalah 10.0.2.2
  static const String localBaseUrl = 'http://10.0.2.2:3000/api';

  // URL untuk Vercel
  static const String remoteBaseUrl = 'https://rentase-api.vercel.app/api';

  static String get baseUrl => useLocalBackend ? localBaseUrl : remoteBaseUrl;
}
