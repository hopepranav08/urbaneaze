class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String occupancy;
  final String carNumber;
  final String role;
  final String societyCode;
  final String flatNumber;
  final String profileImageUrl;
  final String fcmToken;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.occupancy = 'Owner',
    this.carNumber = 'NA',
    this.role = 'pending',
    this.societyCode = '',
    this.flatNumber = '',
    this.profileImageUrl = '',
    this.fcmToken = '',
  });

  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      occupancy: map['occupancy'] ?? 'Owner',
      carNumber: map['car'] ?? 'NA',
      role: map['role'] ?? 'pending',
      societyCode: map['societyCode'] ?? '',
      flatNumber: map['flatNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'occupancy': occupancy,
    'car': carNumber,
    'role': role,
    'societyCode': societyCode,
    'flatNumber': flatNumber,
    'profileImageUrl': profileImageUrl,
    'fcmToken': fcmToken,
  };

  UserModel copyWith({
    String? name, String? phone, String? role, String? societyCode,
    String? flatNumber, String? carNumber, String? profileImageUrl, String? fcmToken,
  }) {
    return UserModel(
      uid: uid, email: email, occupancy: occupancy,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      societyCode: societyCode ?? this.societyCode,
      flatNumber: flatNumber ?? this.flatNumber,
      carNumber: carNumber ?? this.carNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
