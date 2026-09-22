import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../../shared/models/announcement_model.dart';
import '../../shared/models/complaint_model.dart';
import '../../shared/models/facility_booking_model.dart';
import '../../shared/models/visitor_model.dart';
import '../constants/app_constants.dart';

/// All society-scoped feature data (visitors, announcements, complaints,
/// bookings, members, logs) against Firebase Realtime DB.
class DataService {
  final _db = FirebaseDatabase.instance.ref();

  // ── helpers ─────────────────────────────────────────────────────────
  List<MapEntry<String, Map>> _entries(DataSnapshot snap) {
    if (!snap.exists || snap.value is! Map) return [];
    return (snap.value as Map)
        .entries
        .where((e) => e.value is Map)
        .map((e) => MapEntry(e.key.toString(), e.value as Map))
        .toList();
  }

  Stream<List<T>> _watchList<T>(
    String path,
    T Function(String id, Map map) fromMap, {
    int Function(T, T)? sort,
  }) {
    return _db.child(path).onValue.map((event) {
      final list = _entries(event.snapshot).map((e) => fromMap(e.key, e.value)).toList();
      if (sort != null) list.sort(sort);
      return list;
    });
  }

  // ── Visitors ────────────────────────────────────────────────────────
  Stream<List<VisitorModel>> watchVisitors(String society) => _watchList(
        AppConstants.societyVisitorLogs(society),
        VisitorModel.fromMap,
        sort: (a, b) => b.timestamp.compareTo(a.timestamp),
      );

  Future<void> setVisitorStatus(String society, String visitorId, String status, String residentId) {
    return _db.child('${AppConstants.societyVisitorLogs(society)}/$visitorId').update({
      'status': status,
      'residentId': residentId,
    });
  }

  Future<void> addVisitor(String society, VisitorModel visitor) {
    return _db.child(AppConstants.societyVisitorLogs(society)).push().set(visitor.toMap());
  }

  Future<void> markVisitorExit(String society, String visitorId) {
    return _db.child('${AppConstants.societyVisitorLogs(society)}/$visitorId').update({
      'exitTimestamp': ServerValue.timestamp,
    });
  }

  // ── Pre-approvals ───────────────────────────────────────────────────
  Future<String> createPreApproval(String society, Map<String, dynamic> data) async {
    final otp = (100000 + Random().nextInt(900000)).toString();
    await _db.child(AppConstants.societyPreApprovals(society)).push().set({
      ...data,
      'otp': otp,
      'isUsed': false,
      'createdAt': ServerValue.timestamp,
    });
    return otp;
  }

