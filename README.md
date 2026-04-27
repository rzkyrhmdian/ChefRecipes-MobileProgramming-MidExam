# Chef Recipes - Mobile Programming Mid Exam
## Moh. Rizky Rahmadian Makkani_5025231035
Chef Recipes adalah aplikasi mobile berbasis Flutter untuk membuat, menyimpan,
melihat, dan mengelola resep masakan. Aplikasi ini menggunakan Firebase untuk
autentikasi dan penyimpanan data, serta integrasi ImgBB untuk upload gambar
resep.

Link Demo: https://youtu.be/jD9T9zbGAMU

## Deskripsi Aplikasi

Aplikasi ini ditujukan untuk pengguna yang ingin:

- Menyimpan resep masakan pribadi dalam satu tempat.
- Menambahkan foto resep dari kamera atau galeri.
- Menandai resep favorit agar lebih mudah ditemukan kembali.
- Mendapatkan pengingat memasak melalui notifikasi lokal.

## Fitur Utama

- Autentikasi pengguna dengan email dan password (register/login/logout).
- Splash screen dan auth gate untuk pengecekan sesi login otomatis.
- CRUD resep:
	- Create: tambah resep baru.
	- Read: lihat daftar resep dan detail resep.
	- Update: edit resep milik sendiri.
	- Delete: hapus resep milik sendiri.
- Upload gambar resep ke ImgBB (sumber gambar dari kamera/galeri).
- Favorite recipe:
	- Tandai atau batalkan favorit dari daftar resep maupun detail resep.
	- Lihat daftar resep favorit pada halaman khusus.
- Notifikasi lokal:
	- Notifikasi instan (test notification).
	- Notifikasi saat resep berhasil disimpan.
	- Reminder harian terjadwal (08:00 dan 17:00).
- UI Material 3 dengan tema warna hangat dan komponen responsif dasar.

## Flow Aplikasi

Berikut alur utama aplikasi dari sisi pengguna:

1. App dibuka -> tampil `SplashPage`.
2. Setelah splash, pengguna diarahkan ke `AuthGatePage`.
3. Jika belum login -> masuk ke halaman `LoginPage`.
4. Jika sudah login -> masuk ke `HomePage`.
5. Di `HomePage`, pengguna dapat:
	 - Melihat semua resep.
	 - Membuka detail resep.
	 - Menambah resep baru.
	 - Menandai favorit.
	 - Masuk ke halaman favorit dan profil.
6. Pada `RecipeDetailPage`, pemilik resep dapat mengedit atau menghapus resep.
7. Pada `FavoritePage`, pengguna melihat semua resep favoritnya.
8. Pada `ProfilePage`, pengguna dapat:
	 - Uji notifikasi instan.
	 - Aktifkan reminder harian.
	 - Batalkan seluruh reminder.
	 - Logout.

## Teknologi yang Digunakan

- Flutter (Dart)
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Image Picker
- HTTP (untuk upload ke ImgBB)
- Awesome Notifications
- Flutter Dotenv

## Struktur Folder Inti

```text
lib/
	main.dart
	firebase_options.dart
	models/
		recipe.dart
	pages/
		splash_page.dart
		auth_gate_page.dart
		login_page.dart
		register_page.dart
		home_page.dart
		add_recipe_page.dart
		edit_recipe_page.dart
		recipe_detail_page.dart
		favorite_page.dart
		profile_page.dart
	services/
		auth_service.dart
		db_service.dart
		favorites_service.dart
		imgbb_service.dart
		local_notification_service.dart
	widgets/
		safe_network_image.dart
```

## Cara Menjalankan

### 1. Prasyarat

Pastikan sudah terpasang:

- Flutter SDK
- Dart SDK (biasanya sudah termasuk dalam Flutter)
- Android Studio / VS Code + emulator atau perangkat fisik
- Akun Firebase (project sudah dikonfigurasi untuk app ini)

Cek instalasi Flutter:

```bash
flutter --version
flutter doctor
```

### 2. Clone dan install dependency

```bash
git clone https://github.com/rzkyrhmdian/ChefRecipes-MobileProgramming-MidExam.git
cd ChefRecipes-MobileProgramming-MidExam
flutter pub get
```

### 3. Siapkan file environment

Buat file `.env` di root project, lalu isi minimal:

```env
IMGBB_API_KEY=YOUR_IMGBB_API_KEY
```

Catatan:

- `.env` sudah didaftarkan sebagai asset di `pubspec.yaml`.
- Tanpa `IMGBB_API_KEY`, fitur upload gambar tidak akan berjalan.

### 4. Konfigurasi Firebase

Project ini memakai Firebase untuk auth dan database.

- Pastikan file konfigurasi Firebase sudah sesuai:
	- Android: `android/app/google-services.json`
	- iOS: `ios/Runner/GoogleService-Info.plist` (jika target iOS digunakan)
- Pastikan `lib/firebase_options.dart` sesuai dengan project Firebase aktif.

### 5. Jalankan aplikasi

```bash
flutter run
```

Jika ingin menjalankan di device tertentu:

```bash
flutter devices
flutter run -d <device_id>
```

## Akun dan Data

- Pengguna baru dapat membuat akun lewat halaman Register.
- Data resep disimpan di koleksi Firestore `recipes`.
- Data favorit disimpan di koleksi Firestore `favorites`.

---

*Mini Project ini dibuat untuk kebutuhan ETS/Mid Exam mata kuliah Mobile Programming(PPB).*