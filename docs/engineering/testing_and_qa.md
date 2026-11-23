# SENTRA — Testing Strategy & E2E QA Checklist (Web ↔ Mobile)

> **Tujuan**: Memastikan setiap perbaikan pada Fase P0–P3 dan setiap perubahan fitur di masa depan bebas dari regresi, tersinkronisasi 100% antara Web Laravel dan Flutter Mobile, serta aman untuk deploy.

---

## 1. Piramida Pengujian Dual-Repo

| Layer Test | Flutter Mobile (`keloompok3C-Sentra-`) | Laravel Backend (`C:\Projects\Sentra`) | Perintah Eksekusi |
| :--- | :--- | :--- | :--- |
| **Static Analysis / Lint** | `flutter analyze` (0 error, tanpa warning baru) | `./vendor/bin/pint --test` (PSR-12) | `flutter analyze` / `composer test` |
| **Unit Tests** | Serialisasi JSON model (`UserModel`, `LaporanModel`, `Chat`, `Informasi`, `PjsrkRehabModel`), mapping status (`SentraStatusStyle`), `PjsrkPhotoUrls`, `ApiException`. | Helper enkripsi, pemetaan status, service validasi. | `flutter test test/unit/` |
| **Widget / Component Tests** | Komponen inti (`test/core_widgets_test.dart`), form validasi (`test/laporan_form_test.dart`, `test/pjsrk_test.dart`), state loading/empty/error. | Livewire component tests (`LivewirePanelTest.php`). | `flutter test` |
| **API Feature Tests** | Mock `Dio` adapter untuk `AuthSession`, `LaporanRepository`, `ChatRepository`, `PjsrkRepository`. | `php artisan test` mencakup `MobileChannelSecurityTest`, `ChatNotifikasiApiTest`, `DinsosAksesDanStatusTest`, `InformasiGambarApiTest`, `LaporanPpaRestoreVerifyTest`, plus test baru untuk P0 security & PJSRK endpoints. | `php artisan test` (di `C:\Projects\Sentra`) |
| **E2E Sync QA (Manual / Staging)** | Uji alur nyata pada perangkat Android/iOS melawan server staging HTTPS + WSS. | Uji panel Admin Web Dinsos/PPPA & Superadmin secara paralel dengan mobile. | Checklist Bagian 3 |

---

## 2. Perbaikan Test Bawaan yang Saat Ini Gagal

Saat audit terakhir, terdapat 2 file test bawaan Flutter yang perlu dibersihkan/diperbaiki agar `flutter test` 100% hijau sebagai *CI Quality Gate*:
1. `test/widget_test.dart`: Masih berisi template bawaan Flutter (`Counter increments smoke test` mencari teks `"0"`). **Tindakan**: Ganti dengan smoke test nyata `MyApp` / `StartupGate` atau hapus jika sudah tercakup `core_widgets_test.dart`.
2. `test/pjsrk_report_event_test.dart`: Menguji jam hardcoded `'09.30 WIB'` padahal controller memakai `DateTime.now()` (gagal jika dijalankan selain pukul 09.30!). **Tindakan**: Inject `DateTime` / clock ke `PjsrkReportEventController` agar deterministik di semua jam.

---

## 3. Matriks Pengujian Integrasi End-to-End (Web ↔ Mobile)

Setiap rilis wajib lulus seluruh skenario sinkronisasi berikut secara berurutan:

### A. Autentikasi & Sesi
- [ ] **Daftar akun baru** di Mobile → akun muncul di panel Superadmin Web (`role = user`, `is_active = 1`).
- [ ] **Daftar nomor duplikat** → ditolak `422` dengan pesan ramah (bukan `500` SQL error).
- [ ] **Login** → menerima token Sanctum, tersimpan di `FlutterSecureStorage`, restart aplikasi tetap login via `GET /api/user`.
- [ ] **Admin menonaktifkan akun di Web** → saat Mobile dibuka/refresh, API menjawab `401/403` dan Mobile otomatis logout ke `LoginPage`.
- [ ] **Ubah Profil** di Mobile → perubahan nama/alamat/email langsung tampil di Web Admin.
- [ ] **Ubah Profil akun orang lain** (ID berbeda dari token) → ditolak `403 Forbidden`.

### B. Alur Pelaporan PPPA (Lengkap & Cepat)
- [ ] **Kirim Laporan PPPA** (Pelapor, Penerima Manfaat, Terlapor opsional, Informasi Anak opsional, Kronologi, Waktu & Lokasi) → tersimpan di Web Admin PPPA dengan data NIK & nomor telepon terdekripsi dengan benar.
- [ ] **Kirim Laporan Cepat tanpa login** → masuk ke Web Admin di bawah akun `guest`, mengembalikan nomor tiket valid.
- [ ] **Ubah status di Web Admin** (`dikirim` → `diterima` → `diproses` → `selesai` / `ditolak` / `dirujuk`) →
  - Status di **Tracking** & **Riwayat Mobile** langsung berubah sesuai enum.
  - **Notifikasi in-app** & **FCM Push Notification** masuk ke perangkat pelapor dengan ikon & warna status yang tepat.

### C. Alur Layanan PJSRK (Bencana, Rehabilitasi, Permasalahan Sosial, Cepat)
- [ ] **Pengaduan Bencana (3 langkah + maks 4 foto)** → muncul di Admin Web Dinsos lengkap dengan koordinat peta, kebutuhan mendesak, dan seluruh foto dapat dibuka di Web maupun di Detail Laporan Mobile.
- [ ] **Rehabilitasi Sosial (+ foto + toggle rahasia)** → muncul di Admin Web Dinsos dengan flag `rahasia` sesuai input.
- [ ] **Permasalahan Sosial (+ foto + lokasi peta)** → muncul di Admin Web Dinsos dengan judul & uraian sebagai kronologi.
- [ ] **Riwayat & Detail PJSRK** di Mobile hanya menampilkan laporan PJSRK milik akun yang login (tidak tercampur PPPA dan tidak bisa mengakses akun lain).

### D. Chat Konsultasi Realtime & Informasi
- [ ] **Mobile kirim pesan** → langsung muncul realtime di panel Chat Web Admin (dan sebaliknya) tanpa duplikasi pesan.
- [ ] **Indikator mengetik (`typing`)**, **edit pesan**, **hapus pesan**, dan **mark as read** tersinkronisasi di kedua sisi.
- [ ] **Koneksi terputus lalu pulih** → WebSocket otomatis reconnect satu koneksi saja (tidak ada pesan ganda) dan mengambil pesan yang terlewat via `GET /api/chats/{userId}`.
- [ ] **Admin Web menerbitkan Informasi baru + gambar** → langsung muncul di urutan teratas Informasi Terkini di Mobile dan gambar termuat via `/api/informasi/{id}/gambar`.

### E. Kondisi Jaringan & Edge Cases
- [ ] **Mode Pesawat / Offline**: Tidak ada crash; layar Riwayat, Informasi, dan Detail menampilkan state error yang ramah + tombol *Coba Lagi*.
- [ ] **Timeout / Server 500**: Tidak menampilkan pesan teknis/stacktrace/SQL ke pengguna.
- [ ] **Ketukan ganda (*double tap*)** pada semua tombol kirim laporan/login/simpan profil dicegah oleh `isLoading`.
