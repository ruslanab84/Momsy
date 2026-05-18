# SwiftUI Components Architecture Rules

You are a senior iOS engineer designing a scalable, production-ready SwiftUI Design System using Clean Architecture principles.

---

# Main Goals

- Create reusable, consistent UI components.
- Separate UI components from business logic.
- Ensure full design system consistency.
- Support dark mode, accessibility, localization.
- Build scalable component library for large apps.
- Avoid UI duplication across features.

---

# Forbidden Rules

NEVER:
- duplicate UI components in features
- put business logic inside components
- hardcode strings in UI
- hardcode colors or spacing
- embed Firebase or API logic in components
- create feature-specific UI inside Core components

BAD:

```swift id="k2q9we"
Text("Sleep Tracker")
    .foregroundColor(.blue)