import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/society_model.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

class SocietyService {
  final _db = FirebaseDatabase.instance.ref();

  Future<String> registerSociety({
    required String societyName,
    required String address,
    required int numOfFlats,
    required String contactPerson,
    required String contactNumber,
    required List<String> amenities,
    required UserModel admin,
  }) async {
    final code = _generateCode();
    final society = SocietyModel(
      societyCode: code,
      societyName: societyName,
      address: address,
      numOfFlats: numOfFlats,
      contactPerson: contactPerson,
      contactNumber: contactNumber,
      amenities: amenities,
      adminId: admin.uid,
    );
    await _db.child('${AppConstants.societies}/$code').set(society.toMap());
    await _db.child('${AppConstants.societyMembers(code)}/${admin.uid}').set({
      'username': admin.name,
      'role': AppConstants.roleAdmin,
      'flatNumber': '',
    });
    await _db.child('${AppConstants.users}/${admin.uid}').update({
      'role': AppConstants.roleAdmin,
      'societyCode': code,
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefRole, AppConstants.roleAdmin);
    await prefs.setString(AppConstants.prefSocietyCode, code);
    return code;
  }

  Future<void> joinSociety({
    required String societyCode,
    required UserModel user,
    required String flatNumber,
    required bool isWatchman,
  }) async {
    final snap = await _db.child('${AppConstants.societies}/$societyCode').get();
    if (!snap.exists) throw Exception('Society not found. Check the code.');

    // Filter client-side: a server-side orderByChild query would require an
    // ".indexOn" rule on /joinRequests in the database rules.
    final existing = await _db.child(AppConstants.joinRequests).get();
    if (existing.exists && existing.value is Map) {
      final hasPending = (existing.value as Map).values.any(
        (v) => v is Map && v['userId'] == user.uid,
      );
      if (hasPending) throw Exception('You already have a pending request.');
    }

    final reqRef = _db.child(AppConstants.joinRequests).push();
    await reqRef.set({
      'userId': user.uid,
      'societyId': societyCode,
      'userName': user.name,
      'role': isWatchman ? AppConstants.roleWatchman : AppConstants.roleMember,
      'flatNumber': isWatchman ? '' : flatNumber,
      'status': 'pending',
    });

    await _db.child('${AppConstants.users}/${user.uid}').update({
      'role': AppConstants.rolePending,
      'societyCode': societyCode,
      'flatNumber': isWatchman ? '' : flatNumber,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefRole, AppConstants.rolePending);
    await prefs.setString(AppConstants.prefSocietyCode, societyCode);
  }

  Future<SocietyModel?> getSociety(String code) async {
    final snap = await _db.child('${AppConstants.societies}/$code').get();
    if (!snap.exists) return null;
    return SocietyModel.fromMap(code, snap.value as Map);
  }

  Stream<String?> watchUserRole(String uid) {
    return _db
        .child('${AppConstants.users}/$uid/role')
        .onValue
        .map((e) => e.snapshot.value?.toString());
  }

  String _generateCode() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rng = Random();
    final chars = List.generate(3, (_) => letters[rng.nextInt(letters.length)]).join();
    final nums = (100 + rng.nextInt(900)).toString();
    return '$chars$nums';
  }
}
