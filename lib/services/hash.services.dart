import 'package:dio/dio.dart';

class HashService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://encryptit-1.onrender.com', // Use 10.0.2.2 if Android emulator
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

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

  Future<String> encryptText(String text, String key, String algorithm) async {
    try {
      final response = await _dio.post(
        '/encrypt',
        data: {
          'text': text,
          'key': key,
          'algorithm': algorithm,
        },
      );
      if (algorithm == 'RSA') {
        // If RSA, optionally return more info like public_key/private_key
        return response.data['result'] ?? "No encrypted text returned";
      }
      return response.data['result'] ?? "No encrypted text returned";
    } catch (e) {
      print('Encryption error: $e');
      return 'Error';
    }
  }

  Future<String> decryptText(String encryptedText, String key, String algorithm) async {
    try {
      final response = await _dio.post(
        '/decrypt',
        data: {
          'text': encryptedText,
          'key': key,
          'algorithm': algorithm,
        },
      );
      return response.data['result'] ?? "No decrypted text returned";
    } catch (e) {
      print('Decryption error: $e');
      return 'Error';
    }
  }
}
