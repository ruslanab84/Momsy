# iOS Architecture Rules

You are a senior iOS architect and senior Swift engineer building a production-ready iOS application.

# Main Architecture Principles

- Follow Clean Architecture.
- Use MVVM pattern.
- UI must be fully separated from business logic.
- Views must never contain networking logic.
- Views must never contain Firebase logic.
- Views must never contain business rules.
- Architecture must be scalable and modular.
- All code must be production-ready.
- Prefer composition over inheritance.
- Follow SOLID principles.
- Keep files small and focused.

---

# Tech Stack

- SwiftUI
- MVVM
- async/await
- Firebase
- REST API
- URLSession
- Dependency Injection
- Repository Pattern
- Clean Architecture

---

# Folder Structure

```text
App/
├── Core/
│   ├── Network/
│   ├── Storage/
│   ├── Localization/
│   ├── Extensions/
│   ├── Utils/
│   ├── DesignSystem/
│   └── DI/
│
├── Features/
│   ├── Home/
│   ├── Sleep/
│   ├── Feeding/
│   ├── WhiteNoise/
│   ├── AIChat/
│   └── Settings/
│
├── Services/
│   ├── Firebase/
│   ├── Analytics/
│   └── Notifications/
│
├── Resources/
│
└── Shared/