class SubmittedCvModel {
  final String fileLink;
  final String fileName;

  SubmittedCvModel({required this.fileLink, required this.fileName});

  factory SubmittedCvModel.fromJson(Map<String, dynamic> json) {
    return SubmittedCvModel(
      fileLink: json['fileLink'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'Unknown File',
    );
  }
}