# SENTRA — Dokumentasi API Lengkap (REST API & WebSocket)

> **Versi**: 2.0 (Post-Hardening)  
> **Tanggal Pembaruan**: 23 November 2026  
> **Backend Source**: `C:\Projects\Sentra\routes\api.php` (42 rute aktif) & `C:\Projects\Sentra\websocket-server.cjs`  
> **Spesifikasi Mesin (Postman/Swagger)**: [openapi.yaml](./openapi.yaml)  
> **Status Keamanan**: Seluruh temuan kritis P0 telah diamankan (`auth:sanctum`, `mobile.account`, `throttle`, dan verifikasi token SHA-256 pada WebSocket). Lihat [sync_audit.md](./sync_audit.md).

---

## 0. Ringkasan & Konvensi

### Base URL
| Lingkungan | REST API Base URL | WebSocket URL |
| :--- | :--- | :--- |
| **Lokal (Dev)** | `http://127.0.0.1:8000/api` | `ws://127.0.0.1:3021` |
| **Produksi (Target)** | `https://<domain-resmi-sentra>/api` | `wss://ws.<domain-resmi-sentra>` |

### Header Standar
```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <sanctum_plain_text_token>   # Wajib untuk endpoint Sanctum
```
> Untuk endpoint upload foto (`PJSRK`), gunakan `Content-Type: multipart/form-data`.

### Kode Status HTTP
- `200 OK` — Permintaan berhasil.
- `201 Created` — Data/laporan/pesan baru berhasil disimpan.
- `400 Bad Request` — Input logika/OTP/jawaban tidak cocok.
- `401 Unauthorized` — Token hilang/tidak valid atau kredensial salah.
- `403 Forbidden` — Mencoba mengakses/mengubah resource milik akun lain.
- `404 Not Found` — Data tidak ditemukan.
- `422 Unprocessable Entity` — Gagal validasi Laravel (`{ "message": "...", "errors": { "field": ["..."] } }`).
- `500 Internal Server Error` — Kesalahan internal server.

---

## 1. Autentikasi & Manajemen Akun (`AkunControllerMobile`)

### 1.1 Register Akun Baru
- **Endpoint**: `POST /api/auth/register`
- **Auth**: Publik (`throttle:15,1`)

| Field | Tipe | Wajib | Aturan Validasi Laravel |
| :--- | :--- | :-: | :--- |
| `notelp` | string | Ya | `required\|string\|max:15\|unique:akun,notelp` |
| `nama` | string | Ya | `required\|string\|max:50` |
| `password` | string | Ya | `required\|string\|min:6` |
| `emerquest` | string | Tidak | `nullable\|string\|max:100` |
| `answquest` | string | Tidak | `nullable\|string\|max:100` |
| `gender` | string | Tidak | `nullable\|string\|max:100` (disimpan ke `jenis_kelamin`) |
| `alamat` | string | Tidak | `nullable\|string\|max:100` |

**Contoh Request (`curl`)**:
```bash
curl -X POST http://127.0.0.1:8000/api/auth/register \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "notelp": "081234567890",
    "nama": "Budi Santoso",
    "password": "password123",
    "emerquest": "Dimana anda Lahir ?",
    "answquest": "Nganjuk",
    "gender": "Pria",
    "alamat": "Jl. Ahmad Yani No. 10, Nganjuk"
  }'
```

**Response `201 Created`**:
```json
{
  "success": true,
  "message": "Akun berhasil ditambahkan",
  "data": {
    "id_akun": 42,
    "laporan_updated": false
  }
}
```

---

### 1.2 Login (Nomor Telepon & Password)
- **Endpoint**: `POST /api/auth/login`
- **Auth**: Publik

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `notelp` | string | Ya | `required` |
| `password` | string | Ya | `required` |

**Response `200 OK`**:
```json
{
  "message": "Login berhasil",
  "user": {
    "id_akun": 42,
    "nama": "Budi Santoso",
    "notelp": "081234567890",
    "email": "budi@example.com",
    "jenis_kelamin": "Pria",
    "alamat": "Jl. Ahmad Yani No. 10, Nganjuk",
    "role": "user",
    "is_active": 1
  },
  "token": "1|aBcDeFgHiJkLmNoPqRsTuVwXyZ..."
}
```

