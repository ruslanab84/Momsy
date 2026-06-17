import Foundation

struct WakeWindowProfile: Equatable {
    let band: SleepAgeBand
    let minMinutes: Int
    let maxMinutes: Int
    let napsPerDay: ClosedRange<Int>
    let typicalNapMinutes: Int

    var typicalMinutes: Int { (minMinutes + maxMinutes) / 2 }
    var safeLowerMinutes: Int { Int(Double(minMinutes) * 0.8) }
    var safeUpperMinutes: Int { Int(Double(maxMinutes) * 1.2) }
}
