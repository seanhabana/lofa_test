class Certificate {
  final int id;
  final String certificateNumber;
  final String courseTitle;
  final String studentName;
  final String completionDate;
  final String issueDate;
  final String issueDateTimestamp;
  final String grade;
  final String finalScore;
  final int totalHours;
  final String certificateFilePath;
  final String downloadUrl;
  final String verificationCode;
  final String? emailedAt;
  final String? downloadedAt;
  final bool isValid;
  final CertificateCourse course;

  Certificate({
    required this.id,
    required this.certificateNumber,
    required this.courseTitle,
    required this.studentName,
    required this.completionDate,
    required this.issueDate,
    required this.issueDateTimestamp,
    required this.grade,
    required this.finalScore,
    required this.totalHours,
    required this.certificateFilePath,
    required this.downloadUrl,
    required this.verificationCode,
    this.emailedAt,
    this.downloadedAt,
    required this.isValid,
    required this.course,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] ?? 0,
      certificateNumber: json['certificate_number'] ?? '',
      courseTitle: json['course_title'] ?? '',
      studentName: json['student_name'] ?? '',
      completionDate: json['completion_date'] ?? '',
      issueDate: json['issue_date'] ?? '',
      issueDateTimestamp: json['issue_date_timestamp'] ?? '',
      grade: json['grade'] ?? '',
      finalScore: json['final_score'] ?? '',
      totalHours: json['total_hours'] ?? 0,
      certificateFilePath: json['certificate_file_path'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      verificationCode: json['verification_code'] ?? '',
      emailedAt: json['emailed_at'],
      downloadedAt: json['downloaded_at'],
      isValid: json['is_valid'] ?? true,
      course: CertificateCourse.fromJson(json['course'] ?? {}),
    );
  }
}

class CertificateCourse {
  final int id;
  final String title;
  final String slug;

  CertificateCourse({
    required this.id,
    required this.title,
    required this.slug,
  });

  factory CertificateCourse.fromJson(Map<String, dynamic> json) {
    return CertificateCourse(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class CertificatesResponse {
  final bool success;
  final List<Certificate> data;
  final int total;

  CertificatesResponse({
    required this.success,
    required this.data,
    required this.total,
  });

  factory CertificatesResponse.fromJson(Map<String, dynamic> json) {
    return CertificatesResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Certificate.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}