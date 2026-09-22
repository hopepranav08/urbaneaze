import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/society_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final societyServiceProvider = Provider<SocietyService>((ref) => SocietyService());

// Holds the currently signed-in user (null = not logged in)
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>(
  (ref) => CurrentUserNotifier(ref.read(authServiceProvider)),
);

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  CurrentUserNotifier(this._auth) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthService _auth;

  Future<void> _init() async {
    try {
      final user = await _auth.getSessionUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _auth.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String occupancy,
    required String carNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _auth.register(
        name: name, email: email, password: password,
        phone: phone, occupancy: occupancy, carNumber: carNumber,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    state = const AsyncValue.data(null);
  }

  void updateUser(UserModel user) {
    state = AsyncValue.data(user);
  }
}
