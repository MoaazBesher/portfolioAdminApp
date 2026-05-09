# Portfolio Admin

A Flutter-based admin dashboard for managing portfolio content. Built with Firebase Realtime Database and Firebase Cloud Messaging, this app provides a secure interface for authenticated administrators to manage all aspects of a personal portfolio.

---

## Features

- **Authentication** — Secure Google Sign-In integration
- **Dashboard** — Overview with quick stats and navigation to all sections
- **Profile Management** — Edit personal information, title, bio, and social links
- **Projects** — Create, update, and delete portfolio projects
- **Skills** — Manage skill categories and proficiency levels
- **Education** — Track academic background and qualifications
- **Experience** — Manage work history entries
- **Certificates** — Add and manage professional certifications
- **Achievements** — Highlight key accomplishments
- **Messages** — View and manage contact messages from portfolio visitors
- **Push Notifications** — Real-time Firebase Cloud Messaging notifications for new messages
- **Settings** — App configuration and preferences

---

## Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI framework |
| **Firebase Auth** | Authentication (Google Sign-In) |
| **Firebase Realtime Database** | Data storage and real-time sync |
| **Firebase Cloud Messaging** | Push notifications |
| **Firebase Cloud Functions** | Serverless notification triggers |
| **Provider** | State management |
| **Google Fonts** | Typography |
| **FL Chart** | Data visualization |
| **Font Awesome** | Iconography |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.0`
- A configured Firebase project
- Node.js (for Firebase Cloud Functions)

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

   This file is excluded from version control for security reasons.

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

## Project Structure

```
lib/
├── core/
│   └── theme/              # App theme and styling
├── models/                 # Data models
├── providers/              # State management (Provider)
├── services/               # Firebase service layer
├── ui/
│   ├── auth/               # Login screen
│   ├── components/         # Reusable UI components
│   └── dashboard/          # Main dashboard and tabs
│       └── tabs/           # Individual content management tabs
├── admin_notifications_service.dart
└── main.dart
functions/                  # Firebase Cloud Functions (Node.js)
```

---

## Security Notes

- `google-services.json` and `GoogleService-Info.plist` are excluded from version control
- Firebase Realtime Database is protected by custom security rules (`database.rules.json`)
- This application is intended for private / administrative use only
- Environment-specific configuration files (`.env`, `.env.*`) are not committed

---

## Author

**Moaaz Besher** — [GitHub](https://github.com/MoaazBesher)
