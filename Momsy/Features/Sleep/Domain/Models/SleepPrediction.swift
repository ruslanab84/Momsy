import Foundation

enum SleepPredictionKind: Equatable { case nap, bedtime }
enum PredictionConfidence: Equatable { case low, medium, high }
enum PredictionBasis: Equatable { case ageOnly, personalized(samples: Int) }

struct SleepPrediction: Equatable {
    let kind: SleepPredictionKind
    let windowStart: Date
    let predictedOnset: Date
    let windowEnd: Date
    let confidence: PredictionConfidence
    let basis: PredictionBasis
    let napsRemaining: Int?
    /// The ideal window has already elapsed: the baby is awake past it and
    /// should be settled now. `predictedOnset` then points at a past time and
    /// the UI shows an "overdue" state instead of a future clock time.
    let isOverdue: Bool
    /// Minutes since the last completed sleep ended. `nil` when the baby is
    /// currently asleep or no prior sleep is known.
    let minutesAwake: Int?
}
