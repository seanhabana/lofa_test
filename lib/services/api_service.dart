import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  static Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(token: token),
        body: json.encode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<http.Response> get(
    String endpoint, {
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}