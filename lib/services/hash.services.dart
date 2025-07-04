import 'package:dio/dio.dart';

class HashService {
 final Dio _dio = Dio(BaseOptions(baseUrl: 'https://encryptit.onrender.com')); // if Android Emulator
 // Replace with IP if using emulator

  Future<String> hashText(String text, String algorithm) async {
    try {
      final response = await _dio.post(
        '/hash',
        data: {
          'text': text,
          'algorithm': algorithm,
        },
      );
      return response.data['hashed'] ?? "No hash returned";
    } catch (e) {
      print('Hashing error: $e');
      return 'Error';
    }
  }
}
