class FacilityBookingModel {
  final String id;
  final String userId;
  final String userName;
  final String flatNumber;
  final String amenity;
  final String date;
  final int startTime;
  final int endTime;
  final String societyCode;
  final String status;

  const FacilityBookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.flatNumber,
    required this.amenity,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.societyCode,
    this.status = 'Confirmed',
  });

  factory FacilityBookingModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return FacilityBookingModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      flatNumber: map['flatNumber']?.toString() ?? '',
      amenity: map['amenity']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      startTime: map['startTime'] is int ? map['startTime'] : int.tryParse(map['startTime'].toString()) ?? 0,
      endTime: map['endTime'] is int ? map['endTime'] : int.tryParse(map['endTime'].toString()) ?? 0,
      societyCode: map['societyCode']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Confirmed',
    );
  }

  String get timeRange => '$startTime:00 – $endTime:00';
}
