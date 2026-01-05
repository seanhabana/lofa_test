import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/subscription_models.dart';


class SubscriptionService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static Future<SubscriptionPlansResponse> getPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SubscriptionPlansResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Subscription plans not found.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load subscription plans',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Unable to fetch subscription plans');
    }
  }

  // Optional: If you need to pass authentication token
  static Future<SubscriptionPlansResponse> getPlansWithAuth(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SubscriptionPlansResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Subscription plans not found.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load subscription plans',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: Unable to fetch subscription plans');
    }
  }
}