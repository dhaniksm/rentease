class ApiConfig {
  // Ubah ke true jika Anda ingin menggunakan backend lokal laptop Anda
  // Ubah ke false jika Anda ingin menggunakan backend Vercel (sekarang sudah jalan!)
  static const bool useLocalBackend = false;

  // IPv4 Address laptop Anda
  static const String localBaseUrl = 'http://192.168.0.104:3000/api'; 
  
  // URL untuk Vercel
  static const String remoteBaseUrl = 'https://rentase-api.vercel.app/api';

  static String get baseUrl {
    final url = useLocalBackend ? localBaseUrl : remoteBaseUrl;
    print('DEBUG: Menggunakan API -> \$url');
    return url;
  }
}
