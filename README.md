# 💰 RUPIA - Smart Financial App

<p align="center">
  <img src="assets/logo.png" alt="Rupia Logo" width="150"/>
</p>

<p align="center">
  <strong>Aplikasi Pengelolaan Keuangan Pribadi dengan Mood Analytics & Smart Sync</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.32.2+-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.8.1+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?logo=firebase" alt="Firebase"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
</p>

---

## 📖 Tentang RUPIA

**RUPIA** adalah aplikasi keuangan Flutter yang menggabungkan psikologi pengeluaran, otomasi data, dan fleksibilitas spreadsheet. Dirancang untuk membantu pengguna memahami kebiasaan belanja mereka tidak hanya dari sisi angka, tapi juga dari sisi emosional.

### 🎯 Kenapa RUPIA Berbeda?

| Fitur | Aplikasi Lain | RUPIA |
|-------|--------------|-------|
| Tracking Transaksi | ✅ | ✅ |
| Budget Management | ✅ | ✅ |
| **Mood Analytics** | ❌ | ✅ |
| **Receipt OCR Scanner** | Berbayar | ✅ Gratis |
| **Geofencing Reminder** | ❌ | ✅ |
| **Shared Vault** | ❌ | ✅ |
| **Google Sheets Sync** | ❌ | ✅ Full UI |
| **Dark Mode** | ✅ | ✅ Light/Dark/System |
| **CI/CD Pipeline** | ❌ | ✅ GitHub Actions |

---

## ✨ Fitur Lengkap

### 📊 Core Features
- **Catat Transaksi** - Pemasukan & pengeluaran dengan kategori kustom
- **Budget Management** - Atur budget per kategori dengan progress visual
- **Analytics Dashboard** - Grafik & statistik pengeluaran bulanan
- **Multi-Device Sync** - Data tersinkron di semua perangkat

### 🎭 Mood Analytics (Fitur Unik!)
- Lacak mood saat berbelanja: **Happy**, **Stress**, **Tired**, **Bored**, **Neutral**
- Insight otomatis: *"Kamu paling boros saat stress!"*
- Visualisasi pie chart & breakdown per mood
- Bantu identifikasi pola emotional spending

### 📷 Receipt Scanner (OCR)
- Scan struk belanja dengan kamera
- Deteksi otomatis: total, tanggal, merchant
- Powered by **Google ML Kit**
- Langsung buat transaksi dari hasil scan

### 📍 Geofencing
- Buat zona pengeluaran (Mall, Cafe, Supermarket)
- Notifikasi otomatis saat memasuki zona
- Ingatkan sisa budget di lokasi tertentu
- Battery-efficient background tracking

### 👨‍👩‍👧‍👦 Shared Vault
- Vault bersama untuk keluarga/pasangan
- Maksimal 5 anggota per vault
- Real-time sync pengeluaran bersama
- Transparansi keuangan keluarga

### 📊 Google Sheets Sync
- Export otomatis ke Google Sheets
- OAuth 2.0 authentication dengan UI lengkap
- Batch sync dengan progress tracking
- Auto-create spreadsheet dengan format terstruktur
- Dashboard sync dengan status real-time

### 🔐 Keamanan & Cloud
- **Google Sign-In** - Login aman dengan akun Google
- **Firebase Auth** - Autentikasi terenkripsi
- **Cloud Firestore** - Backup otomatis ke cloud
- **Local-First** - Tetap berfungsi saat offline

---

## 🛠 Tech Stack

| Kategori | Teknologi |
|----------|-----------|
| **Framework** | Flutter 3.32.2+ |
| **Language** | Dart 3.8.1+ |
| **State Management** | Riverpod |
| **Local Database** | SQLite (sqflite) |
| **Authentication** | Firebase Auth + Google Sign-In |
| **Cloud Database** | Cloud Firestore |
| **OCR Engine** | Google ML Kit |
| **Location** | Geolocator + Geofencing |
| **Charts** | FL Chart |
| **Routing** | GoRouter |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.32.2 atau lebih baru (Dart SDK ^3.8.1)
- Android Studio / VS Code
- Akun Firebase (untuk fitur cloud)
- Device Android/iOS atau Emulator
- Java JDK 17+ (untuk build Android)

