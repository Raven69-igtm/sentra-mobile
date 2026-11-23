class Endpoints {
  // Autentikasi & Akun
  static const String currentUser = "/user";
  static const String login = "/auth/login";
  static const String biometric = "/auth/biometric";
  static const String register = "/auth/register";
  static const String editProfile = "/auth/edit";
  static const String deleteAccount = "/auth/delete";
  static const String updatenomor = "/auth/updatenomor";
  static const String ubahpassword = "/auth/ubahpassword";
  static const String emergencyQuestion = "/auth/get-emergency-question";
  static const String emergencyCheck = "/auth/emergency-check";
  static const String forgotPassword = "/forgot-password";
  static const String resetPassword = "/reset-password";

  // Laporan PPA & Riwayat
  static const String postReport = "/post-report";
  static const String laporanCepat = "/laporan-cepat";
  static const String trackReport = "/track-report";
  static const String reportStatistics = "/report-statistics";
  static const String userReports = "/user-reports";
  static const String userReportsByCategory = "/user-reports-by-category";
  static const String searchReports = "/search";

  // PJSRK
  static const String pjsrkBencana = "/pjsrk/bencana";
  static const String pjsrkRehabilitasi = "/pjsrk/rehabilitasi";
  static const String pjsrkPermasalahanSosial = "/pjsrk/permasalahan-sosial";
  static const String pjsrkCepat = "/pjsrk/cepat";

  // Notifikasi & FCM
  static const String notifications = "/notifications";
  static const String notificationsRestore = "/notifications/restore";
  static const String updateFcmToken = "/update-fcm-token";
  static const String newMessageNotif = "/new-message";
  static const String reportUpdateNotif = "/report-update";

  // Chat & Informasi
  static const String chats = "/chats";
  static const String chatUpdate = "/chat/update";
  static const String chatDelete = "/chat/delete";
  static const String conversations = "/conversations";
  static const String informasi = "/informasi";
}
