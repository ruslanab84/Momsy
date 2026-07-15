import Foundation

enum AppLegalLinks {
    static let privacyPolicyURL = URL(string: "https://ruslanab84.github.io/-momsy-site/")
    static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    static let feedbackEmail = "momsy.app.support@gmail.com"

    // TODO: заполнить после создания записи в App Store Connect
    static let appStoreID = ""

    static var appStoreReviewURL: URL? {
        guard !appStoreID.isEmpty else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")
    }

    static var feedbackURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = feedbackEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Momsy Feedback")
        ]
        return components.url
    }
}