**Response `401 Unauthorized`**:
```json
{
  "message": "No Telp atau password salah"
}
```

---

### 1.3 Ambil Data User Login Saat Ini
- **Endpoint**: `GET /api/user`
- **Auth**: **Sanctum Bearer Token** (`auth:sanctum`, `mobile.account`)

**Response `200 OK`**: Mengembalikan objek `UserMobile` aktif sesuai token Sanctum.

---

### 1.4 Edit Profil Akun
- **Endpoint**: `PUT /api/auth/edit/{id}`
- **Auth**: **Sanctum Bearer Token** (`id` wajib cocok dengan `id_akun` pemilik token)

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `notelp` | string | Tidak | `nullable\|string\|max:15` |
| `nama` | string | Tidak | `nullable\|string\|max:50` |
| `email` | string | Tidak | `nullable\|email\|max:100` |
| `jenis_kelamin` | string | Tidak | `nullable\|string\|max:100` |
| `alamat` | string | Tidak | `nullable\|string\|max:100` |
| `password` | string | Tidak | `nullable\|string\|min:6` |
| `emerquest` | string | Tidak | `nullable\|string\|max:100` |
| `answquest` | string | Tidak | `nullable\|string\|max:100` |

**Response `200 OK`**: `{ "message": "Akun berhasil diperbarui" }`  
**Response `403 Forbidden`**: `{ "message": "Anda tidak berhak mengubah akun ini" }`  
**Response `404 Not Found`**: `{ "message": "Akun tidak ditemukan" }`

---

### 1.5 Hapus Akun
- **Endpoint**: `DELETE /api/auth/delete/{id}`
- **Auth**: **Sanctum Bearer Token** (hanya pemilik akun sendiri; otomatis mencabut semua token Sanctum)
- **Response `200 OK`**: `{ "message": "Akun berhasil dihapus" }`

---

### 1.6 Update Nomor Telepon
- **Endpoint**: `POST /api/auth/updatenomor`
- **Auth**: **Sanctum Bearer Token**

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `notelp_lama` | string | Ya | `required\|string\|max:15` (harus cocok dengan akun login) |
| `notelp_baru` | string | Ya | `required\|string\|max:15` |
| `answquest` | string | Ya | `required\|string\|max:100` (harus cocok dengan jawaban darurat) |

- **Response `200 OK`**: `{ "message": "Nomor telepon berhasil diperbarui" }`
- **Response `401 Unauthorized`**: `{ "message": "Jawaban pertanyaan darurat salah" }`
- **Response `403 Forbidden`**: `{ "message": "Anda tidak berhak mengubah nomor ini" }`

---

### 1.7 Ubah Password
- **Endpoint**: `POST /api/auth/ubahpassword`
- **Auth**: **Sanctum Bearer Token** (mencabut seluruh token perangkat lain)

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `notelp` | string | Tidak | `nullable\|string\|max:15` |
| `password` | string | Ya | `required\|string\|min:6` |
| `password2` | string | Ya | `required\|string\|min:6\|same:password` |

- **Response `200 OK`**: `{ "message": "Password berhasil diperbarui" }`

---

### 1.8 Ambil Pertanyaan Keamanan & Verifikasi Darurat
- **`POST /api/auth/get-emergency-question`** (Publik)
  - Body: `{ "notelp": "081234567890" }` (`required|string|max:15`)
  - `200 OK`: `{ "success": true, "emerquest": "Dimana anda Lahir ?" }`
  - `404 Not Found`: `{ "success": false, "message": "Nomor telepon tidak ditemukan" }`
- **`POST /api/auth/emergency-check`** (Publik)
  - Body: `{ "notelp": "081234567890", "answer": "Nganjuk" }`
  - `200 OK`: `{ "message": "Verifikasi berhasil" }`
  - `400 Bad Request`: `{ "message": "Jawaban tidak sesuai" }`

