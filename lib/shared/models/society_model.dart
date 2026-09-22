class SocietyModel {
  final String societyCode;
  final String societyName;
  final String address;
  final int numOfFlats;
  final String contactPerson;
  final String contactNumber;
  final List<String> amenities;
  final String adminId;

  const SocietyModel({
    required this.societyCode,
    required this.societyName,
    required this.address,
    required this.numOfFlats,
    required this.contactPerson,
    required this.contactNumber,
    required this.amenities,
    required this.adminId,
  });

  factory SocietyModel.fromMap(String code, Map<dynamic, dynamic> map) {
    final amenitiesRaw = map['amenities'];
    List<String> amenities = [];
    if (amenitiesRaw is List) {
      amenities = amenitiesRaw.map((e) => e.toString()).toList();
    }
    return SocietyModel(
      societyCode: code,
      societyName: map['societyName'] ?? '',
      address: map['address'] ?? '',
      numOfFlats: (map['numOfFlats'] ?? 0) is int
          ? map['numOfFlats']
          : int.tryParse(map['numOfFlats'].toString()) ?? 0,
      contactPerson: map['contactPerson'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      amenities: amenities,
      adminId: map['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'societyCode': societyCode,
    'societyName': societyName,
    'address': address,
    'numOfFlats': numOfFlats,
    'contactPerson': contactPerson,
    'contactNumber': contactNumber,
    'amenities': amenities,
    'adminId': adminId,
  };
}
