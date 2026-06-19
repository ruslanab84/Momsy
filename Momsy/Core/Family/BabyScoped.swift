import Foundation

/// Every per-child SwiftData log record carries a `babyId`. This protocol lets
/// cross-cutting operations (legacy backfill, cascade delete on child removal)
/// treat them uniformly without enumerating each concrete type's API.
protocol BabyScoped: AnyObject {
    var babyId: UUID { get set }
}

extension SleepRecord: BabyScoped {}
extension FeedingRecord: BabyScoped {}
extension DiaperRecord: BabyScoped {}
extension StoolRecord: BabyScoped {}
extension DiaryItemRecord: BabyScoped {}
extension PumpingRecord: BabyScoped {}
extension WalkRecord: BabyScoped {}
extension BathRecord: BabyScoped {}
extension VaccinationRecord: BabyScoped {}
extension MeasurementRecord: BabyScoped {}
extension TemperatureRecord: BabyScoped {}
extension DoctorVisitRecord: BabyScoped {}
extension ComplementaryFoodRecord: BabyScoped {}
extension MomSleepRecord: BabyScoped {}
extension MomMoodRecord: BabyScoped {}
extension WaterIntakeRecord: BabyScoped {}
extension LeapProgressRecord: BabyScoped {}
