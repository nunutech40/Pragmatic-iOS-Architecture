# 🛡️ LoginTesting  
**Core Authentication Module for iOS (SwiftUI + Combine)**

LoginTesting adalah implementasi **boilerplate sistem otentikasi** yang **scalable, aman, dan testable** untuk aplikasi iOS modern.  
Proyek ini dirancang sebagai **fondasi (starter core)** yang bisa langsung dikembangkan untuk aplikasi production.

Teknologi utama:
- **SwiftUI**
- **Combine**
- **MVVM + Repository Pattern**
- **Keychain-based Security**

---

## 🎯 Tujuan Proyek

- Menyediakan **arsitektur autentikasi yang bersih dan terstruktur**
- Memastikan **keamanan data sensitif** (token) sesuai best practice iOS
- Memudahkan **pengembangan lanjutan dan testing**
- Menjadi **referensi arsitektur** untuk modul autentikasi iOS

---

## 🚀 Fitur & Implementasi Inti

### 🔐 Secure Authentication
- Seluruh flow login dan manajemen token **diisolasi**
- Token **tidak pernah** disimpan di UserDefaults
- Menggunakan **Keychain** sebagai secure storage

### 🧩 Decoupled Architecture
- Pemisahan tanggung jawab ketat (View ↔ ViewModel ↔ Repository)
- Mudah di-extend dan di-maintain
- Cocok untuk aplikasi skala kecil hingga besar

### 🔄 Reactive State Management
- Combine digunakan untuk:
  - Asynchronous API call
  - State UI (loading, error, success)
  - Data flow yang reaktif dan terkontrol

---

## 🏗️ Pola Arsitektur

### 1️⃣ MVVM (Model–View–ViewModel)

MVVM digunakan untuk memisahkan logika UI dan logika bisnis.

| Komponen | Deskripsi | Tanggung Jawab |
|--------|----------|---------------|
| **View** (`LoginView`, `HomeView`) | SwiftUI layer | Menampilkan state dari ViewModel dan mengirim user action |
| **ViewModel** (`LoginViewModel`) | UI logic handler | Mengelola state UI (`isLoading`, `isError`, dll) dan memanggil Repository |
| **Model** (`UserInfo`, `AuthDataResponse`) | Data contract | Mendefinisikan struktur data dan response API |

---

### 2️⃣ Repository Pattern (Data Layer Abstraction)

`UserRepository` berperan sebagai **jembatan** antara ViewModel dan Data Source.

**Tanggung Jawab Repository:**
- Mengabstraksi asal data (API / Cache / Local)
- Menyediakan API yang konsisten ke ViewModel
- Menghindari ketergantungan ViewModel ke network layer

**Keuntungan Utama:**
- ViewModel **mudah di-unit test**
- Repository dapat di-**mock**
- Tidak ada network dependency saat testing

---

## 🔒 Security & Data Persistence

Keamanan data autentikasi menjadi prioritas utama.

### Mekanisme Penyimpanan

| Item | Penyimpanan | Alasan |
|----|------------|-------|
| **Access & Refresh Token** | Keychain (`SecureStorage`) | Enkripsi hardware-level via Secure Enclave |
| **UserInfo (non-sensitif)** | UserDefaults (`LocalPersistence`) | Instant loading saat app launch |
| **Session State** | AuthenticationManager | Single source of truth global |

---

## 🌍 Global Session Management

### AuthenticationManager

Lapisan global yang bertanggung jawab atas:

- **Session Checking**
  - Membaca token dari Keychain
  - Membaca user data dari LocalPersistence
- **State Observation**
  - Menyediakan `isAuthenticated`
  - Digunakan oleh `ContentView` untuk routing
- **Universal Logout**
  - Menghapus seluruh data dari Keychain & LocalPersistence
  - Konsisten dan aman

---

## 📊 Status Proyek

| Fitur | Status | Catatan |
|-----|-------|--------|
| Basic Login Flow | ✅ Selesai | Login user/password via Repository |
| Get Profile API | ✅ Selesai | Network + cache fallback |
| Logout & Clean Storage | ✅ Selesai | Keychain & UserDefaults dibersihkan |
| Session Management | ✅ Selesai | Global auth state |

---

## 📦 Kontrak Model Data

Proyek ini menerapkan **Type Safety** dengan memisahkan model berdasarkan konteks penggunaan.

- **UserInfo**  
  Data minimal hasil login (ID, name, email, dll)

- **UserProfileResponse**  
  Data lengkap dari Profile API (`getProfile`)

Pendekatan ini mencegah:
- Over-fetching data
- Kebocoran data sensitif
- Coupling antar endpoint

---

## 📌 Catatan Pengembangan Selanjutnya

- Token refresh interceptor
- Biometric authentication (Face ID / Touch ID)
- Offline-first session handling
- Modular SDK extraction
- Integration testing

---

## 🤝 Kontribusi & Pengembangan Lanjutan

Proyek ini cocok dijadikan:
- **Authentication core**
- **Internal SDK**
- **Boilerplate production app**
- **Referensi arsitektur SwiftUI + Combine**

---

> 💡 *Next step:* Dokumentasi dan implementasi **SDK Liveness Detection** dapat disusun dengan struktur serupa agar konsisten dan scalable.
