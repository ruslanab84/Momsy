// Momsy/Services/Firebase/BabySync/CloudSyncTimestamped.swift
import FirebaseFirestore

/// A synced log DTO carrying a last-write-wins modification stamp. Used by the incremental
/// downloader to advance the per-collection high-water mark. `updatedAt` is server-assigned
/// (`@ServerTimestamp`) on write and may be `nil` for legacy docs written before the field existed.
protocol CloudSyncTimestamped {
    var updatedAt: Timestamp? { get }
}

extension FeedingLogDTO:     CloudSyncTimestamped {}
extension SleepLogDTO:       CloudSyncTimestamped {}
extension DiaperLogDTO:      CloudSyncTimestamped {}
extension QuickEventLogDTO:  CloudSyncTimestamped {}
extension PumpingLogDTO:     CloudSyncTimestamped {}
extension DiaryLogDTO:       CloudSyncTimestamped {}
extension MeasurementLogDTO: CloudSyncTimestamped {}
extension VaccinationLogDTO: CloudSyncTimestamped {}
extension FoodDiaryLogDTO:   CloudSyncTimestamped {}
extension TemperatureLogDTO: CloudSyncTimestamped {}
extension WaterIntakeLogDTO: CloudSyncTimestamped {}
extension LeapLogDTO:        CloudSyncTimestamped {}
extension DoctorVisitLogDTO: CloudSyncTimestamped {}
