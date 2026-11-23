# SENTRA — Production Deployment Readiness Checklist (Web + WebSocket + Mobile)

> **Tujuan**: Panduan operasional dan daftar periksa wajib sebelum men-deploy backend **Laravel (`C:\Projects\Sentra`)**, server **WebSocket (`websocket-server.cjs`)**, dan aplikasi **Flutter (`C:\Projects\keloompok3C-Sentra-`)** ke lingkungan produksi.

---

## 1. Hygiene Repositori (Wajib Dibersihkan Sebelum Deploy)

### A. Backend (`C:\Projects\Sentra`)
Hapus atau pindahkan keluar dari direktori produksi (jangan ikut ter-deploy ke server!):
- [ ] `check_admin.php` (script debug di root)
- [ ] `fix_accounts.php` (script perbaikan manual di root)
- [ ] `tests/superadmin_check.php`
- [ ] `sentra_2026-11-11_pre_waktu_kejadian.sql` (backup SQL — pindahkan ke storage backup privat terenkripsi!)
- [ ] `fashion_marketplace_graph_db*.drawio` (file tidak terkait proyek SENTRA)
- [ ] `rmdir` (file kosong nyasar di root)
- [ ] Pastikan `.env`, `storage/logs/*.log`, dan file kredensial Firebase service account JSON **tidak pernah** masuk Git dan berada di luar `public/`.

### B. Mobile (`C:\Projects\keloompok3C-Sentra-`)
- [ ] Hapus file sementara di root: `tool_edit_login.js`, `pjsrk_out.txt`.
- [ ] Pastikan `.env` (berisi `FONNTE_API_KEY`, `MAPBOX_ACCESS_TOKEN`) tidak berisi secret server-side yang tidak seharusnya ada di APK (APK dapat di-decompile — secret sensitif wajib hanya hidup di server Laravel!).

---

## 2. Kesiapan Deploy Web & Laravel API (`C:\Projects\Sentra`)

### 2.1 Environment & Konfigurasi (`.env` Produksi)
- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false` *(wajib agar stacktrace & kredensial tidak pernah tampil)*
- [ ] `APP_URL=https://<domain-resmi-sentra>`
- [ ] `APP_KEY` unik produksi (tersimpan aman — **jangan ganti sembarangan** karena kolom NIK & no_telp memakai `Crypt::encryptString` berbasis `APP_KEY`!).
- [ ] `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` memakai user MySQL khusus dengan hak akses minimum (*least privilege*), **bukan** `root/root`.
- [ ] Konfigurasi `FIREBASE_CREDENTIALS` & `FIREBASE_PROJECT_ID` melalui `config/services.php` (hapus hardcode `sentra-3e7a6` di `NotificationControllerMobile.php`).

### 2.2 Keamanan Laravel
- [ ] **`config/cors.php`**: Ganti `'allowed_origins' => ['*']` menjadi daftar domain resmi web & origin yang diizinkan via `env('CORS_ALLOWED_ORIGINS')`.
- [ ] **`config/sanctum.php`**: Set `'expiration'` (mis. `43200` = 30 hari) alih-alih `null`, serta konfigurasi `SANCTUM_STATEFUL_DOMAINS` sesuai domain produksi.
- [ ] **Rate Limiting (`throttle`)**: Pasang throttle pada `/api/auth/login`, `/api/auth/register`, `/api/auth/emergency-check`, `/api/laporan-cepat`, `/api/pjsrk/cepat`, dan `/api/track-report`.
- [ ] **HTTPS Forced**: Redirect seluruh HTTP → HTTPS di Nginx/Apache dan aktifkan header keamanan (`Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`).

### 2.3 Perintah Build & Optimasi Server Produksi
```bash
composer install --no-dev --optimize-autoloader
npm ci && npm run build
php artisan migrate --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
```
- [ ] Pastikan direktori `storage/` dan `bootstrap/cache/` serta `public/uploads/` memiliki permission write yang tepat untuk user web server (`www-data`).
- [ ] Aktifkan **cron scheduler** (`* * * * * php artisan schedule:run`) dan **queue worker** (Supervisor) untuk pengiriman FCM & audit retention.
- [ ] Aktifkan backup otomatis harian database MySQL + folder `public/uploads/` (foto bukti laporan & informasi).

---

## 3. Kesiapan Deploy WebSocket Server (`websocket-server.cjs`)

