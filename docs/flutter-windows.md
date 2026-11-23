# Flutter di Windows

Konfigurasi VS Code proyek ini menggunakan lokasi berikut:

- Flutter SDK: `C:\src\flutter`
- Cache Pub (`PUB_CACHE`): `C:\Pub\Cache`

Keduanya harus berupa direktori fisik tanpa spasi. Junction seperti
`C:\flutter` yang mengarah ke `C:\Users\ASUS TUF\...` masih dapat dibaca
oleh Dart sebagai lokasi asli yang mengandung spasi. Hal ini dapat menyebabkan
build hook dependensi transitif `objective_c` gagal menjalankan Dart di Windows.

Untuk komputer lain, sesuaikan `dart.flutterSdkPath`, `dart.env.PUB_CACHE`, dan
`terminal.integrated.env.windows` di `.vscode/settings.json` dengan lokasi
SDK/cache lokal. Untuk terminal di luar VS Code, atur environment variable
pengguna `PUB_CACHE` dan letakkan direktori `bin` SDK tersebut di awal `Path`.

Setelah mengganti lokasi SDK/cache, buka ulang VS Code dan terminal, lalu
jalankan dari direktori proyek:

```powershell
flutter clean
flutter pub get
flutter build web --debug --no-pub
flutter run -d chrome
```

`flutter clean` menghapus konfigurasi build/hook lama; `flutter pub get`
membuat ulang referensi paket. Paket `objective_c` tetap merupakan dependensi
transitif dan tidak perlu dihapus atau ditimpa versinya untuk perbaikan path ini.

Untuk memeriksa lokasi yang benar-benar digunakan:

```powershell
Get-Command flutter | Select-Object Source
$config = Get-Content .dart_tool/package_config.json -Raw | ConvertFrom-Json
$config | Select-Object flutterRoot, pubCache
$config.packages | Where-Object name -eq objective_c | Select-Object rootUri
```

Jika `Failed to exit Chromium` tetap muncul setelah build hook berhasil,
periksa secara terpisah saat menghentikan sesi debug Chrome.
