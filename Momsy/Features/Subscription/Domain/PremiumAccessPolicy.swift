enum PremiumAccessState: Equatable {
    case resolving
    case requiresPurchase
    case premium
}

enum PremiumAccessPolicy {
    static func state(
        personalPremium: Bool,
        familyPremium: Bool,
        isResolving: Bool
    ) -> PremiumAccessState {
        if personalPremium || familyPremium { return .premium }
        return isResolving ? .resolving : .requiresPurchase
    }
}
