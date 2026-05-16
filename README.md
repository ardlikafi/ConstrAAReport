# ConstrAA Report 🏗️

Aplikasi mobile premium dan modern untuk manajemen dan pelaporan progres proyek konstruksi harian. Dibangun dengan menggunakan **Flutter** dan **Supabase**.

## Fitur Utama ✨
* **Manajemen Progres Harian**: Catat pekerjaan, bahan, alat, dan volume dengan sangat mudah.
* **Sistem K3 Terintegrasi**: Pengecekan standar Kesehatan dan Keselamatan Kerja (K3) dengan tampilan interaktif.
* **Dokumentasi Foto**: Langsung ambil atau unggah foto progres dari galeri perangkat.
* **Dashboard Analitik**: Pantau metrik proyek seperti Total Pekerja, Kepatuhan K3, dan jumlah laporan.
* **Autentikasi Aman**: Login dan Registrasi terintegrasi dengan **Supabase Auth**.
* **Database Persisten**: Data tersimpan dengan aman dan siap disinkronisasikan ke Cloud.
* **UI/UX Elegan**: Dilengkapi dengan animasi halus menggunakan `flutter_animate` dan komponen desain premium.

## Teknologi yang Digunakan 💻
* **Framework:** Flutter (Dart)
* **Backend as a Service:** Supabase (PostgreSQL & Auth)
* **Local Storage:** SharedPreferences
* **Animasi:** flutter_animate
* **Media:** image_picker

## Panduan Instalasi 🚀

1. **Clone repositori ini**
   ```bash
   git clone https://github.com/ardlikafi/ConstrAAReport.git
   cd ConstrAAReport
   ```

2. **Install semua dependensi**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Supabase**
   Buka file `lib/main.dart` dan pastikan `Supabase.initialize` sudah berisi URL dan Anon Key dari proyek Supabase Anda.

4. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

## Konfigurasi Database Supabase 🗄️
Untuk menyimpan laporan secara *online* di Supabase, jalankan kode SQL berikut pada **SQL Editor** di Dashboard Supabase Anda:

```sql
CREATE TABLE reports (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  project_name TEXT NOT NULL,
  date TEXT NOT NULL,
  jenis_pekerjaan TEXT NOT NULL,
  jenis_bahan TEXT NOT NULL,
  volume TEXT NOT NULL,
  satuan TEXT NOT NULL,
  jenis_alat TEXT[] DEFAULT '{}',
  jumlah_pekerja INT DEFAULT 1,
  k3_count INT DEFAULT 0,
  image_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);
```

## Build APK Rilis 📦
Untuk membangun file APK yang siap dipasang ke perangkat Android:
```bash
flutter build apk --release
```
File APK akan berada di: `build/app/outputs/flutter-apk/app-release.apk`.
