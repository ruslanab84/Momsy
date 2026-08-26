import Foundation

enum AppLegalLinks {
    static let privacyPolicyURL = URL(string: "https://ruslanab84.github.io/-momsy-site/")
    static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    static let feedbackEmail = "momsy.app.support@gmail.com"
    static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")

    /// Source of the growth tables in `WHOGrowthStandards.swift`, surfaced in the
    /// tracking chart's methodology sheet so the WHO attribution is verifiable.
    static let whoGrowthStandardsURL = URL(string: "https://www.who.int/tools/child-growth-standards/standards")

    /// Source of the routine immunization schedule in `WHOSchedule.swift`, surfaced
    /// in the vaccination list so the WHO attribution is verifiable.
    static let whoImmunizationScheduleURL = URL(string: "https://www.who.int/teams/immunization-vaccines-and-biologicals/policies/who-recommendations-for-routine-immunization")

    /// The EPDS may be reproduced free of charge only while the authors, the title
    /// and the source are quoted on every copy, so this line ships with the
    /// questionnaire itself. It stays in English in every language: it is a
    /// bibliographic reference, not translatable copy.
    static let epdsCitation = "Cox, J.L., Holden, J.M. & Sagovsky, R. (1987). Detection of postnatal depression: Development of the 10-item Edinburgh Postnatal Depression Scale. British Journal of Psychiatry, 150, 782\u{2013}786. \u{00A9} 1987 The Royal College of Psychiatrists."

    static let appStoreID = "6784641297"

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
