import Foundation

/// Static, offline care-guide content shown in Doctor → Tips.
///
/// ID ranges are namespaced per category so new entries never renumber existing ones:
/// feeding 1000+, sleep 1100+, hygiene 1200+, comfort 1300+,
/// development 1400+, safety 1500+, parent 1600+.
///
/// v1 is authored in English only. Adding a language is a pure data change:
/// replace a string literal with `.init(en: …, ru: …)` in place.
enum CareTipsCatalog {
    static let all: [CareTip] = visible(feeding + sleep + hygiene + comfort + development + safety + parent)

    /// Release ships only tips backed by a publishable source; DEBUG keeps
    /// unsourced tips visible so content reviewers can still see them.
    static func visible(_ tips: [CareTip]) -> [CareTip] {
        #if DEBUG
        return tips
        #else
        return publishable(tips)
        #endif
    }

    static func publishable(_ tips: [CareTip]) -> [CareTip] {
        tips.filter(\.isPublishable)
    }

    static func tips(in category: CareTipCategory) -> [CareTip] {
        all.filter { $0.category == category }
    }

    static func tip(id: Int) -> CareTip? {
        all.first { $0.id == id }
    }
}
