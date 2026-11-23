# SENTRA — API & Realtime Contract (Mobile ↔ Web Laravel)

> **Sumber Kebenaran Backend**: `C:\Projects\Sentra\routes\api.php` & `C:\Projects\Sentra\websocket-server.cjs`  
> **Sumber Kebenaran Mobile**: `lib/core/network/api_client.dart` & `lib/core/network/endpoints.dart`  
> **Base URL**: `{SENTRA_API_ORIGIN}/api` (Header wajib: `Accept: application/json`, dan `Authorization: Bearer <sanctum_token>` untuk endpoint terproteksi).

---

## 1. Konvensi Global & Enum Status Tunggal

Seluruh fitur (Web Admin Dinsos/PPPA, Tracking, Riwayat, Detail, dan Notifikasi Mobile) **wajib** memakai tabel enum status yang sama:

| Nilai DB / API (`status`) | Label UI Mobile | Warna Status (`AppColors`) | Catatan Sinkronisasi |
| :--- | :--- | :--- | :--- |
| `dikirim` | Terkirim | Warning (`#B45309` / `#FEF3C7`) | Status awal semua laporan baru. |
| `diterima` | Diterima | Info (`#1D4ED8` / `#DBEAFE`) | Sudah diverifikasi petugas. |
| `diproses` | Diproses | Orange (`#C2410C` / `#FFEDD5`) | Sedang ditindaklanjuti / survei lapangan. |
| `selesai` | Selesai | Success (`#15803D` / `#DCFCE7`) | Penanganan selesai. |
| `ditolak` | Ditolak | Error (`#B42318` / `#FEE2E2`) | Wajib ditambahkan ke validasi `reportUpdate` di backend! |
| `dirujuk` | Dirujuk | Info (`#1D4ED8` / `#DBEAFE`) | Khusus kasus rujukan PPPA (`TrackingLaporan` dialog). |

### Enum `layanan_pjsrk`
- `pengaduan_bencana`
- `rehabilitasi_sosial`
- `permasalahan_sosial`
- `null` → Laporan PPPA.

---

## 2. Matriks Endpoint REST API (`routes/api.php`)

### 2.1 Autentikasi & Akun (`AkunControllerMobile`)
| Method & Path | Auth Saat Ini | Auth Target (Production) | Request Payload / Params | Respons & Catatan |
| :--- | :---: | :---: | :--- | :--- |
| `POST /api/auth/register` | Publik | Publik (+ throttle) | `notelp`, `nama`, `password`, `emerquest?`, `answquest?`, `gender?`, `alamat?` | `201 { success, message, data: { id_akun, laporan_updated } }`. Wajib tambah `unique:akun,notelp`. |
| `POST /api/auth/login` | Publik | Publik (+ throttle) | `notelp`, `password` | `200 { message, user, token }`. Role dibatasi `Akun::MOBILE_ROLES` & `is_active = true`. |
| `GET /api/user` | **Sanctum** | **Sanctum** | — | `200 UserMobile`. **Target utama untuk `AuthSession.restore()` & `refreshProfile()`**. |
| `PUT /api/auth/edit/{id}` | **Sanctum** | **Sanctum** (+ owner check) | `notelp?`, `nama?`, `email?`, `jenis_kelamin?`, `alamat?`, `password?` | Role tidak bisa diubah klien. |
| `DELETE /api/auth/delete/{id}` | **Sanctum** | **Sanctum** (+ owner check) | — | Hapus akun sendiri. |
| `POST /api/auth/updatenomor` | **Sanctum** | **Sanctum** | Payload ganti nomor | Wajib terikat dengan OTP terverifikasi di server. |
| `POST /api/auth/ubahpassword` | **Sanctum** | **Sanctum** | Payload ubah password | Wajib cek password lama / token reset server. |
| `POST /api/auth/get-emergency-question` | Publik | Publik (+ throttle) | `notelp` | `200 { success, emerquest }`. |
| `POST /api/auth/emergency-check` | Publik | Publik (+ throttle) | `notelp`, `answer` | Harus mengembalikan token reset sementara (bukan hanya 200 tanpa state). |
| `POST /api/auth/biometric` | Publik | **NONAKTIFKAN / GANTI** | Saat ini hanya `notelp`! | **P0 Security Blocker**: ganti alur restore sesi ke `GET /api/user` + Sanctum token. |
| `POST /api/auth/email` | Publik | **VERIFIKASI ID TOKEN** | Saat ini hanya `email`! | **P0 Security Blocker**: wajib verifikasi Firebase/Google ID Token sebelum menerbitkan Sanctum token. |
| `GET /api/auth/getdata` | Publik | **HAPUS / ADMIN ONLY** | — | **P0 Data Leak**: membocorkan seluruh data akun ke publik. |
| `POST /api/login`, `/register`, `/forgot-password`, `/reset-password` | Publik | **HAPUS DUPLIKAT** | `AuthControllerMobile` | Duplikat dengan `/api/auth/*`; konsolidasikan ke satu set endpoint. |