  Stream<List<Map<String, dynamic>>> watchPreApprovals(String society, {String? residentId}) {
    return _db.child(AppConstants.societyPreApprovals(society)).onValue.map((event) {
      var items = _entries(event.snapshot)
          .map((e) => <String, dynamic>{'id': e.key, ...e.value.map((k, v) => MapEntry(k.toString(), v))})
          .toList();
      if (residentId != null) {
        items = items.where((m) => m['residentId'] == residentId).toList();
      }
      items.sort((a, b) => ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num));
      return items;
    });
  }

  /// Guard-side: check an OTP. Returns the pre-approval entry if valid.
  Future<Map<String, dynamic>?> redeemOtp(String society, String otp) async {
    final snap = await _db.child(AppConstants.societyPreApprovals(society)).get();
    for (final e in _entries(snap)) {
      if (e.value['otp'] == otp && e.value['isUsed'] != true) {
        await _db.child('${AppConstants.societyPreApprovals(society)}/${e.key}').update({'isUsed': true});
        return {'id': e.key, ...e.value.map((k, v) => MapEntry(k.toString(), v))};
      }
    }
    return null;
  }

  Future<void> deletePreApproval(String society, String id) =>
      _db.child('${AppConstants.societyPreApprovals(society)}/$id').remove();

  // ── Announcements ───────────────────────────────────────────────────
  Stream<List<AnnouncementModel>> watchAnnouncements(String society) => _watchList(
        AppConstants.societyAnnouncements(society),
        AnnouncementModel.fromMap,
        sort: (a, b) => b.timestamp.compareTo(a.timestamp),
      );

  Future<void> postAnnouncement(String society, String text, String postedBy,
      {String fileUrl = '', String fileType = ''}) {
    return _db.child(AppConstants.societyAnnouncements(society)).push().set({
      'text': text,
      'postedBy': postedBy,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> deleteAnnouncement(String society, String id) =>
      _db.child('${AppConstants.societyAnnouncements(society)}/$id').remove();

  // ── Complaints ──────────────────────────────────────────────────────
  Stream<List<ComplaintModel>> watchComplaints(String society) => _watchList(
        AppConstants.societyComplaints(society),
        ComplaintModel.fromMap,
        sort: (a, b) => b.timestamp.compareTo(a.timestamp),
      );

  Future<void> fileComplaint(String society, ComplaintModel complaint) {
    return _db.child(AppConstants.societyComplaints(society)).push().set({
      ...complaint.toMap(),
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> setComplaintStatus(String society, String id, String status) =>
      _db.child('${AppConstants.societyComplaints(society)}/$id').update({'status': status});

  // ── Facility bookings ───────────────────────────────────────────────
  Stream<List<FacilityBookingModel>> watchBookings(String society) => _watchList(
        AppConstants.societyFacilityBookings(society),
        FacilityBookingModel.fromMap,
        sort: (a, b) => a.startTime.compareTo(b.startTime),
      );

  Future<void> addBooking(String society, Map<String, dynamic> data) =>
      _db.child(AppConstants.societyFacilityBookings(society)).push().set(data);

  Future<void> cancelBooking(String society, String id) =>
      _db.child('${AppConstants.societyFacilityBookings(society)}/$id').remove();

  // ── Join requests (admin) ───────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchJoinRequests(String society) {
    return _db.child(AppConstants.joinRequests).onValue.map((event) {
      return _entries(event.snapshot)
          .where((e) => e.value['societyId'] == society && e.value['status'] == 'pending')
          .map((e) => <String, dynamic>{'id': e.key, ...e.value.map((k, v) => MapEntry(k.toString(), v))})
          .toList();
    });
  }

  Future<void> approveJoinRequest(String society, Map<String, dynamic> req) async {
    final userId = req['userId'] as String;
    final role = req['role'] as String;
    await _db.child('${AppConstants.societyMembers(society)}/$userId').set({
      'username': req['userName'],
      'role': role,
      'flatNumber': req['flatNumber'] ?? '',
    });
    await _db.child('${AppConstants.users}/$userId').update({'role': role});
    await _db.child('${AppConstants.joinRequests}/${req['id']}').remove();
  }

  Future<void> rejectJoinRequest(Map<String, dynamic> req) async {
    await _db.child('${AppConstants.users}/${req['userId']}').update({
      'role': '',
      'societyCode': '',
      'flatNumber': '',
    });
    await _db.child('${AppConstants.joinRequests}/${req['id']}').remove();
  }

  // ── Members ─────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchMembers(String society) {
    return _db.child(AppConstants.societyMembers(society)).onValue.map((event) {
      final list = _entries(event.snapshot)
          .map((e) => <String, dynamic>{'id': e.key, ...e.value.map((k, v) => MapEntry(k.toString(), v))})
          .toList();
      list.sort((a, b) => (a['username'] ?? '').toString().compareTo((b['username'] ?? '').toString()));
      return list;
    });
  }

  Future<void> removeMember(String society, String userId) async {
    await _db.child('${AppConstants.societyMembers(society)}/$userId').remove();
    await _db.child('${AppConstants.users}/$userId').update({
      'role': '',
      'societyCode': '',
      'flatNumber': '',
    });
  }

  // ── Car logs / RFID ─────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchCarLogs(String society) {
    return _db.child(AppConstants.societyCarLogs(society)).onValue.map((event) {
      final list = _entries(event.snapshot)
          .map((e) => <String, dynamic>{'id': e.key, ...e.value.map((k, v) => MapEntry(k.toString(), v))})
          .toList();
      list.sort((a, b) => ((b['timestamp'] ?? 0) as num).compareTo((a['timestamp'] ?? 0) as num));
      return list;
    });
  }

  Future<void> addCarLog(String society, Map<String, dynamic> data) =>
      _db.child(AppConstants.societyCarLogs(society)).push().set({
        ...data,
        'timestamp': ServerValue.timestamp,
      });

  Future<Map<String, dynamic>?> lookupRfid(String society, String tag) async {
    final snap = await _db.child('${AppConstants.societyCarRfidTags(society)}/$tag').get();
    if (!snap.exists || snap.value is! Map) return null;
    return (snap.value as Map).map((k, v) => MapEntry(k.toString(), v));
  }

  Future<void> assignRfid(String society, String tag, Map<String, dynamic> data) =>
      _db.child('${AppConstants.societyCarRfidTags(society)}/$tag').set(data);

  // ── Security reports ────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchSecurityReports(String society) {
    return _db.child(AppConstants.societySecurityReports(society)).onValue.map((event) {
      final list = _entries(event.snapshot)
          .map((e) => <String, dynamic>{'id': e.key, ...e.value.map((k, v) => MapEntry(k.toString(), v))})
          .toList();
      list.sort((a, b) => ((b['timestamp'] ?? 0) as num).compareTo((a['timestamp'] ?? 0) as num));
      return list;
    });
  }

  Future<void> addSecurityReport(String society, Map<String, dynamic> data) =>
      _db.child(AppConstants.societySecurityReports(society)).push().set({
        ...data,
        'timestamp': ServerValue.timestamp,
      });

  // ── SOS ─────────────────────────────────────────────────────────────
  Future<void> raiseSos(String society, Map<String, dynamic> data) =>
      _db.child('${AppConstants.societies}/$society/sosAlerts').push().set({
        ...data,
        'timestamp': ServerValue.timestamp,
      });

  Stream<List<Map<String, dynamic>>> watchSos(String society) {
    return _db.child('${AppConstants.societies}/$society/sosAlerts').onValue.map((event) {
      final list = _entries(event.snapshot)
          .map((e) => <String, dynamic>{'id': e.key, ...e.value.map((k, v) => MapEntry(k.toString(), v))})
          .toList();
      list.sort((a, b) => ((b['timestamp'] ?? 0) as num).compareTo((a['timestamp'] ?? 0) as num));
      return list;
    });
  }
}
