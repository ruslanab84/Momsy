import Foundation

enum AppLegalLinks {
    static let privacyPolicyURL = URL(string: "https://ruslanab84.github.io/-momsy-site/")
    static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    static let feedbackEmail = "momsy.app.support@gmail.com"

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