---

### 1.9 Status Endpoint Auth Khusus (Hardened)
- **`POST /api/auth/biometric`** — **Sanctum Bearer Token** (`auth:sanctum`, `mobile.account`). Hanya memvalidasi sesi aktif dari token (tidak menerbitkan token baru tanpa autentikasi). Mobile disarankan memakai `GET /api/user`.
- **`POST /api/auth/email`** — **Dinonaktifkan (`401 Unauthorized`)** demi mencegah *account takeover* tanpa verifikasi kredensial (`throttle:15,1`).
- **`GET /api/auth/getdata`** — **Dihapus (`404 Not Found`)** demi mencegah kebocoran data akun publik.

---

## 2. Laporan PPPA, Riwayat, Pencarian, Tracking & Statistik (`LaporanControllerMobile`)

### 2.1 Kirim Laporan PPPA Lengkap
- **Endpoint**: `POST /api/post-report`
- **Auth**: **Sanctum Bearer Token** (`auth:sanctum`, `mobile.account`). Identitas `id_akun` selalu diambil dari token aktif.

**Contoh Request Body (`application/json`)**:
```json
{
  "id_akun": 42,
  "kategori": "Kekerasan Fisik",
  "status": "dikirim",
  "judul": "Laporan Kekerasan Dalam Rumah Tangga",
  "kecamatan": "Nganjuk",
  "layanan_pjsrk": null,
  "detail_pelapor": {
    "nik": "3518010101900001",
    "nama": "Siti Aminah",
    "alamat": "Kec. Nganjuk",
    "no_telp": "081234567890",
    "hubungan_dengan_korban": "Pelapor / Korban"
  },
  "detail_penerima_manfaat": {
    "nik": "3518010101900001",
    "nama": "Siti Aminah",
    "Tempat_lahir": "Nganjuk",
    "tanggal_lahir": "1990-01-01",
    "umur": 36,
    "jenis_kelamin": "Perempuan",
    "pekerjaan": "Wiraswasta",
    "agama": "Islam",
    "alamat": "Kec. Nganjuk",
    "pendidikan": "SMA",
    "hubungan_dengan_terlapor": "Suami",
    "notelp": "081234567890",
    "informasi_tambahan": "-"
  },
  "detail_terlapor": [
    {
      "nik": "3518010101880002",
      "nama": "Terlapor A",
      "umur": 38,
      "alamat": "Kec. Nganjuk",
      "jenis_kelamin": "Laki-laki",
      "hubungan_dengan_korban": "Suami",
      "informasi_tambahan": "-"
    }
  ],
  "detail_kasus": {
    "tanggal": "2026-11-23",
    "waktu_kejadian": "10:30:00",
    "tempat_kejadian": "Kec. Nganjuk",
    "kronologi": "Uraian kronologi kejadian secara lengkap."
  },
  "informasi_anak": [
    {
      "nama": "Anak A",
      "tanggal_lahir": "2018-05-10",
      "umur": 8,
      "jenis_kelamin": "Perempuan",
      "pendidikan": "SD",
      "agama": "Islam",
      "status": "Anak Kandung"
    }
  ]
}
```
> **Catatan**: `detail_terlapor` dapat berupa objek tunggal atau array objek. `status` awal valid: `dikirim|diterima` (default `dikirim`). Backend menerima baik `tempat_lahir` maupun `Tempat_lahir` pada `detail_penerima_manfaat` dan mengembalikan data penerima terdekripsi.

**Response `200 OK`**:
```json
{
  "success": true,
  "message": "Laporan berhasil dikirim",
  "data": {
    "laporan": { "id_laporan": "RKN000123", "status": "dikirim" },
    "detail_penerima": { "id_penerima": 15 },
    "informasi_anak": []
  }
}
```

---