- [ ] **Wajib TLS (`wss://`)**: Jangan ekspos `ws://18.136.209.83:3021` langsung ke publik! Jalankan `websocket-server.cjs` lokal di `127.0.0.1:3021` di belakang **Nginx Reverse Proxy** dengan sertifikat SSL (Let's Encrypt) pada subdomain seperti `wss://ws.<domain-resmi-sentra>`:
  ```nginx
  location / {
      proxy_pass http://127.0.0.1:3021;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "Upgrade";
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_read_timeout 86400;
  }
  ```
- [ ] **Process Manager (PM2 / systemd)**: Jalankan dengan auto-restart & log rotation (`pm2 start websocket-server.cjs --name sentra-ws && pm2 save && pm2 startup`).
- [ ] **Firewall**: Tutup port `3021` dari akses publik luar (hanya port `80`/`443` terbuka).
- [ ] **Autentikasi Koneksi**: Pastikan P0-03 (verifikasi token Sanctum + kepemilikan `sender_id`) sudah diterapkan sebelum go-live.

---

## 4. Kesiapan Deploy Flutter Mobile (`C:\Projects\keloompok3C-Sentra-`)

### 4.1 Android (`android/app/build.gradle.kts` & `AndroidManifest.xml`)
- [ ] **Application ID Unik**: Ganti `com.example.sentra_mobile` di `build.gradle.kts` (dan samakan di Firebase Console + `google-services.json` baru) menjadi ID resmi, misalnya `id.go.nganjukkab.sentra`.
- [ ] **Target SDK**: Naikkan `targetSdk` dari `33` menjadi **`35`** sesuai syarat Google Play Store.
- [ ] **Release Signing**: Buat `upload-keystore.jks` (simpan aman + backup), konfigurasi `android/key.properties` (di-`.gitignore`), dan ganti `signingConfig = signingConfigs.getByName("debug")` di `buildTypes.release` menjadi `signingConfigs.getByName("release")`.
- [ ] **Minify / Shrink**: Aktifkan `isMinifyEnabled = true` & `isShrinkResources = true` dengan aturan ProGuard yang teruji untuk Firebase, Maps, dan Dio.
- [ ] **Network Security**: Matikan `usesCleartextTraffic` pada build release (karena API sudah `https://` dan WebSocket sudah `wss://`).
- [ ] **Permissions Audit**: Pastikan izin lokasi (`ACCESS_FINE_LOCATION`), kamera, galeri, dan notifikasi (`POST_NOTIFICATIONS` Android 13+) memiliki penjelasan ramah pengguna.

### 4.2 iOS (Jika Rilis App Store)
- [ ] Samakan `Bundle Identifier` dengan konfigurasi Firebase (`GoogleService-Info.plist`) & Apple Developer Portal.
- [ ] Lengkapi deskripsi izin di `ios/Runner/Info.plist` (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSLocationWhenInUseUsageDescription`).
- [ ] Aktifkan *Push Notifications* & *Background Modes (Remote notifications)* di Xcode + unggah APNs Key `.p8` ke Firebase Console.

### 4.3 Perintah Build Release (Tanpa Hardcode URL)
Gunakan `--dart-define` agar tidak perlu mengedit kode antara Staging dan Production:

```bash
# Android App Bundle (.aab untuk Google Play Store)
flutter build appbundle --release \
  --dart-define=SENTRA_IS_LOCAL=false \
  --dart-define=SENTRA_API_ORIGIN=https://<domain-resmi-sentra> \
  --dart-define=SENTRA_WS_URL=wss://ws.<domain-resmi-sentra>

# Android APK Release (distribusi internal / QA)
flutter build apk --release \
  --dart-define=SENTRA_IS_LOCAL=false \
  --dart-define=SENTRA_API_ORIGIN=https://<domain-resmi-sentra> \
  --dart-define=SENTRA_WS_URL=wss://ws.<domain-resmi-sentra>
```
- [ ] Pastikan `DevicePreview(enabled: !kReleaseMode)` di `lib/main.dart` otomatis nonaktif di `--release`.
- [ ] Naikkan `version: X.Y.Z+BUILD` di `pubspec.yaml` pada setiap rilis baru.

---

## 5. Gerbang Go / No-Go Sebelum Rilis Publik

Rilis **DILARANG** lanjut (*No-Go*) jika salah satu syarat berikut belum terpenuhi:
1. Semua temuan **P0** di `sync_audit.md` (P0-01 s/d P0-06) sudah selesai & terverifikasi.
2. `flutter analyze` = 0 error, `flutter test` = 100% lulus, `php artisan test` = 100% lulus.
3. Seluruh trafik produksi berjalan di **HTTPS + WSS** (nol HTTP/WS polos, nol IP mentah).
4. Backup database & rencana rollback sudah diuji di server produksi.
