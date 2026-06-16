import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing API...');
  try {
    final response = await http.get(Uri.parse('https://rentase-api.vercel.app/api/vehicles')).timeout(Duration(seconds: 5));
    print('Status: \${response.statusCode}');
    print('Body: \${response.body.substring(0, 100)}...');
  } catch (e) {
    print('Error: \$e');
  }
}
