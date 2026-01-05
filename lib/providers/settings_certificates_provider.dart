import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_certificates_model.dart';
import '../providers/auth_session_provider.dart';
import '../services/settings_certificate_services.dart';

// Service Provider
final certificateServiceProvider = Provider<CertificateService>((ref) {
  return CertificateService();
});

// Certificates State Provider
final certificatesProvider = StateNotifierProvider<CertificatesNotifier, AsyncValue<List<Certificate>>>((ref) {
  final service = ref.watch(certificateServiceProvider);
  final authSession = ref.watch(authSessionProvider);
  return CertificatesNotifier(service, authSession.token);
});

class CertificatesNotifier extends StateNotifier<AsyncValue<List<Certificate>>> {
  final CertificateService _service;
  final String? _token;

  CertificatesNotifier(this._service, this._token) : super(const AsyncValue.loading()) {
    loadCertificates();
  }

  Future<void> loadCertificates() async {
    if (_token == null) {
      state = AsyncValue.error('No authentication token found', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final response = await _service.getCertificates(_token!);
      state = AsyncValue.data(response.data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

 
}