import SwiftUI

struct NextSleepCard: View {
    let prediction: SleepPrediction
    @EnvironmentObject var loc: LocalizationManager

    private var strings: L10n { loc.strings }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private func time(_ date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }

    private var title: String {
        switch prediction.kind {
        case .nap:     return strings.sleepForecastNapTitle
        case .bedtime: return strings.sleepForecastBedtimeTitle
        }
    }

    private var accent: Color {
        if prediction.isOverdue { return .bbCoralDeep }
        return prediction.kind == .bedtime ? .bbLilacDeep : .bbSkyDeep
    }

    private var icon: String {
        if prediction.isOverdue { return "moon.zzz.fill" }
        return prediction.kind == .bedtime ? "moon.stars.fill" : "powersleep"
    }

    private var awakeText: String? {
        guard let mins = prediction.minutesAwake, mins > 0 else { return nil }
        let dur = strings.sleepDurationFormatted(h: mins / 60, m: mins % 60)
        return strings.sleepForecastAwakeFor(dur)
    }

    private var confidenceLabel: String {
        switch prediction.confidence {
        case .low:    return strings.sleepForecastConfidenceLow
        case .medium: return strings.sleepForecastConfidenceMedium
        case .high:   return strings.sleepForecastConfidenceHigh
        }
    }

    private var basisLabel: String {
        switch prediction.basis {
        case .ageOnly:      return strings.sleepForecastBasisAge
        case .personalized: return strings.sleepForecastBasisPersonalized
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(accent)
                .frame(width: 44, height: 44)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if prediction.isOverdue {
                overdueContent
            } else {
                forecastContent
            }
        }
        .bbCard()
    }

    private var forecastContent: some View {
        Group {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Text(time(prediction.predictedOnset))
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(strings.sleepForecastRange(time(prediction.windowStart), time(prediction.windowEnd)))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                BBPill(text: confidenceLabel, color: accent.opacity(0.14), fg: accent, size: 11)
                Text(basisLabel)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
        }
    }

    private var overdueContent: some View {
        Group {
            VStack(alignment: .leading, spacing: 4) {
                Text(strings.sleepForecastOverdueTitle)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Text(strings.sleepForecastOverdueAction)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                if let awakeText {
                    Text(awakeText)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
            }

            Spacer(minLength: 0)

            BBPill(text: strings.sleepForecastOverduePill, color: accent.opacity(0.14), fg: accent, size: 11)
        }
    }
}
