# WriteIt 📖

A mobile-first publishing platform inspired by Medium, built with Flutter.
Designed for writers and readers who value clean reading, collaboration, and engagement.

## 🧠 About

WriteIt is a production-grade publishing mobile application that allows users to:
- Write and publish articles
- Read long-form content in a clean, distraction-free UI
- Engage via comments and likes
- Collaborate with other writers

The app is optimized for mobile-first writing and reading experiences and is built with scalability and maintainability in mind.

## 📸 Screenshots

<table>
  <tr>
    <td align="center style="padding: 60px;">
      <img src="https://github.com/user-attachments/assets/b5a8babc-7f2f-4328-b564-50e02c286c48" width="250" />
      <br/>
      <b>Home Feed</b>
    </td>
    <td align="center style="padding: 60px;">
      <img src="https://github.com/user-attachments/assets/f3a7b30e-77c6-49f9-9db8-ae76578d8189" width="250" />
      <br/>
      <b>Article Detail</b>
    </td>
  </tr>
  <tr>
    <td align="center style="padding: 60px;">
      <img src="https://github.com/user-attachments/assets/fdb2ace2-28ea-4a49-aef3-8afb0d813401" width="250" />
      <br/>
      <b>Comments</b>
    </td>
    <td align="center style="padding: 60px;">
      <img src="https://github.com/user-attachments/assets/3036797e-6992-4bc4-93ef-3ee13f284f95" width="250" />
      <br/>
      <b>Welcome screen</b>
    </td>
  </tr>
</table>

## ✨ Features

- 🔐 Firebase Authentication (Email / Google)
- ✍️ Rich-text article creation
- 📖 Clean article reading experience
- ❤️ Likes / Claps system
- 💬 Commenting with replies
- 📊 Writer analytics (views, likes)
- 🔄 Offline-friendly drafts

## 🏗 Architecture

- MVVM architecture
- Repository pattern
- Clean separation of UI, domain, and data layers
- Firebase as backend (Auth, Firestore, Storage)

State Management:
- Riverpod / Provider / Bloc (choose what you used)

Why MVVM?
- Clear separation of concerns
- Lifecycle-aware state management
- Scales well as features grow


## 🛠 Tech Stack

- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Markdown rendering
- REST-friendly architecture


## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x)
- Firebase project
- Android Studio / VS Code

### Installation
```bash
git clone https://github.com/Stephenayor/writeit.git
cd writeit
flutter pub get
flutter run

## 🛣 Roadmap

- Collaborative writing
- Writer monetization
- Push notifications
- Play Store release





