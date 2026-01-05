import 'dart:convert';
import 'api_service.dart';
import '../models/settings_certificates_model.dart';

class CertificateService {
  // Get all certificates
  Future<CertificatesResponse> getCertificates(String token) async {
    try {
      print('🔍 Fetching certificates from /certificates');
      final response = await ApiService.get('/certificates', token: token);

      print('📡 Certificates response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Certificates loaded successfully');
        return CertificatesResponse.fromJson(data);
      } else {
        print('⚠️ Failed to load certificates: ${response.statusCode}');
        throw Exception('Failed to load certificates: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching certificates: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error fetching certificates: $e');
    }
  }

  // Get download URL (just return the URL, don't actually download)
  String getDownloadUrl(int certificateId) {
    return '/certificates/$certificateId/download';
  }
}