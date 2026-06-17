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
}
