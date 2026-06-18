# Software Design and Architecture Analysis

## Overview

Momsy is built using Clean Architecture and MVVM to ensure scalability, maintainability, and testability.

## Architectural Principles

- Separation of concerns
- Dependency inversion
- Modular structure
- Reusable components
- Offline-first approach

## Layers

### Presentation Layer
Contains SwiftUI Views and ViewModels.

### Domain Layer
Contains business rules and use cases.

### Data Layer
Contains repositories and Firebase integrations.

### Infrastructure Layer
Handles networking, analytics, logging, and external services.

## AI Architecture

Gemini (via FirebaseAI) is used for non-interactive generation only — daily tips
and weekly insights. There is no free-form user chat. Each request is composed of:
- Prompt Builder — app-built system instruction + context-derived user prompt
- Safety Filters — Gemini `safetySettings` (harassment, hate speech, sexually
  explicit, dangerous content) block harmful generations at the model backend,
  independent of the prompt
- Response Formatter — tolerant decode of model output

## Firebase Architecture

Services used:
- Authentication
- Firestore
- Analytics
- Crashlytics
- Remote Config

## Security

- Protected Firestore rules
- Secure API key storage
- Backend-enforced Gemini safety filters on all AI generation
- User data isolation

## Scalability

Architecture designed for:
- Subscription system
- Multi-language support
- AI expansion
- Offline sync
- Cross-platform support

## Conclusion

Current architecture supports rapid development while maintaining production-level scalability and maintainability.