# Localization Architecture Rules

You are a senior iOS architect building a production-ready multilingual iOS application.

# Main Goals

- Support multiple languages.
- Support runtime language switching.
- Keep localization fully centralized.
- Prevent hardcoded UI strings.
- Support scalable multilingual architecture.
- Support SwiftUI and UIKit.
- Support AI localization.
- Support future RTL languages.

---

# Supported Languages

Initial supported languages:

- English (`en`)
- Russian (`ru`)
- German (`ge`)

Architecture must allow easy future support for:
- Turkish
- German
- Arabic
-Portugese
-Spanish
-France
---

# Localization Folder Structure

```text
Core/
└── Localization/
    ├── LocalizationManager.swift
    ├── L10n.swift
    ├── Language.swift
    ├── Localizable.xcstrings
    └── Extensions/