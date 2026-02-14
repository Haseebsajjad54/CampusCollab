import 'package:equatable/equatable.dart';

/// Application entity - Domain layer
class Application extends Equatable {
  final String id;
  final String postId;
  final String applicantId;
  final String message;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields
  final String? postTitle;
  final String? postType;
  final String? applicantName;
  final String? applicantImage;
  final String? applicantDepartment;
  final int? applicantYear;
  final String? responseMessage;

  const Application({
    required this.id,
    required this.postId,
    required this.applicantId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.postTitle,
    this.postType,
    this.applicantName,
    this.applicantImage,
    this.applicantDepartment,
    this.applicantYear,
    this.responseMessage,
  });

  Application copyWith({
    String? id,
    String? postId,
    String? applicantId,
    String? message,
    ApplicationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? postTitle,
    String? postType,
    String? applicantName,
    String? applicantImage,
    String? applicantDepartment,
    int? applicantYear,
    String? responseMessage,
  }) {
    return Application(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      applicantId: applicantId ?? this.applicantId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      postTitle: postTitle ?? this.postTitle,
      postType: postType ?? this.postType,
      applicantName: applicantName ?? this.applicantName,
      applicantImage: applicantImage ?? this.applicantImage,
      applicantDepartment: applicantDepartment ?? this.applicantDepartment,
      applicantYear: applicantYear ?? this.applicantYear,
      responseMessage: responseMessage ?? this.responseMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    postId,
    applicantId,
    message,
    status,
    createdAt,
    updatedAt,
    postTitle,
    postType,
    applicantName,
    applicantImage,
    applicantDepartment,
    applicantYear,
    responseMessage,
  ];
}

/// Application status enum
enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  static ApplicationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        return ApplicationStatus.pending;
    }
  }
}