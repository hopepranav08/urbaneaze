class VisitorModel {
  final String id;
  final String name;
  final String phone;
  final String purpose;
  final String customPurpose;
  final String flat;
  final bool hasCar;
  final String rfidTag;
  final String carNumber;
  final String imageUrl;
  final String status;
  final String watchmanId;
  final String residentId;
  final int timestamp;

  const VisitorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.purpose,
    this.customPurpose = '',
    required this.flat,
    this.hasCar = false,
    this.rfidTag = '',
    this.carNumber = '',
    this.imageUrl = '',
    required this.status,
    this.watchmanId = '',
    this.residentId = '',
    required this.timestamp,
  });

  factory VisitorModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return VisitorModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      purpose: map['purpose'] ?? '',
      customPurpose: map['customPurposeText'] ?? '',
      flat: map['flat'] ?? '',
      hasCar: map['hasCar'] == true,
      rfidTag: map['rfidTag'] ?? '',
      carNumber: map['carNumber'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      status: map['status'] ?? 'Pending',
      watchmanId: map['watchmanId'] ?? '',
      residentId: map['residentId'] ?? '',
      timestamp: map['timestamp'] is int
          ? map['timestamp']
          : int.tryParse(map['timestamp'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'purpose': purpose,
    'customPurposeText': customPurpose,
    'flat': flat,
    'hasCar': hasCar,
    'rfidTag': rfidTag,
    'carNumber': carNumber,
    'imageUrl': imageUrl,
    'status': status,
    'watchmanId': watchmanId,
    'residentId': residentId,
    'timestamp': timestamp,
  };

  VisitorModel copyWith({String? status}) => VisitorModel(
    id: id, name: name, phone: phone, purpose: purpose,
    customPurpose: customPurpose, flat: flat, hasCar: hasCar,
    rfidTag: rfidTag, carNumber: carNumber, imageUrl: imageUrl,
    watchmanId: watchmanId, residentId: residentId, timestamp: timestamp,
    status: status ?? this.status,
  );

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
}
