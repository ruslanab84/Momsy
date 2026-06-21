import Foundation

final class DeterministicSleepForecastEngine: SleepForecastEngine {

    private enum Const {
        static let minSamplesForPersonalization = 4
        static let highConfidenceSamples        = 8
        static let maxObservedWeight            = 0.7
        static let weightSampleDivisor          = 10.0
        static let minBufferMinutes             = 15.0
        static let bufferFraction               = 0.15
        static let eveningBedtimeHour           = 18
        static let nightStartHour               = 19
        static let morningWakeHour              = 6
    }

    func predict(birthDate: Date, entries: [SleepEntry], now: Date) -> SleepPrediction? {
        let ageDays = Self.ageInDays(birthDate, now)
        guard ageDays >= 0 else { return nil }
        let profile = WakeWindowCatalog.profile(forAgeInDays: ageDays)

        let samples = observedWakeWindows(entries, profile: profile, now: now)
        let (windowMinutes, basis) = personalizedWindow(profile: profile, samples: samples)

        guard let anchor = onsetAnchor(entries, profile: profile, now: now) else { return nil }
        let onset  = anchor.addingMinutes(windowMinutes)
        let buffer = bufferMinutes(forWindow: windowMinutes)

        guard let kind = classify(onset: onset, entries: entries, profile: profile, now: now) else { return nil }

        let asleepNow = isSleepingNow(entries)
        let awake = asleepNow ? nil : minutesAwake(entries, now: now)

        return SleepPrediction(
            kind: kind,
            windowStart: onset.addingMinutes(-buffer),
            predictedOnset: onset,
            windowEnd: onset.addingMinutes(buffer),
            confidence: confidence(sampleCount: samples.count),
            basis: basis,
            napsRemaining: napsRemaining(entries, profile: profile, now: now),
            isOverdue: !asleepNow && onset <= now,
            minutesAwake: awake
        )
    }

    // MARK: - Готово
    private static func ageInDays(_ birthDate: Date, _ now: Date) -> Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: now).day ?? -1
    }
    private func bufferMinutes(forWindow windowMinutes: Int) -> Int {
        Int(max(Const.minBufferMinutes, Const.bufferFraction * Double(windowMinutes)))
    }
    private func confidence(sampleCount n: Int) -> PredictionConfidence {
        if n >= Const.highConfidenceSamples { return .high }
        if n >= Const.minSamplesForPersonalization { return .medium }
        return .low
    }

    // MARK: - §4.1
    private func observedWakeWindows(_ entries: [SleepEntry], profile: WakeWindowProfile, now: Date) -> [Int] {
        let cal = Calendar.current
        let completed = entries.filter { $0.endDate != nil }.sorted { $0.startDate < $1.startDate }
        guard completed.count >= 2 else { return [] }

        let lower = Double(profile.minMinutes) * 0.5
        let upper = Double(profile.maxMinutes) * 1.5

        var gaps: [Int] = []
        for i in 1..<completed.count {
            guard let aEnd = completed[i - 1].endDate else { continue }
            let bStart = completed[i].startDate
            guard cal.isDate(aEnd, inSameDayAs: bStart) else { continue }
            let aHour = calendarHour(aEnd)
            let bHour = calendarHour(bStart)
            guard aHour >= Const.morningWakeHour, aHour < Const.nightStartHour,
                  bHour >= Const.morningWakeHour, bHour < Const.nightStartHour else { continue }
            let gap = Int(bStart.timeIntervalSince(aEnd) / 60)
            if Double(gap) >= lower, Double(gap) <= upper { gaps.append(gap) }
        }
        return gaps
    }

    // MARK: - §4.2
    private func personalizedWindow(profile: WakeWindowProfile, samples: [Int]) -> (minutes: Int, basis: PredictionBasis) {
        let n = samples.count
        guard n >= Const.minSamplesForPersonalization else {
            return (profile.typicalMinutes, .ageOnly)
        }
        let mean: Double
        if n >= 5 {
            let sorted = samples.sorted()
            let trimmed = sorted.dropFirst().dropLast()
            mean = Double(trimmed.reduce(0, +)) / Double(trimmed.count)
        } else {
            mean = Double(samples.reduce(0, +)) / Double(n)
        }
        let w = min(Double(n) / Const.weightSampleDivisor, Const.maxObservedWeight)
        let blended = w * mean + (1 - w) * Double(profile.typicalMinutes)
        let clamped = min(max(Int(blended.rounded()), profile.safeLowerMinutes), profile.safeUpperMinutes)
        return (clamped, .personalized(samples: n))
    }

    // MARK: - §4.3
    private func onsetAnchor(_ entries: [SleepEntry], profile: WakeWindowProfile, now: Date) -> Date? {
        if let latest = entries.max(by: { $0.startDate < $1.startDate }) {
            if latest.endDate == nil {
                return latest.startDate.addingMinutes(profile.typicalNapMinutes)
            }
            let lastCompleted = entries
                .filter { $0.endDate != nil }
                .max(by: { ($0.endDate ?? .distantPast) < ($1.endDate ?? .distantPast) })
            return lastCompleted?.endDate
        }
        // Нет логов вообще: сегодня в morningWakeHour, если now уже позже; иначе now.
        let morning = Calendar.current.date(
            bySettingHour: Const.morningWakeHour, minute: 0, second: 0, of: now
        ) ?? now
        return now > morning ? morning : now
    }

    // MARK: - §4.4
    private func napsTakenToday(_ entries: [SleepEntry], now: Date) -> Int {
        let cal = Calendar.current
        return entries.filter { entry in
            guard cal.isDate(entry.startDate, inSameDayAs: now) else { return false }
            let hour = calendarHour(entry.startDate)
            return hour >= Const.morningWakeHour && hour < Const.nightStartHour
        }.count
    }

    private func napsRemaining(_ entries: [SleepEntry], profile: WakeWindowProfile, now: Date) -> Int? {
        max(0, profile.napsPerDay.upperBound - napsTakenToday(entries, now: now))
    }

    private func isSleepingNow(_ entries: [SleepEntry]) -> Bool {
        entries.max(by: { $0.startDate < $1.startDate })?.endDate == nil && !entries.isEmpty
    }

    /// Minutes the baby has been awake since the last completed sleep ended.
    /// `nil` when no sleep has ended yet or the timestamp is in the future.
    private func minutesAwake(_ entries: [SleepEntry], now: Date) -> Int? {
        guard let lastEnd = entries.compactMap(\.endDate).max() else { return nil }
        let mins = Int(now.timeIntervalSince(lastEnd) / 60)
        return mins >= 0 ? mins : nil
    }

    private func classify(onset: Date, entries: [SleepEntry], profile: WakeWindowProfile, now: Date) -> SleepPredictionKind? {
        let h = calendarHour(onset)
        if h >= Const.nightStartHour || h < Const.morningWakeHour { return nil }
        let remaining = napsRemaining(entries, profile: profile, now: now) ?? 0
        if remaining <= 0 || h >= Const.eveningBedtimeHour { return .bedtime }
        return .nap
    }

    private func calendarHour(_ date: Date) -> Int { Calendar.current.component(.hour, from: date) }
}

private extension Date {
    func addingMinutes(_ minutes: Int) -> Date { addingTimeInterval(TimeInterval(minutes * 60)) }
}