---

### 2.2 Laporan PPPA, Riwayat, Pencarian & Tracking (`LaporanControllerMobile`)
| Method & Path | Auth Saat Ini | Auth Target | Request Payload / Params | Catatan Kontrak |
| :--- | :---: | :---: | :--- | :--- |
| `POST /api/post-report` | Publik | **Sanctum** | `id_akun` (ambil dari token), `kategori`, `status`, `judul?`, `kecamatan?`, `layanan_pjsrk?`, `detail_pelapor`, `detail_penerima_manfaat`, `detail_terlapor?`, `detail_kasus`, `informasi_anak?` | Perhatikan key sensitif: `detail_penerima_manfaat.Tempat_lahir` (huruf besar `T` di backend saat ini — wajib distandarkan dengan fallback `tempat_lahir`). |
| `POST /api/laporan-cepat` | Publik | Publik (+ throttle) | `id_akun?`, `nik`, `nama`, `no_telp`, `alamat`, `deskripsi` | Tanpa login otomatis diatribusikan ke akun `guest`. |
| `POST /api/track-report` | Publik | Publik (+ throttle) | `id_laporan` | `200 { message, status, laporan }`. Periksa field sensitif korban agar tidak terbuka berlebihan ke publik tanpa autentikasi! |
| `GET /api/user-reports/{id_akun}` | Publik | **Sanctum** (+ owner check) | Path `id_akun` | `200 { message, laporan: [...] }` (termasuk `detail_pjsrk`, `detail_kasus`, `detail_penerima_manfaat`). |
| `GET /api/user-reports-by-category/{id_akun}/{status}` | Publik | **Sanctum** (+ owner check) | Path `id_akun`, `status` | Filter berdasarkan kolom `status`. |
| `GET /api/search` | Publik | **Sanctum** (+ owner check) | Query `keyword`/`query`, `id_akun` | Jangan izinkan mencari laporan milik `id_akun` lain. |
| `GET /api/report-statistics` | Publik | Publik (cache 5 menit) | — | `200 { message, data: { "Jan": { "Kategori": count } } }`. |

---

### 2.3 Layanan PJSRK (`PjsrkControllerMobile`)
Semua endpoint upload foto memakai **`multipart/form-data`**, field `foto[]` (maksimal **4 file**, format `jpeg,png,jpg,webp`, maks **5 MB/file**).

| Method & Path | Auth Saat Ini | Auth Target | Payload Wajib |
| :--- | :---: | :---: | :--- |
| `POST /api/pjsrk/bencana` | Publik | **Sanctum** | `id_akun`, `jenis_bencana`, `waktu_kejadian` (ISO/date), `tingkat_dampak` (`Ringan\|Sedang\|Berat`), `jiwa_terdampak`, `rumah_rusak`, `keterangan`, `kebutuhan_mendesak[]` (min 1), `alamat`, `kelurahan`, `kecamatan`, `patokan_lokasi?`, `latitude`, `longitude`, `kontak`, `foto[]?` |
| `POST /api/pjsrk/rehabilitasi` | Publik | **Sanctum** | `id_akun`, `jenis_rehabilitasi` (`Tunawisma\|Anak Terlantar`), `jumlah_penerima` (min 1), `jenis_kelamin` (`Laki-laki\|Perempuan\|Campuran`), `kelompok_usia` (`Dewasa\|Lansia\|Bersama anak`), `kondisi_saat_ditemukan` (`Sehat\|Sakit\|Gangguan jiwa`), `ciri_ciri`, `rahasia` (bool), `alamat`, `latitude?`, `longitude?`, `kontak`, `foto[]?` |
| `POST /api/pjsrk/permasalahan-sosial` | Publik | **Sanctum** | `id_akun`, `jenis_permasalahan`, `judul`, `uraian`, `alamat`, `kelurahan?`, `kecamatan?`, `latitude?`, `longitude?`, `rahasia` (bool), `kontak?`, `foto[]?` |
| `POST /api/pjsrk/cepat` | Publik | Publik (+ throttle) | `id_akun?`, `layanan` (`pengaduan_bencana\|rehabilitasi_sosial\|permasalahan_sosial`), `nama`, `telepon`, `lokasi`, `jenis`, `deskripsi` |

> **Respons Standar PJSRK (`201`)**: `{ "success": true, "message": "...", "data": { "id_laporan": "<id>" } }`.  
> **Resolusi URL Foto**: Mobile memakai `PjsrkPhotoUrls.resolve(detailPjsrk, idLaporan: id)` dan `InformasiImageUrls` agar host `localhost`/`127.0.0.1` otomatis menyesuaikan `ApiClient.apiOrigin`.

---

