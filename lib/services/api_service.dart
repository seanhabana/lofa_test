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

  static Future<http.Response> get(
    String endpoint, {
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('📥 GET Request to: $url');
    print('📥 Token: ${token != null ? "${token.substring(0, 20)}..." : "none"}');
    
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ GET request error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('📤 POST Request to: $url');
    print('📤 Body: $body');
    print('📤 Token: ${token != null ? "${token.substring(0, 20)}..." : "none"}');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ POST request error: $e');
      rethrow;
    }
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('🔄 PUT Request to: $url');
    print('🔄 Body: $body');
    print('🔄 Token: ${token != null ? "${token.substring(0, 20)}..." : "none"}');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ PUT request error: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('🗑️ DELETE Request to: $url');
    print('🗑️ Body: $body');
    print('🗑️ Token: ${token != null ? "${token.substring(0, 20)}..." : "none"}');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ DELETE request error: $e');
      rethrow;
    }
  }

  static Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('🔧 PATCH Request to: $url');
    print('🔧 Body: $body');
    print('🔧 Token: ${token != null ? "${token.substring(0, 20)}..." : "none"}');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ PATCH request error: $e');
      rethrow;
    }
  }
}