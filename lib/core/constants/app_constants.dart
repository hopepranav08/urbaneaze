class AppConstants {
  AppConstants._();

  // Firebase DB paths
  static const users = 'users';
  static const societies = 'societies';
  static const joinRequests = 'joinRequests';

  static String societyMembers(String code) => '$societies/$code/members';
  static String societyFlats(String code) => '$societies/$code/flats';
  static String societyAnnouncements(String code) => '$societies/$code/announcements';
  static String societyComplaints(String code) => '$societies/$code/complaints';
  static String societyVisitorLogs(String code) => '$societies/$code/visitorLogs';
  static String societyPreApprovals(String code) => '$societies/$code/preApprovals';
  static String societyFacilityBookings(String code) => '$societies/$code/facility_bookings';
  static String societyCarRfidTags(String code) => '$societies/$code/carRFIDTags';
  static String societyCarLogs(String code) => '$societies/$code/carLogs';
  static String societyPayments(String code) => '$societies/$code/payments';
  static String societyDailyHelp(String code) => '$societies/$code/dailyHelp';
  static String societySecurityReports(String code) => '$societies/$code/securityReports';
  static String societyVendors(String code) => '$societies/$code/vendors';

  // SharedPreferences keys
  static const prefUserId = 'userId';
  static const prefRole = 'role';
  static const prefSocietyCode = 'societyCode';
  static const prefFlatNumber = 'flatNumber';
  static const prefUserName = 'userName';
  static const prefThemeMode = 'themeMode';

  // User roles
  static const roleAdmin = 'admin';
  static const roleMember = 'member';
  static const roleWatchman = 'watchman';
  static const rolePending = 'pending';

  // Visitor status
  static const statusPending = 'Pending';
  static const statusApproved = 'Approved';
  static const statusDenied = 'Denied';

  // Supabase
  static const supabaseUrl = 'https://emioewngkmxbnylxsaob.supabase.co';
  static const supabaseAnonKey = 'YOUR_SUPABASE_KEY';
  static const supabaseBucket = 'urbaneaze';
}
