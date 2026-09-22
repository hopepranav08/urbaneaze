class AnnouncementModel {
  final String id;
  final String text;
  final String fileUrl;
  final String fileType;
  final String postedBy;
  final int timestamp;

  const AnnouncementModel({
    required this.id,
    required this.text,
    this.fileUrl = '',
    this.fileType = '',
    this.postedBy = '',
    required this.timestamp,
  });

  factory AnnouncementModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final fileUrl = map['fileUrl']?.toString() ?? '';
    String fileType = map['fileType']?.toString() ?? '';
    if (fileType.isEmpty && fileUrl.isNotEmpty) {
      if (fileUrl.toLowerCase().endsWith('.pdf')) {
        fileType = 'pdf';
      } else if (fileUrl.toLowerCase().contains('.jpg') ||
          fileUrl.toLowerCase().contains('.jpeg') ||
          fileUrl.toLowerCase().contains('.png')) {
        fileType = 'image';
      }
    }
    return AnnouncementModel(
      id: id,
      text: map['text']?.toString() ?? '',
      fileUrl: fileUrl,
      fileType: fileType,
      postedBy: map['postedBy']?.toString() ?? '',
      timestamp: map['timestamp'] is int
          ? map['timestamp']
          : int.tryParse(map['timestamp'].toString()) ?? 0,
    );
  }

  bool get hasFile => fileUrl.isNotEmpty;
  bool get isImage => fileType == 'image';
  bool get isPdf => fileType == 'pdf';
}
