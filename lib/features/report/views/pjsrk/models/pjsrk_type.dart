/// ============================================================================
/// ENUM & MODEL: PjsrkType
/// ============================================================================
/// Mengatur konfigurasi teks dan label formulir berdasarkan jenis layanan:
/// 1. Permasalahan Sosial
/// 2. Bencana Alam
/// 3. Rehabilitasi Sosial
///
/// Setiap jenis memiliki judul, label field, dan teks placeholder yang berbeda
/// sesuai dengan gambar referensi desain.
/// ============================================================================
enum PjsrkType {
  permasalahanSosial,
  bencanaAlam,
  rehabilitasiSosial,
}

extension PjsrkTypeExtension on PjsrkType {
  /// Subtitle di bawah judul "Form Laporan Cepat"
  String get subtitle {
    switch (this) {
      case PjsrkType.permasalahanSosial:
        return "Permasalahan Sosial";
      case PjsrkType.bencanaAlam:
        return "Bencana Alam";
      case PjsrkType.rehabilitasiSosial:
        return "Rehabilitasi Sosial";
    }
  }

  /// Label untuk field ke-4 (Jenis ...)
  String get jenisLabel {
    switch (this) {
      case PjsrkType.permasalahanSosial:
        return "Jenis Permasalahan Sosial";
      case PjsrkType.bencanaAlam:
        return "Jenis Bencana";
      case PjsrkType.rehabilitasiSosial:
        return "Jenis Rehabilitasi Sosial";
    }
  }

  /// Hint text untuk field ke-4
  String get jenisHint {
    switch (this) {
      case PjsrkType.permasalahanSosial:
        return "Masukkan Jenis Permasalahan";
      case PjsrkType.bencanaAlam:
        return "Masukkan Jenis Bencana";
      case PjsrkType.rehabilitasiSosial:
        return "Masukkan Jenis Laporan";
    }
  }

  /// Label untuk field ke-5 (Deskripsi ...)
  String get deskripsiLabel {
    switch (this) {
      case PjsrkType.permasalahanSosial:
        return "Deskripsi Permasalahan Sosial";
      case PjsrkType.bencanaAlam:
        return "Deskripsi Bencana Alam";
      case PjsrkType.rehabilitasiSosial:
        return "Deskripsi Rehabilitasi Sosial";
    }
  }

  /// Hint text untuk field ke-5
  String get deskripsiHint {
    switch (this) {
      case PjsrkType.permasalahanSosial:
        return "Ceritakan kondisi yang Anda lihat";
      case PjsrkType.bencanaAlam:
        return "Ceritakan kondisi bencana saat ini";
      case PjsrkType.rehabilitasiSosial:
        return "Ceritakan apa yang anda ketahui dan kondisi yang anda lihat";
    }
  }
}

