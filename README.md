# 🗂️ Portfolio Admin App

A modern Flutter admin dashboard for managing portfolio content, built with Firebase Realtime Database and Firebase Cloud Messaging.

---

## 📱 Features

- **🔐 Authentication** — Secure login via Google Sign-In
- **📊 Overview Dashboard** — Quick stats and navigation to all sections
- **👤 Profile Management** — Edit personal info, title, bio, and social links
- **💼 Projects** — Add, edit, and delete portfolio projects
- **🛠️ Skills** — Manage skill categories and proficiency levels
- **🎓 Education** — Track academic background
- **💼 Experience** — Manage work experience entries
- **📜 Certificates** — Add professional certifications
- **🏆 Achievements** — Highlight key accomplishments
- **💬 Messages** — View contact messages from portfolio visitors
- **🔔 Push Notifications** — Real-time FCM notifications for new messages
- **⚙️ Settings** — App configuration and preferences

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **Firebase Auth** | Google Sign-In authentication |
| **Firebase Realtime Database** | Data storage and real-time sync |
| **Firebase Cloud Messaging** | Push notifications |
| **Firebase Cloud Functions** | Serverless notification triggers |
| **Provider** | State management |
| **Google Fonts** | Typography |
| **FL Chart** | Analytics charts |
| **Font Awesome** | Icons |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.11.0`
- Firebase project configured
- Node.js (for Firebase Functions)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/MoaazBesher/portfolioAdminApp.git
   cd portfolioAdminApp
   ```

2. **Add Firebase configuration**

   Download your `google-services.json` from the Firebase Console and place it at:
   ```
   android/app/google-services.json
   ```
   > ⚠️ This file is excluded from version control for security reasons.

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Deploy Firebase Functions**
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
lib/
├── core/
│   └── theme/          # App theme and styling
├── models/             # Data models
├── providers/          # State management (Provider)
├── services/           # Firebase service layer
├── ui/
│   ├── auth/           # Login screen
│   ├── components/     # Reusable UI components
│   └── dashboard/      # Main dashboard & tabs
│       └── tabs/       # Individual content tabs
├── admin_notifications_service.dart
└── main.dart
functions/              # Firebase Cloud Functions (Node.js)
```

---

## 🔒 Security Notes

- `google-services.json` is **not** committed — add it manually after cloning
- The Firebase Realtime Database is protected with security rules (`database.rules.json`)
- This app is intended for **private/admin use only**

---

## 👤 Author

**Moaaz Besher** — [GitHub](https://github.com/MoaazBesher)