### 2.4 Chat Konsultasi (`ChatControllerMobile` — Sudah `auth:sanctum`)
| Method & Path | Request | Respons |
| :--- | :--- | :--- |
| `POST /api/chats` | `{ receiver_id, message, replied_to_id? }` (`sender_id` diambil dari token) | `201 ChatMobile` + otomatis memicu FCM `newMessage`. |
| `GET /api/chats/{userId}` | Query opsional `other_user_id` (`userId` wajib == token user) | `200 ChatMobile[]` urut `sent_at ASC`. |
| `GET /api/conversations/{userId}` | Path `userId` wajib == token user | `200 [{ user_id, name, last_message, time, is_online }]`. |
| `PUT /api/chats/{chatId}/read` | Hanya `receiver_id` yang diizinkan | `200 ChatMobile`. |
| `PUT /api/chat/update/{chatId}` | `{ message }` — hanya `sender_id` | `200 ChatMobile`. |
| `DELETE /api/chat/delete/{chatId}` | Hanya `sender_id` | `200 { message }`. |
| `DELETE /api/chats/{senderId}/{receiverId}` | Token user wajib salah satu pihak | `200 { message }`. |

---

### 2.5 Notifikasi & Informasi (`NotificationControllerMobile` & `InformasiController`)
| Method & Path | Auth Saat Ini | Auth Target | Catatan |
| :--- | :---: | :---: | :--- |
| `GET /api/notifications` | Opsional Sanctum | **Sanctum Wajib** | Mengembalikan `{ success: true, data: [...] }` (limit 200). |
| `PATCH /api/notifications/{id}/read` | Cek owner jika ada token | **Sanctum Wajib** | Mengubah status menjadi `dibaca`. |
| `DELETE /api/notifications/{id}` | Cek owner jika ada token | **Sanctum Wajib** | Hapus notifikasi milik sendiri. |
| `POST /api/notifications/restore` | Publik | **Sanctum Wajib** | Undo hapus notifikasi. |
| `POST /api/update-fcm-token` | Publik | **Sanctum Wajib** | Ambil `user_id` dari token agar akun lain tidak bisa menimpa FCM token. |
| `POST /api/new-message` & `/api/report-update` | Publik | **Internal / Admin Only** | **Jangan dibuka publik** (rawan spam FCM). Dipanggil internal dari service backend. |
| `GET /api/informasi` | Publik | Publik | `{ status: "success", data: [{ id, judul, deskripsi, gambar, gambar_url, tanggal, waktu }] }`. |
| `GET /api/informasi/{informasi}/gambar` | Publik | Publik | Stream file gambar dengan CORS & `Cache-Control: max-age=86400`. |

---

## 3. Kontrak Realtime WebSocket (`websocket-server.cjs`)

**URL**: `SENTRA_WS_URL` (Lokal: `ws://127.0.0.1:3021`, Produksi Target: **`wss://ws.<domain-sentra>`** via Nginx TLS).

| Arah | `type` | Payload | Catatan Target Hardening |
| :---: | :--- | :--- | :--- |
| Server → Client | `connected` | `{ type, message, timestamp }` | Diterima saat koneksi terbuka. |
| Client → Server | `register` | `{ type, user_id, user_type, token }` | **Target P0**: Wajib validasi `token` Sanctum di server sebelum mendaftarkan `clients.set(userId, ws)`. |
| Server → Client | `registered` | `{ type, user_id, user_type, online_users: [] }` | Konfirmasi registrasi. |
| Client → Server | `send_message` | `{ type, sender_id, receiver_id, message, replied_to_id? }` | Gunakan `userId` terverifikasi dari sesi WS, bukan `sender_id` mentah. |
| Server → Client | `new_message` | `{ type, id_chat, sender_id, receiver_id, message, replied_to_id, sent_at, is_read, is_notified }` | Dikirim ke pengirim & penerima. |
| Client → Server | `edit_message` | `{ type, id_chat, new_message }` | **Target P0**: Cek `WHERE id_chat = ? AND sender_id = ?`. |
| Server → Client | `message_edited` | `{ type, chat_id, new_message, sent_at }` | Broadcast ke kedua pihak. |
| Client → Server | `delete_message` | `{ type, id_chat }` | **Target P0**: Cek `WHERE id_chat = ? AND sender_id = ?`. |
| Server → Client | `message_deleted` | `{ type, chat_id }` | Broadcast ke kedua pihak. |
| Bidirectional | `typing` | `{ type, senderId, receiverId, isTyping }` | Forward ke `receiverId`. |
| Bidirectional | `ping` / `pong` | `{ type: "ping" }` / `{ type: "pong" }` | Heartbeat tiap 30 detik. |

---

## 4. Standarisasi `lib/core/network/endpoints.dart`

Seluruh endpoint di atas harus didaftarkan terpusat di `lib/core/network/endpoints.dart` (tidak ada string URL tersebar di repository/screen) agar perubahan path cukup di satu file.
