import Foundation

enum CitationPolicy {
    static let allowedPublishers: Set<MedicalPublisher> = [.who, .nhs, .aap, .peerReviewed]

    /// Medical copy may ship only when it cites at least one source and every
    /// cited source resolves in the catalog to an allowed publisher.
    static func isPublishable(_ ids: [MedicalSourceID]) -> Bool {
        !ids.isEmpty && ids.allSatisfy { id in
            MedicalSourceCatalog.source(id).map { allowedPublishers.contains($0.publisher) } ?? false
        }
    }
}