### 2.2 Laporan Cepat PPPA (Boleh Tanpa Login)
- **Endpoint**: `POST /api/laporan-cepat`
- **Auth**: Publik

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `id_akun` | int | Tidak | `nullable\|integer\|exists:akun,id_akun` (jika kosong otomatis pakai akun `guest`) |
| `nik` | string | Ya | `required\|string\|max:100` |
| `nama` | string | Ya | `required\|string\|max:150` |
| `no_telp` | string | Ya | `required\|string\|max:15` |
| `alamat` | string | Ya | `required\|string\|max:255` |
| `deskripsi` | string | Ya | `required\|string` |

**Response `201 Created`**:
```json
{
  "success": true,
  "message": "Laporan cepat berhasil dikirim.",
  "data": { "id_laporan": "RKN000124" }
}
```

---

### 2.3 Tracking & Detail Laporan by ID
- **Endpoint**: `POST /api/track-report`
- **Body**: `{ "id_laporan": "RKN000124" }` (`required|exists:laporan,id_laporan`)
- **Response `200 OK`**:
```json
{
  "message": "Laporan ditemukan",
  "status": "diproses",
  "laporan": {
    "id_laporan": "RKN000124",
    "status": "diproses",
    "kategori": "Kekerasan Fisik",
    "layanan_pjsrk": null,
    "detail_pelapor": {},
    "detail_terlapor": [],
    "detail_penerima_manfaat": {},
    "detail_kasus": {},
    "detail_pjsrk": null
  }
}
```

---

### 2.4 Riwayat Laporan User & Filter Status
- **`GET /api/user-reports/{id_akun}`** — **Sanctum Bearer Token** (`auth:sanctum`, `mobile.account`, *owner check* `403`)
  - `200 OK`: `{ "message": "Laporan ditemukan", "laporan": [ ... ] }`
- **`GET /api/user-reports-by-category/{id_akun}/{status}`** — **Sanctum Bearer Token** (`auth:sanctum`, `mobile.account`, *owner check* `403`)
  - Path `{status}`: `dikirim`, `diterima`, `diproses`, `selesai`, `ditolak`, `dirujuk`.
  - `200 OK`: `{ "message": "Laporan ditemukan", "laporan": [ ... ] }`

---

### 2.5 Pencarian Laporan
- **Endpoint**: `GET /api/search?keyword=Siti` — **Sanctum Bearer Token** (`auth:sanctum`, `mobile.account`, terikat ke akun pemilik token)
- **Response `200 OK`**: Array JSON objek `LaporanMobile[]`.

---

### 2.6 Statistik Laporan Tahun Berjalan
- **Endpoint**: `GET /api/report-statistics` (Publik)
- **Response `200 OK`**:
```json
{
  "message": "Jumlah laporan per kategori per bulan tahun ini",
  "data": {
    "Jan": { "Kekerasan Fisik": 4, "Penelantaran": 2 },
    "Feb": { "Kekerasan Psikis": 3 }
  }
}
```

---

## 3. Layanan PJSRK (`PjsrkControllerMobile`)

Semua endpoint upload foto PJSRK (`/bencana`, `/rehabilitasi`, `/permasalahan-sosial`) wajib **Sanctum Bearer Token** (`auth:sanctum`, `mobile.account`, `id_akun` otomatis diambil dari token) dan menerima `multipart/form-data` dengan array file `foto[]` (maks 4 file, `jpeg,png,jpg,webp`, maks 5 MB/file). Endpoint `/pjsrk/cepat` bersifat publik dengan `throttle:20,1`.

### 3.1 Pengaduan Bencana
- **Endpoint**: `POST /api/pjsrk/bencana`
- **Content-Type**: `multipart/form-data`

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `id_akun` | int | Ya | `required\|exists:akun,id_akun` |
| `jenis_bencana` | string | Ya | `required\|string\|max:100` |
| `waktu_kejadian` | datetime | Ya | `required\|date` (contoh: `2026-11-23 09:30:00`) |
| `tingkat_dampak` | string | Ya | `in:Ringan,Sedang,Berat` |
| `jiwa_terdampak` | int | Ya | `integer\|min:0` |
| `rumah_rusak` | int | Ya | `integer\|min:0` |
| `keterangan` | string | Ya | `required\|string` |
| `kebutuhan_mendesak[]` | string[] | Ya | `array\|min:1`, item `string\|max:50` |
| `alamat` | string | Ya | `required\|string\|max:255` |
| `kelurahan` | string | Ya | `required\|string\|max:100` |
| `kecamatan` | string | Ya | `required\|string\|max:100` |
| `patokan_lokasi` | string | Tidak | `nullable\|string\|max:150` |
| `latitude` | number | Ya | `numeric\|between:-90,90` |
| `longitude` | number | Ya | `numeric\|between:-180,180` |
| `kontak` | string | Ya | `required\|string\|max:30` |
| `foto[]` | file[] | Tidak | `array\|max:4`, `image\|mimes:jpeg,png,jpg,webp\|max:5120` |

