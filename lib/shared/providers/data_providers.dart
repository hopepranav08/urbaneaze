import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/data_service.dart';
import '../models/announcement_model.dart';
import '../models/complaint_model.dart';
import '../models/facility_booking_model.dart';
import '../models/visitor_model.dart';
import 'auth_provider.dart';

final dataServiceProvider = Provider<DataService>((ref) => DataService());

/// Society code of the signed-in user ('' while logged out / loading).
final societyCodeProvider = Provider<String>((ref) {
  return ref.watch(currentUserProvider).value?.societyCode ?? '';
});

Stream<List<T>> _empty<T>() => Stream.value(<T>[]);

final visitorsProvider = StreamProvider<List<VisitorModel>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchVisitors(code);
});

final announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchAnnouncements(code);
});

final complaintsProvider = StreamProvider<List<ComplaintModel>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchComplaints(code);
});

final bookingsProvider = StreamProvider<List<FacilityBookingModel>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchBookings(code);
});

final joinRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchJoinRequests(code);
});

final membersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchMembers(code);
});

final carLogsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchCarLogs(code);
});

final securityReportsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchSecurityReports(code);
});

final preApprovalsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final code = ref.watch(societyCodeProvider);
  final uid = ref.watch(currentUserProvider).value?.uid;
  if (code.isEmpty || uid == null) return _empty();
  return ref.watch(dataServiceProvider).watchPreApprovals(code, residentId: uid);
});

final sosAlertsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return _empty();
  return ref.watch(dataServiceProvider).watchSos(code);
});

final societyProvider = FutureProvider((ref) {
  final code = ref.watch(societyCodeProvider);
  if (code.isEmpty) return Future.value(null);
  return ref.watch(societyServiceProvider).getSociety(code);
});
