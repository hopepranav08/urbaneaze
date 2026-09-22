import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final snap = await _db.child('${AppConstants.users}/$uid').get();
    if (!snap.exists) throw Exception('User profile not found');
    final user = UserModel.fromMap(uid, snap.value as Map);
    await _saveSession(user);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String occupancy,
    required String carNumber,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final user = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      occupancy: occupancy,
      carNumber: carNumber.isEmpty ? 'NA' : carNumber.toUpperCase(),
      // No role until they create or join a society; 'pending' is reserved
      // for users awaiting admin approval of a join request.
      role: '',
    );
    await _db.child('${AppConstants.users}/$uid').set(user.toMap());
    await _saveSession(user);
    return user;
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefRole);
    await prefs.remove(AppConstants.prefSocietyCode);
    await prefs.remove(AppConstants.prefFlatNumber);
    await prefs.remove(AppConstants.prefUserName);
  }

  Future<UserModel?> getSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(AppConstants.prefUserId);
    if (uid == null || uid.isEmpty) return null;
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || currentUid != uid) return null;
    final snap = await _db.child('${AppConstants.users}/$uid').get();
    if (!snap.exists) return null;
    return UserModel.fromMap(uid, snap.value as Map);
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUserId, user.uid);
    await prefs.setString(AppConstants.prefRole, user.role);
    await prefs.setString(AppConstants.prefSocietyCode, user.societyCode);
    await prefs.setString(AppConstants.prefFlatNumber, user.flatNumber);
    await prefs.setString(AppConstants.prefUserName, user.name);
  }

  Future<void> updateSession(UserModel user) => _saveSession(user);
}
