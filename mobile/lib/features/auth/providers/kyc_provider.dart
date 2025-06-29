import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/kyc_models.dart';
import '../../../shared/services/api_service.dart';

final kycProvider = StateNotifierProvider<KycNotifier, KycState>((ref) {
  return KycNotifier(ref.read(apiServiceProvider));
});

class KycNotifier extends StateNotifier<KycState> {
  final ApiService _apiService;

  KycNotifier(this._apiService) : super(const KycState());

  Future<void> loadKycStatus(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/kyc/status/$userId');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profile = KycProfile.fromJson(data['data']);
        
        state = state.copyWith(
          status: profile.status,
          personalInfo: profile.personalInfo,
          addressInfo: profile.addressInfo,
          submittedAt: profile.submittedAt,
          reviewedAt: profile.approvedAt,
          rejectionReasons: profile.rejectionReasons,
          isLoading: false,
        );
      } else {
        throw Exception('Failed to load KYC status');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load verification status: ${e.toString()}',
      );
    }
  }

  Future<void> submitKyc(KycSubmissionData kycData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create multipart request for file uploads
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.baseUrl}/kyc/submit'),
      );

      // Add headers
      request.headers.addAll(_apiService.headers);

      // Add form fields
      request.fields['personalInfo'] = json.encode(kycData.personalInfo.toJson());
      request.fields['addressInfo'] = json.encode(kycData.addressInfo.toJson());

      // Add files
      request.files.add(await http.MultipartFile.fromPath(
        'frontIdImage',
        kycData.documents.frontIdImage.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'backIdImage',
        kycData.documents.backIdImage.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'selfieImage',
        kycData.documents.selfieImage.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        state = state.copyWith(
          status: KycStatus.submitted,
          personalInfo: kycData.personalInfo,
          addressInfo: kycData.addressInfo,
          submittedAt: DateTime.now(),
          isLoading: false,
          message: data['message'] ?? 'Verification submitted successfully',
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit verification');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to submit verification: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> resubmitKyc(KycSubmissionData kycData) async {
    // Reset status to in progress and submit again
    state = state.copyWith(status: KycStatus.inProgress);
    await submitKyc(kycData);
  }

  Future<void> checkKycStatus(String userId) async {
    try {
      final response = await _apiService.get('/kyc/status/$userId');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profile = KycProfile.fromJson(data['data']);
        
        // Only update if status has changed
        if (profile.status != state.status) {
          state = state.copyWith(
            status: profile.status,
            reviewedAt: profile.approvedAt,
            rejectionReasons: profile.rejectionReasons,
            message: _getStatusMessage(profile.status),
          );
        }
      }
    } catch (e) {
      // Silent fail for status checks
    }
  }

  String _getStatusMessage(KycStatus status) {
    switch (status) {
      case KycStatus.approved:
        return 'Congratulations! Your identity has been verified. You can now trade with real money.';
      case KycStatus.rejected:
        return 'Your verification was rejected. Please review the reasons and resubmit.';
      case KycStatus.needsReview:
        return 'Additional information is required. Please check your messages.';
      default:
        return '';
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }

  void reset() {
    state = const KycState();
  }
}

// Provider for checking if user can trade (KYC approved)
final canTradeProvider = Provider<bool>((ref) {
  final kycState = ref.watch(kycProvider);
  return kycState.canTrade;
});

// Provider for KYC status display
final kycStatusDisplayProvider = Provider<String>((ref) {
  final kycState = ref.watch(kycProvider);
  return kycState.statusDisplayText;
});

// Provider for KYC completion percentage
final kycCompletionProvider = Provider<double>((ref) {
  final kycState = ref.watch(kycProvider);
  
  switch (kycState.status) {
    case KycStatus.notStarted:
      return 0.0;
    case KycStatus.inProgress:
      return 0.3;
    case KycStatus.submitted:
      return 0.7;
    case KycStatus.approved:
      return 1.0;
    case KycStatus.rejected:
    case KycStatus.needsReview:
      return 0.5;
  }
});