**Response `201 Created`**:
```json
{
  "success": true,
  "message": "Laporan pengaduan bencana berhasil dikirim.",
  "data": { "id_laporan": "RKN000125" }
}
```

---

### 3.2 Rehabilitasi Sosial
- **Endpoint**: `POST /api/pjsrk/rehabilitasi` (`multipart/form-data`)

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `id_akun` | int | Ya | `required\|exists:akun,id_akun` |
| `jenis_rehabilitasi` | string | Ya | `in:Tunawisma,Anak Terlantar` |
| `jumlah_penerima` | int | Ya | `integer\|min:1` |
| `jenis_kelamin` | string | Ya | `in:Laki-laki,Perempuan,Campuran` |
| `kelompok_usia` | string | Ya | `in:Dewasa,Lansia,Bersama anak` |
| `kondisi_saat_ditemukan` | string | Ya | `in:Sehat,Sakit,Gangguan jiwa` |
| `ciri_ciri` | string | Ya | `required\|string` |
| `rahasia` | bool | Tidak | `boolean` (`0`/`1` atau `true`/`false`) |
| `alamat` | string | Ya | `required\|string\|max:255` |
| `latitude` / `longitude` | number | Tidak | `nullable\|numeric` |
| `kontak` | string | Ya | `required\|string\|max:30` |
| `foto[]` | file[] | Tidak | Maks 4 foto, maks 5 MB/file |

- **Response `201 Created`**: `{ "success": true, "message": "Laporan rehabilitasi sosial berhasil dikirim.", "data": { "id_laporan": "RKN000126" } }`

---

### 3.3 Permasalahan Sosial
- **Endpoint**: `POST /api/pjsrk/permasalahan-sosial` (`multipart/form-data`)

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `id_akun` | int | Ya | `required\|exists:akun,id_akun` |
| `jenis_permasalahan` | string | Ya | `required\|string\|max:100` |
| `judul` | string | Ya | `required\|string\|max:150` |
| `uraian` | string | Ya | `required\|string` |
| `alamat` | string | Ya | `required\|string\|max:255` |
| `kelurahan` / `kecamatan` | string | Tidak | `nullable\|string\|max:100` |
| `latitude` / `longitude` | number | Tidak | `nullable\|numeric` |
| `rahasia` | bool | Tidak | `boolean` |
| `kontak` | string | Tidak | `nullable\|string\|max:30` |
| `foto[]` | file[] | Tidak | Maks 4 foto, maks 5 MB/file |

- **Response `201 Created`**: `{ "success": true, "message": "Laporan permasalahan sosial berhasil dikirim.", "data": { "id_laporan": "RKN000127" } }`

---

### 3.4 Laporan Cepat PJSRK (Boleh Tanpa Login)
- **Endpoint**: `POST /api/pjsrk/cepat` (`application/json`)

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :-: | :--- |
| `id_akun` | int | Tidak | `nullable\|integer\|exists:akun,id_akun` |
| `layanan` | string | Ya | `in:pengaduan_bencana,rehabilitasi_sosial,permasalahan_sosial` |
| `nama` | string | Ya | `required\|string\|max:150` |
| `telepon` | string | Ya | `required\|string\|max:30` |
| `lokasi` | string | Ya | `required\|string\|max:255` |
| `jenis` | string | Ya | `required\|string\|max:100` |
| `deskripsi` | string | Ya | `required\|string` |

