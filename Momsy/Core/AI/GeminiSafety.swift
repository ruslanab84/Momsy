import FirebaseAI

/// Server-side content safety filters applied to every Gemini request.
///
/// System prompts alone constrain topic but can be circumvented; these
/// `SafetySetting`s are enforced by the model backend and block harmful
/// generations regardless of how the prompt is phrased. Medium-and-above is
/// the appropriate threshold for a parenting app whose only model inputs are
/// app-built context (daily tips, weekly insights), never free-form user chat.
enum GeminiSafety {
    static let settings: [SafetySetting] = [
        SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
        SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove),
        SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockMediumAndAbove),
        SafetySetting(harmCategory: .dangerousContent, threshold: .blockMediumAndAbove),
    ]
}
