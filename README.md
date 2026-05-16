<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
</div>

<h1 align="center">🏗️ ConstrAA Report</h1>

<p align="center">
  <b>Aplikasi Mobile Premium untuk Manajemen Progres & K3 Proyek Konstruksi</b><br>
  <i>Laporan harian di lapangan kini lebih cepat, rapi, dan terintegrasi.</i>
</p>

---

## 🌟 Tentang Aplikasi
**ConstrAA Report** adalah solusi digital modern yang dirancang khusus untuk para praktisi konstruksi (mandor, pengawas, hingga *project manager*). Aplikasi ini mendigitalkan proses pencatatan manual di lapangan, memastikan kelengkapan data harian seperti volume pekerjaan, alat berat, bahan, hingga kepatuhan standar K3 (Kesehatan dan Keselamatan Kerja) terekam dengan aman dalam satu *database* terpusat.

## 🚀 Fitur Utama

- 🔐 **Autentikasi Aman**: Sistem Login dan Pendaftaran peran-ganda terintegrasi dengan backend *Supabase*.
- 📝 **Input Laporan Harian**: Form interaktif untuk mencatat jenis pekerjaan, volume bahan, dan jumlah pekerja.
- 👷‍♂️ **Ceklis K3 Interaktif**: Kartu *Premium UI* yang menampilkan *counter* otomatis kelengkapan K3 (Helm, Sepatu, Harness, dll).
- 🚜 **Manajemen Alat Dinamis**: Pilih alat berat dari *chip* bawaan atau tambahkan alat kustom secara langsung.
- 📸 **Dokumentasi Visual**: Pengambilan gambar langsung dari lapangan untuk bukti progres aktual.
- 📊 **Dashboard Analitik**: Rangkuman total pekerja, tingkat kepatuhan K3, dan status pekerjaan.
- 📁 **Rekapitulasi Cerdas**: Riwayat laporan harian yang tertata rapi dan interaktif.
- 📱 **Desain Responsif & Animasi**: Dibangun dengan *Glassmorphism UI* dan transisi *micro-animation* menggunakan `flutter_animate`.

## 🛠️ Teknologi & Arsitektur

Aplikasi ini dikembangkan dengan arsitektur modern untuk memastikan performa tinggi dan skalabilitas:

| Komponen | Teknologi |
| :--- | :--- |
| **Framework UI** | Flutter (Dart) |
| **Backend & Auth** | Supabase (PostgreSQL) |
| **State & Storage** | Local Storage (SharedPreferences) & Caching |
| **Desain & Animasi** | Vanilla Flutter UI, `flutter_animate` |
| **Media Handling** | `image_picker` |

## 📦 Menjalankan Proyek Secara Lokal

Untuk menguji atau berkontribusi pada pengembangan aplikasi ini:

1. **Clone Repositori**
   ```bash
   git clone https://github.com/ardlikafi/ConstrAAReport.git
   cd ConstrAAReport
   ```

2. **Unduh Dependensi**
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

## 📱 Tampilan Layar (Screenshots)
*(Coming soon)*

<p align="center">
  <i>"Membangun dengan data, memantau dengan presisi."</i>
</p>
