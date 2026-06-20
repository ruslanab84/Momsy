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
        let normalized = raw?.trimmingCharacters(in: .whitespaces).uppercased()
        return (normalized?.isEmpty == false) ? normalized : nil
    }
}