- **Response `201 Created`**: `{ "success": true, "message": "Laporan cepat berhasil dikirim.", "data": { "id_laporan": "RKN000128" } }`

---

## 4. Chat Konsultasi (`ChatControllerMobile` — Wajib Sanctum)

Semua 7 endpoint berada dalam `middleware(['auth:sanctum', 'mobile.account'])`.

| Method & Path | Payload / Query | Respons Sukses |
| :--- | :--- | :--- |
| `POST /api/chats` | `{ "receiver_id": 1, "message": "Halo", "replied_to_id": null }` (`sender_id` otomatis dari token) | `201 ChatMobile` (+ memicu FCM) |
| `GET /api/chats/{userId}` | Opsional `?other_user_id=1` (`userId` wajib == token user) | `200 ChatMobile[]` urut `sent_at ASC` |
| `GET /api/conversations/{userId}` | Path `userId` wajib == token user | `200 [{ user_id, name, last_message, time, is_online }]` |
| `PUT /api/chats/{chatId}/read` | Tanpa body (hanya `receiver_id` yang boleh) | `200 ChatMobile` (`is_read: 1`) |
| `PUT /api/chat/update/{chatId}` | `{ "message": "Pesan revisi" }` (hanya `sender_id`) | `200 ChatMobile` |
| `DELETE /api/chat/delete/{chatId}` | Tanpa body (hanya `sender_id`) | `200 { "message": "Chat deleted" }` |
| `DELETE /api/chats/{senderId}/{receiverId}` | Tanpa body (wajib salah satu peserta) | `200 { "message": "Conversation deleted" }` |

---

## 5. Notifikasi & FCM (`NotificationControllerMobile` — Wajib Sanctum)

| Method & Path | Auth & Payload / Query | Respons Sukses |
| :--- | :--- | :--- |
| `GET /api/notifications` | **Sanctum** (`mobile.account`) — opsional `?user_id=42` (wajib sama dengan token) | `200 { success: true, data: [{ id_notif, id_akun, judul, pesan, tipe, status, source, id_laporan, created_at }] }` |
| `PATCH /api/notifications/{id}/read` | **Sanctum** (`mobile.account`, *owner check*) | `200 { success: true, message: "Notifikasi ditandai sudah dibaca." }` |
| `DELETE /api/notifications/{id}` | **Sanctum** (`mobile.account`, *owner check*) | `200 { success: true, message: "Notifikasi dihapus." }` |
| `POST /api/notifications/restore` | **Sanctum** (`mobile.account`) — `{ id_notif?, id_akun, judul, pesan, tipe: "admin\|user", status?: "terkirim\|dibaca", created_at? }` | `200 { success: true, message: "Notifikasi dipulihkan.", data: { id_notif } }` |
| `POST /api/update-fcm-token` | **Sanctum** (`mobile.account`) — `{ "fcm_token": "fcm_device_token..." }` | `200 { "message": "FCM token updated" }` |
| `POST /api/new-message` | **Sanctum** (`mobile.account`) — `{ "receiver_id": 1, "message": "Halo" }` | `200 { "message": "Notifikasi dikirim" }` |
| `POST /api/report-update` | **Sanctum** (Admin atau pemilik laporan) — `{ "id_laporan": "RKN000124", "user_id": 42, "status": "dikirim\|diterima\|diproses\|selesai\|ditolak\|dirujuk" }` | `200 { "message": "Notifikasi laporan dikirim" }` |

---

## 6. Informasi Publik (`InformasiController`)

