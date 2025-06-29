import 'dart:io';

enum KycStatus {
  notStarted,
  inProgress,
  submitted,
  approved,
  rejected,
  needsReview,
}

class PersonalInfo {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String phoneNumber;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'dateOfBirth': dateOfBirth,
    'phoneNumber': phoneNumber,
  };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    firstName: json['firstName'],
    lastName: json['lastName'],
    dateOfBirth: json['dateOfBirth'],
    phoneNumber: json['phoneNumber'],
  );
}

class AddressInfo {
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  AddressInfo({
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
    'streetAddress': streetAddress,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'country': country,
  };

  factory AddressInfo.fromJson(Map<String, dynamic> json) => AddressInfo(
    streetAddress: json['streetAddress'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zipCode'],
    country: json['country'],
  );
}

class DocumentInfo {
  final File frontIdImage;
  final File backIdImage;
  final File selfieImage;

  DocumentInfo({
    required this.frontIdImage,
    required this.backIdImage,
    required this.selfieImage,
  });
}

class KycSubmissionData {
  final PersonalInfo personalInfo;
  final AddressInfo addressInfo;
  final DocumentInfo documents;

  KycSubmissionData({
    required this.personalInfo,
    required this.addressInfo,
    required this.documents,
  });
}

class KycState {
  final KycStatus status;
  final bool isLoading;
  final String? error;
  final String? message;
  final PersonalInfo? personalInfo;
  final AddressInfo? addressInfo;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final List<String> rejectionReasons;

  const KycState({
    this.status = KycStatus.notStarted,
    this.isLoading = false,
    this.error,
    this.message,
    this.personalInfo,
    this.addressInfo,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReasons = const [],
  });

  KycState copyWith({
    KycStatus? status,
    bool? isLoading,
    String? error,
    String? message,
    PersonalInfo? personalInfo,
    AddressInfo? addressInfo,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    List<String>? rejectionReasons,
  }) {
    return KycState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
      personalInfo: personalInfo ?? this.personalInfo,
      addressInfo: addressInfo ?? this.addressInfo,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReasons: rejectionReasons ?? this.rejectionReasons,
    );
  }

  bool get canTrade => status == KycStatus.approved;
  bool get isVerified => status == KycStatus.approved;
  bool get isPending => status == KycStatus.submitted || status == KycStatus.inProgress;
  bool get needsAction => status == KycStatus.rejected || status == KycStatus.needsReview;

  String get statusDisplayText {
    switch (status) {
      case KycStatus.notStarted:
        return 'Verification Required';
      case KycStatus.inProgress:
        return 'In Progress';
      case KycStatus.submitted:
        return 'Under Review';
      case KycStatus.approved:
        return 'Verified ✓';
      case KycStatus.rejected:
        return 'Rejected';
      case KycStatus.needsReview:
        return 'Needs Review';
    }
  }

  String get statusDescription {
    switch (status) {
      case KycStatus.notStarted:
        return 'Complete identity verification to enable real trading';
      case KycStatus.inProgress:
        return 'Please complete all verification steps';
      case KycStatus.submitted:
        return 'We\'re reviewing your documents. This usually takes 1-2 business days.';
      case KycStatus.approved:
        return 'Your identity has been verified. You can now trade with real money.';
      case KycStatus.rejected:
        return 'Verification was rejected. Please review the reasons and resubmit.';
      case KycStatus.needsReview:
        return 'Additional information is required. Please check your messages.';
    }
  }
}

class KycDocument {
  final String id;
  final String type;
  final String fileName;
  final String status;
  final DateTime uploadedAt;
  final String? rejectionReason;

  KycDocument({
    required this.id,
    required this.type,
    required this.fileName,
    required this.status,
    required this.uploadedAt,
    this.rejectionReason,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) => KycDocument(
    id: json['id'],
    type: json['type'],
    fileName: json['fileName'],
    status: json['status'],
    uploadedAt: DateTime.parse(json['uploadedAt']),
    rejectionReason: json['rejectionReason'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'fileName': fileName,
    'status': status,
    'uploadedAt': uploadedAt.toIso8601String(),
    'rejectionReason': rejectionReason,
  };
}

class KycProfile {
  final String userId;
  final KycStatus status;
  final PersonalInfo? personalInfo;
  final AddressInfo? addressInfo;
  final List<KycDocument> documents;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? lastUpdated;
  final List<String> rejectionReasons;
  final bool canTrade;
  final Map<String, dynamic> metadata;

  KycProfile({
    required this.userId,
    required this.status,
    this.personalInfo,
    this.addressInfo,
    required this.documents,
    this.submittedAt,
    this.approvedAt,
    this.lastUpdated,
    this.rejectionReasons = const [],
    this.canTrade = false,
    this.metadata = const {},
  });

  factory KycProfile.fromJson(Map<String, dynamic> json) => KycProfile(
    userId: json['userId'],
    status: KycStatus.values.firstWhere(
      (e) => e.toString() == 'KycStatus.${json['status']}',
      orElse: () => KycStatus.notStarted,
    ),
    personalInfo: json['personalInfo'] != null 
        ? PersonalInfo.fromJson(json['personalInfo']) 
        : null,
    addressInfo: json['addressInfo'] != null 
        ? AddressInfo.fromJson(json['addressInfo']) 
        : null,
    documents: (json['documents'] as List<dynamic>?)
        ?.map((doc) => KycDocument.fromJson(doc))
        .toList() ?? [],
    submittedAt: json['submittedAt'] != null 
        ? DateTime.parse(json['submittedAt']) 
        : null,
    approvedAt: json['approvedAt'] != null 
        ? DateTime.parse(json['approvedAt']) 
        : null,
    lastUpdated: json['lastUpdated'] != null 
        ? DateTime.parse(json['lastUpdated']) 
        : null,
    rejectionReasons: List<String>.from(json['rejectionReasons'] ?? []),
    canTrade: json['canTrade'] ?? false,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'status': status.toString().split('.').last,
    'personalInfo': personalInfo?.toJson(),
    'addressInfo': addressInfo?.toJson(),
    'documents': documents.map((doc) => doc.toJson()).toList(),
    'submittedAt': submittedAt?.toIso8601String(),
    'approvedAt': approvedAt?.toIso8601String(),
    'lastUpdated': lastUpdated?.toIso8601String(),
    'rejectionReasons': rejectionReasons,
    'canTrade': canTrade,
    'metadata': metadata,
  };
}