### Installation

```bash
# 1. Clone repository
git clone https://github.com/firdausmntp/rupia.git
cd rupia

# 2. Install dependencies
flutter pub get

# 3. Run aplikasi
flutter run
```

### Quick Test (Web - Tanpa Firebase)

```bash
flutter run -d chrome
```
> Mode demo otomatis aktif di web dengan mock data untuk preview UI.

---

## 🔥 Firebase Setup

### 1. Buat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **"Add Project"** → Beri nama `rupia`
3. Enable/disable Google Analytics (opsional)
4. Klik **"Create Project"**

### 2. Setup Android App

1. Di Firebase Console, klik ikon **Android**
2. Masukkan package name: `com.firdausmntp.rupia`
3. Masukkan nickname: `Rupia Android`
4. Dapatkan SHA-1 untuk Google Sign-In:
   ```bash
   cd android
   ./gradlew signingReport
   ```
5. Copy SHA-1 dari debug certificate ke Firebase
6. Download `google-services.json`
7. Pindahkan ke: `android/app/google-services.json`

### 3. Enable Firebase Services

#### Authentication
1. Firebase Console → **Authentication** → **Get Started**
2. Tab **Sign-in method** → Enable **Google**
3. Masukkan support email → **Save**

#### Cloud Firestore
1. Firebase Console → **Firestore Database** → **Create database**
2. Pilih **Start in test mode**
3. Pilih region: `asia-southeast1` (Indonesia)
4. Klik **Enable**