- **`GET /api/informasi`** (Publik):
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": 1,
        "judul": "Sosialisasi Perlindungan Anak",
        "deskripsi": "Kegiatan dilaksanakan di Pendopo...",
        "gambar": "http://127.0.0.1:8000/uploads/informasi/banner.jpg",
        "gambar_url": "http://127.0.0.1:8000/api/informasi/1/gambar",
        "tanggal": "23 November 2026",
        "waktu": "2 jam yang lalu"
      }
    ]
  }
  ```
- **`GET /api/informasi/{informasi}/gambar`** (Publik): Mengembalikan binary image (`image/jpeg` / `image/png`) dengan header `Access-Control-Allow-Origin: *` dan `Cache-Control: public, max-age=86400`.

---

## 7. Legacy Auth Endpoints — Deprecated (`AuthControllerMobile`)

Keempat route berikut masih aktif di `routes/api.php` namun direncanakan untuk dihapus pada Fase P2 karena duplikat dengan `/api/auth/*`:
- `POST /api/login` — Body `{ notelp, password }` → `200 { message, user, token }`
- `POST /api/register` — Body `{ notelp, nama, password }` → `200 { message, user }`
- `POST /api/forgot-password` — Body `{ notelp }` → `200 { message: "OTP telah dikirim" }`
- `POST /api/reset-password` — Body `{ notelp, otp, password }` → `200 { message: "Password berhasil direset" }`

---

## 8. Dokumentasi WebSocket Realtime (`websocket-server.cjs`)

### Koneksi & Heartbeat
1. Buka koneksi ke `SENTRA_WS_URL` (lokal: `ws://127.0.0.1:3021`).
2. Server langsung mengirim event `connected`:
   ```json
   { "type": "connected", "message": "WebSocket connection established", "timestamp": "2026-11-23T04:00:00.000Z" }
   ```
3. Klien wajib mengirim `register` segera setelah terhubung. Server menjalankan ping/pong setiap **30 detik** untuk memutus koneksi mati.

### Daftar Event JSON

#### 1. Registrasi Klien Terautentikasi (`register` → `registered` + `user_online`)
> Server memverifikasi `token` Sanctum (`{id}|{plainText}`) dengan mencocokkan hash SHA-256 terhadap tabel `personal_access_tokens` dan memastikan `akun.is_active = 1`. Bila tidak valid, server mengirim `auth_error` lalu memutus koneksi (`4001`).

```json
// Client -> Server
{ "type": "register", "token": "1|aBcDeFgHiJkLmNoPqRsTuVwXyZ...", "user_id": "42", "user_type": "user" }

// Server -> Client (konfirmasi)
{ "type": "registered", "user_id": "42", "user_type": "user", "online_users": ["1", "42"] }

// Server -> Client (jika token tidak valid)
{ "type": "auth_error", "message": "Token WebSocket tidak valid atau kedaluwarsa." }

// Server -> Klien lain
{ "type": "user_online", "user_id": "42" }
```

#### 2. Kirim Pesan (`send_message` → `new_message`)
```json
// Client -> Server
{ "type": "send_message", "sender_id": 42, "receiver_id": 1, "message": "Halo admin", "replied_to_id": null }

// Server -> Pengirim & Penerima
{
  "type": "new_message",
  "id_chat": 108,
  "sender_id": 42,
  "receiver_id": 1,
  "message": "Halo admin",
  "replied_to_id": null,
  "sent_at": "2026-11-23T04:01:00.000Z",
  "is_read": 0,
  "is_notified": 0
}
```

#### 3. Edit & Hapus Pesan (`edit_message` / `delete_message`)
```json
// Edit: Client -> Server
{ "type": "edit_message", "id_chat": 108, "new_message": "Halo admin, mohon bantuannya" }
// Edit: Server -> Kedua Pihak
{ "type": "message_edited", "chat_id": 108, "new_message": "Halo admin, mohon bantuannya", "sent_at": "2026-11-23T04:01:00.000Z" }

// Delete: Client -> Server
{ "type": "delete_message", "id_chat": 108 }
// Delete: Server -> Kedua Pihak
{ "type": "message_deleted", "chat_id": 108 }
```

#### 4. Typing, Offline & Keepalive
```json
// Typing (Client -> Server -> Receiver)
{ "type": "typing", "senderId": 42, "receiverId": 1, "isTyping": true }

// Disconnect broadcast (Server -> Semua klien)
{ "type": "user_offline", "user_id": "42" }

// Keepalive
{ "type": "ping" }   // balasan server: { "type": "pong" }
```
