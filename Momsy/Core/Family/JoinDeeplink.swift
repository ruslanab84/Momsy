import Foundation

/// Parses the family-invite deeplink `momsy://join?code=XXXX`.
enum JoinDeeplink {
    /// The normalized invite code (trimmed, uppercased) for a join URL, else `nil`.
    static func code(from url: URL) -> String? {
        guard url.scheme == "momsy", url.host == "join" else { return nil }
        let raw = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "code" }?
            .value
        return normalizedInviteCode(raw)
    }

    /// Canonical invite code for raw user-entered text, which may be a bare code
    /// (`MOMSY-XXXX`) or a full `momsy://join?code=…` link the user pasted into the
    /// join field. Returns `nil` when no usable code can be extracted — including any
    /// other URL/path, which must never reach Firestore as a `//`-containing doc id.
    static func normalize(rawCode input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), let extracted = code(from: url) {
            return extracted
        }
        return normalizedInviteCode(trimmed)
    }

    private static func normalizedInviteCode(_ raw: String?) -> String? {
        let normalized = raw?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let normalized, !normalized.isEmpty, !normalized.contains("/") else { return nil }
        guard normalized != ".", normalized != ".." else { return nil }
        guard !(normalized.hasPrefix("__") && normalized.hasSuffix("__")) else { return nil }
        return normalized
    }
}
