# FaceGate 🔐

A role-based personnel entry system developed with **Flutter** and **Firebase**, featuring:

- Admin and personnel roles
- Admin approval for new users
- Entry/Exit logging with timestamps
- Face recognition support
- Role-based screen routing
- Camera integration for capturing personnel images

---

## 🚀 Features

- **Admin Panel**
  - View and approve/reject pending personnel
  - View entry/exit logs by user and date
- **Personnel Panel**
  - Secure login with email/password
  - Mark entry or exit (only once per day)
  - Personalized welcome screen
- **Authentication & Database**
  - Firebase Auth for secure login
  - Firestore for storing users and logs
  - Firebase Storage for face image uploads
- **Camera + Face Recognition (Coming Soon...)**

---

## 📱 Technologies Used

- [Flutter](https://flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/products/auth)
- [Cloud Firestore](https://firebase.google.com/products/firestore)
- [Firebase Storage](https://firebase.google.com/products/storage)
- [Camera Plugin](https://pub.dev/packages/camera)
- [BLoC](https://pub.dev/packages/flutter_bloc)
- [GoRouter](https://pub.dev/packages/go_router)

---

## 🛠️ Setup

```bash
git clone https://github.com/edabalci/facegate.git
cd facegate
flutter pub get
flutter run
