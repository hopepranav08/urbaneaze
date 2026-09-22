class ComplaintModel {
  final String id;
  final String title;
  final String message;
  final String name;
  final String flatNumber;
  final String category;
  final String status;
  final int timestamp;

  const ComplaintModel({
    required this.id,
    required this.title,
    required this.message,
    required this.name,
    required this.flatNumber,
    this.category = 'General',
    this.status = 'Open',
    required this.timestamp,
  });

  factory ComplaintModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ComplaintModel(
      id: id,
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      flatNumber: map['flatNumber']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      status: map['status']?.toString() ?? 'Open',
      timestamp: map['timestamp'] is int
          ? map['timestamp']
          : int.tryParse(map['timestamp'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'message': message,
    'name': name,
    'flatNumber': flatNumber,
    'category': category,
    'status': status,
    'timestamp': timestamp,
  };
}