### 4. Firestore Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data - hanya owner yang bisa akses
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Vaults - hanya member yang bisa akses
    match /vaults/{vaultId} {
      allow read, write: if request.auth != null && 
        request.auth.token.email in resource.data.memberEmails;
    }
    
    // Vault transactions
    match /vaults/{vaultId}/transactions/{txId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Setup iOS (Opsional)

1. Firebase Console → Klik ikon **Apple**
2. Bundle ID: `com.firdausmntp.rupia`
3. Download `GoogleService-Info.plist`
4. Pindahkan ke: `ios/Runner/GoogleService-Info.plist`
5. Tambahkan URL scheme di `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```

---

## 📁 Project Structure

```
rupia/
├── assets/
│   └── logo.png              # App logo (launcher icon source)
├── lib/
│   ├── main.dart              # Entry point
│   ├── core/
│   │   ├── constants/         # App constants, colors, config
│   │   ├── enums/             # TransactionType, MoodType, etc.
│   │   ├── router/            # GoRouter configuration
│   │   ├── services/          # Database service
│   │   ├── theme/             # App theme (Material 3)
│   │   └── utils/             # Formatters, helpers
│   ├── features/
│   │   ├── analytics/         # Charts & statistics
│   │   ├── auth/              # Login, profile, Google Sign-In
│   │   ├── budget/            # Budget management
│   │   ├── geofencing/        # Location-based reminders
│   │   ├── home/              # Home dashboard
│   │   ├── ocr/               # Receipt scanner (ML Kit)
│   │   ├── onboarding/        # First-time user setup
│   │   ├── settings/          # App settings
│   │   ├── sync/              # Google Sheets sync
│   │   ├── transactions/      # Transaction CRUD
│   │   └── vault/             # Shared vault feature
│   └── shared/
│       └── widgets/           # Reusable UI components
├── android/
│   └── app/
│       ├── google-services.json   # Firebase config (gitignored)
│       ├── build.gradle.kts
│       └── proguard-rules.pro     # R8/ProGuard rules
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist  # Firebase iOS (gitignored)
├── test/
├── pubspec.yaml
└── README.md
```

---

## 🔧 Build & Release

### Debug Build
```bash
flutter run
```

### Release Build (Android)
```bash
# APK
flutter build apk --release

# App Bundle (untuk Play Store)
flutter build appbundle --release
```

### Release Build (iOS)
```bash
flutter build ios --release
```

> ⚠️ **ProGuard/R8** sudah dikonfigurasi untuk release build dengan code shrinking dan obfuscation.

---

## 📋 Environment Modes

| Mode | Platform | Firebase | Database | Use Case |
|------|----------|----------|----------|----------|
| **Demo** | Web | ❌ Mock | Mock Data | UI Preview |
| **Development** | Mobile | ⚠️ Optional | SQLite | Development |
| **Production** | Mobile | ✅ Required | SQLite + Firestore | Production |

Untuk switch mode, edit `lib/core/constants/app_config.dart`:
```dart
static const bool useFirebase = true; // true untuk production
```

---

## 🐛 Troubleshooting

### `google-services.json` not found
- Pastikan file ada di `android/app/google-services.json`
- Bukan di root folder!

### Google Sign-In tidak muncul
- Pastikan SHA-1 sudah ditambahkan di Firebase Console
- Project Settings → Your Apps → Add fingerprint
- Jalankan `flutter clean` lalu `flutter run`

### Build error setelah ganti package name
```bash
flutter clean
flutter pub get
flutter run
```

### iOS build error
- Buka `ios/Runner.xcworkspace` di Xcode
- Product → Clean Build Folder
- Rebuild

---

## 🔄 Google Sheets Integration (Advanced)

### Status Implementasi
✅ **Backend Service**: Sudah tersedia lengkap di `lib/core/services/google_sheets_service.dart`  
⏳ **UI Dashboard**: Dalam pengembangan

### Fitur yang Tersedia
- OAuth 2.0 authentication dengan Google
- Create spreadsheet otomatis
- Batch export semua transaksi
- Auto-format dengan header terstruktur
- Sync status tracking
- Error handling & retry mechanism

### Setup Google Sheets Sync (Optional)

#### 1. Buat OAuth Client di Google Cloud Console
1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Buat project baru atau pilih project Firebase yang sudah ada
3. Enable **Google Sheets API** dan **Google Drive API**
4. Buat OAuth 2.0 Client ID:
   - Application type: **Android** / **iOS**
   - Package name: `com.firdausmntp.rupia`
5. Download credentials (Client ID & Client Secret)

#### 2. Configure di App
Edit `lib/core/constants/app_config.dart`:
```dart
static const String googleSheetsClientId = 'YOUR_CLIENT_ID';
static const String googleSheetsClientSecret = 'YOUR_CLIENT_SECRET';
```

#### 3. Usage (Backend)
```dart
// Initialize service
final service = GoogleSheetsService(transactionRepository);
await service.configure(
  clientId: AppConfig.googleSheetsClientId,
  clientSecret: AppConfig.googleSheetsClientSecret,
);

// Connect & create spreadsheet
final authUrl = service.getAuthorizationUrl();
// Open authUrl in browser, get code
await service.exchangeCodeForToken(code);
await service.createSpreadsheet();

// Sync transactions
await service.syncAllTransactions();
```

> **Note**: UI untuk Google Sheets akan ditambahkan di v2.0. Saat ini hanya backend API yang tersedia.

---

## 🗺️ Roadmap

### ✅ v1.0 (Legacy)

- [x] Transaction CRUD
- [x] Google Sign-In & Firebase Auth
- [x] Budget Management
- [x] Analytics Dashboard
- [x] Mood Analytics
- [x] Receipt OCR Scanner
- [x] Geofencing Reminders
- [x] Shared Vault (basic)
- [x] Cloud Sync (Firebase)

### ✅ v2.0

- [x] Google Sheets Sync (Full UI + Backend)
- [x] GitHub Actions (CI/CD Pipeline)
- [x] About Page & App Info
- [x] **Dark Mode** (Light/Dark/System themes)
- [x] Theme persistence (saved preference)
- [x] Material 3 Dark theme support

### ✅ v3.0 (Stable) - 100% Complete!

- [x] **Multi-Language Support** (ID/EN) - 200+ translations
- [x] **Debt Tracker** - Track hutang & piutang with reminders
- [x] **Budget Alerts** - Smart notifications (80%, 95%, 100%)
- [x] **Export to PDF/Excel** - Generate reports
- [x] **Gamification** - Points, levels, achievements, streaks
- [x] **Android Widgets** - Balance & budget widgets
- [x] **Simplified Config** - Auto Firebase detection
- [x] **APK Size Optimization** - 97MB → 34.8MB (64% reduction)

### ✅ v3.1

- [x] **Cloud Backup & Restore** - Firebase Storage integration
  - Automatic GZip compression
  - Backup history with metadata
  - Manual & auto backup/restore
  - Local export/import (.gz files)
- [x] **Custom Categories** - Personalize your categories
  - Add/Edit/Delete categories
  - Material icon picker (1000+ icons)
  - Custom color selection
  - Drag-and-drop reordering
- [x] **Database v3** - Enhanced schema with migrations
- [x] **minSdk 26** - Android 8.0+ support

### ✅ v3.2

- [x] Recurring transactions
- [x] Multi-currency support
- [x] Split transactions
- [x] Bill reminders
- [x] Dark theme enhancements (AMOLED Black mode)

### ✅ v3.3 (Current)

- [x] **Firebase Packages Upgrade** - All packages updated to latest versions
  - firebase_core ^4.3.0, firebase_auth ^6.1.3
  - cloud_firestore ^6.1.1, firebase_storage ^13.0.5
- [x] **iOS Deployment Target** - Updated to iOS 15.0+
- [x] **Dependency Updates** - printing ^5.14.2, open_file ^3.5.10
- [x] **Split APK Workflow** - Enhanced GitHub Actions for architecture-specific APKs

### 🔜 v3.4 (Planned)

- [ ] **iOS Widgets** - WidgetKit integration
- [ ] **Two-Way Sheets Sync** - Import from Google Sheets
- [ ] **AI Receipt Categorization** - TensorFlow Lite ML model
- [ ] **Investment Tracker** - Track investments & portfolios
- [ ] **Financial Goals** - Set and track savings goals

---

## 🚀 Release & CI/CD

### GitHub Actions Workflows

Project ini sudah dilengkapi dengan automated CI/CD pipeline:

**Continuous Integration** ([ci.yml](.github/workflows/ci.yml)):
- ✅ Code analysis & formatting check
- ✅ Run unit tests dengan coverage
- ✅ Build Android, iOS, dan Web
- ✅ Upload artifacts untuk testing

**Release Pipeline** ([release.yml](.github/workflows/release.yml)):
- 📦 Build signed APK & AAB untuk Android
- 🌐 Build Web bundle
- 🚀 Auto-create GitHub Release
- 📥 Upload semua artifacts (APK, AAB, Web)

### Cara Release

```bash
# 1. Update version di pubspec.yaml
# version: 1.0.1+2

# 2. Commit changes
git add .
git commit -m "Release v1.0.1"

# 3. Create & push tag
git tag v1.0.1
git push origin main --tags

# GitHub Actions akan otomatis:
# - Build APK, AAB, dan Web
# - Create release di GitHub
# - Upload semua artifacts
```

### Download APK

Setelah release, APK bisa didownload di:
`https://github.com/firdausmntp/rupia/releases`

---

## 🐛 Troubleshooting

### Build Error: Android SDK/NDK Version

Jika ada error tentang SDK atau NDK version, sudah diperbaiki di `build.gradle.kts`:
- `compileSdk = 36`
- `ndkVersion = "28.2.13676358"`

Clean project dan rebuild:
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter build apk --release
```

### Flutter Path Issue (`D:\flutter` not found)

Jika masih ada referensi ke path lama:
```bash
# 1. Clean cache
flutter clean
rd /s /q .dart_tool

# 2. Clean Gradle
cd android
gradlew clean
cd ..

# 3. Rebuild
flutter pub get
flutter build apk --release
```

Contributions are welcome! Silakan buat issue atau pull request.

1. Fork repository
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👨‍💻 Author

**Firdaus** - [@firdausmntp](https://github.com/firdausmntp)

---

<p align="center">
  Made with ❤️ and Flutter
</p>
