## 👥 Anggota Tim
Berikut adalah kontributor yang bekerja dalam pengembangan proyek ini:

|Nama| NIM | GitHub |
| :--- | :---: | :--- |
| **Christy Jones** | 535240070 | [GitHub](https://github.com/christyjns) |
| **Vanesa Yolanda** | 535240071 | [GitHub](https://github.com/nesa28) |
| **Cathrine Sandrina** | 535240075 | [GitHub](https://github.com/Einnyboi) |
| **Tandwiyan Talenta** | 535240176 | [GitHub](https://github.com/tndwyntlnt) |
| **Naisya Yuen Ra’af** | 535240187 | [GitHub](https://github.com/itsyuenai) |

# 📱 Alleyway Muse - Mobile Loyalty App

**Alleyway Muse** adalah aplikasi *mobile loyalty membership* yang dirancang untuk pelanggan kedai kopi Alleyway. Aplikasi ini dibangun menggunakan **Flutter** dan terhubung secara *real-time* dengan backend Laravel untuk mengelola poin, penukaran hadiah, dan promo spesial.

Aplikasi ini bertujuan untuk meningkatkan retensi pelanggan melalui sistem gamifikasi (Leveling) dan kemudahan klaim poin transaksi secara mandiri.

---

## 🛠️ Teknologi & Packages

Aplikasi ini dikembangkan dengan Flutter SDK terbaru dan menggunakan *library* standar industri untuk performa dan keamanan:

* **Framework:** Flutter (Dart)
* **Architecture:** MVC (Model-View-Controller) / Service Pattern
* **State Management:** `setState` & `FutureBuilder` (Native)
* **Networking:** `http` (REST API Communication)
* **Local Storage:** `flutter_secure_storage` (Menyimpan Token JWT dengan enkripsi)
* **UI Components:**
    * `carousel_slider` (Banner Promo Otomatis)
    * `cached_network_image` (Optimasi gambar dari server)
    * `intl` (Format Tanggal & Rupiah)
* **Utilities:** `image_picker` (Upload Foto), `url_launcher`.

---

## ✨ Fitur & Fungsionalitas

### 🔐 1. Autentikasi & Keamanan
* **Login & Register:** Pendaftaran akun baru dan login aman menggunakan Token Bearer (JWT).
* **Auto-Login:** Aplikasi mengingat sesi pengguna (Persistent Session) sehingga tidak perlu login berulang kali.
* **Forgot Password:** Alur lengkap reset kata sandi menggunakan kode OTP 4-digit yang dikirim via Email.
* **Change Password:** Fitur mengganti kata sandi langsung dari menu profil.

### 💎 2. Sistem Loyalitas (Membership)
* **Member Tiering:** Status member (Bronze, Silver, Gold) yang berubah otomatis berdasarkan akumulasi poin.
* **Input Kode Transaksi:** Fitur unik dimana pengguna memasukkan kode dari struk fisik untuk mengklaim poin secara mandiri.
* **Redeem Rewards:** Katalog hadiah yang bisa ditukar dengan poin (Merchandise, Minuman Gratis, Diskon).
* **My Rewards:** Dompet digital untuk menyimpan voucher yang sudah ditukar namun belum digunakan.

### 🛍️ 3. Promo & Informasi
* **Special Offers:** Carousel banner interaktif untuk menampilkan promo terbaru (misal: Buy 1 Get 1).
* **Detail Promo Immersive:** Halaman detail promo dengan desain modern (*bottom sheet*).
* **Riwayat Aktivitas:** Log transparansi yang mencatat setiap poin masuk (dari transaksi) dan poin keluar (penukaran).

### 👤 4. Manajemen Profil
* **Edit Profil:** Mengubah data diri (Nama, Email, No HP, Tanggal Lahir).
* **Upload Foto:** Mengganti foto profil dengan mengambil gambar dari galeri HP, terintegrasi langsung dengan penyimpanan server.

---

## 📂 Struktur Proyek

Struktur folder disusun agar mudah dikembangkan (*scalable*) dan rapi.
bash
```
alleyway-mobile/
├── android/app/                       # Config Android (Icon, Permissions)
├── assets/                            # Aset Statis
│   └── images/
│       ├── logo.png
│       ├── onboarding_1.png
│       └── ...
│
├── lib/
│   ├── models/                        # Penerjemah JSON dari API
│   │   ├── my_reward.dart
│   │   ├── notification_item.dart
│   │   ├── promo.dart
│   │   ├── recent_activity.dart
│   │   ├── reward.dart
│   │   └── user_profile.dart
│   │
│   ├── screens/                       # Halaman UI (Tampilan)
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── token_verification_screen.dart
│   │   ├── activity_history_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── home_screen.dart           # Dashboard Utama
│   │   ├── my_rewards_screen.dart
│   │   ├── notification_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── promo_screen.dart
│   │   ├── promo_detail_screen.dart
│   │   ├── redeem_screen.dart
│   │   ├── reward_detail_screen.dart
│   │   └── ...
│   │
│   ├── services/                      # Komunikasi ke Backend
│   │   └── api_service.dart           # Semua logika HTTP ada di sini
│   │
│   ├── widgets/                       # Komponen UI yang Reusable
│   │   ├── member_card.dart
│   │   ├── quick_actions.dart
│   │   ├── recent_activity_list.dart
│   │   ├── special_offers_list.dart
│   │   └── ...
│   │
│   └── main.dart                      # Entry Point & Cek Token
│
├── pubspec.yaml                       # Daftar Library (http, intl, dll)
└── README.md                          # Dokumentasi Mobile
```

---

## 🚀 Instalasi & Menjalankan Aplikasi

Ikuti langkah-langkah ini untuk menjalankan proyek di komputer lokal atau membangun file APK.

### Prasyarat
* Flutter SDK Terinstal (`flutter doctor` ceklis hijau).
* Android Studio / VS Code.
* Emulator Android atau Device Fisik.
* Backend Laravel yang sudah berjalan (Online atau Localhost).

### Langkah 1: Clone Repositori
```bash
git clone https://github.com/tndwyntlnt/alleyway.git
cd alleyway
```

### Langkah 2: Install Dependencies
Unduh semua paket yang diperlukan.
bash
```
flutter pub get
```

### Langkah 3: Konfigurasi URL API (PENTING)
* Agar aplikasi bisa terhubung ke server, Anda harus mengatur URL API sesuai lingkungan Anda.
* Buka file lib/services/api_service.dart.
  * Opsi A: Jika Backend Online (Hosting)
  bash
  ```
  final String _baseUrl = "https://backendalleyway.web.id";
  ```
  * Opsi B: Jika Backend Localhost (Emulator Android)
  bash
  ```
  final String _baseUrl = "http://10.0.2.2:8000";
  ```
  * Opsi C: Jika Backend Localhost (HP Fisik / USB)
  bash
  ```
  // Gunakan IP Address Laptop Anda (cek via ipconfig/ifconfig)
  final String _baseUrl = "http://x.x.x.x:8000";
  ```

### Langkah 4: Update Domain Gambar
Karena gambar diambil dari server, helper URL gambar di model juga harus disesuaikan.
* Cek file di folder `lib/models/` (`reward.dart`, `promo.dart`, `user_profile.dart`, `my_reward.dart`).
* Update _getter_ `fullImageUrl` agar sesuai dengan domain di atas.

### Langkah 5: Jalankan Aplikasi (Debug)
```bash
flutter run
```

---
### 📦 Build APK (Production)
Untuk membuat file instalasi `.apk` yang siap dikirim ke pengguna HP Android:
1. Jalankan perintah build:
   bash
   ```
   flutter build apk --release
   ```
2. File APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`.
