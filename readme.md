# Momsy

AI-powered baby care assistant built with SwiftUI and Firebase.

## Features

- Baby tracking
- AI assistant
- Sleep analytics
- Feeding logs
- Growth tracking
- Multi-language support

## Tech Stack

- SwiftUI
- Firebase
- Firestore
- MVVM
- Clean Architecture

## Setup

1. Clone the repository
2. **Add Firebase config** (never committed — listed in `.gitignore`):
   - Open [Firebase Console](https://console.firebase.google.com) → Project Settings → Your apps → iOS
   - Download `GoogleService-Info.plist`
   - Place it at `Momsy/Momsy/GoogleService-Info.plist`
   - See `Momsy/GoogleService-Info.plist.template` for the expected structure
3. Open `Momsy.xcodeproj` in Xcode and run on simulator or device

## Architecture

Project follows Clean Architecture principles.

## License

Private.