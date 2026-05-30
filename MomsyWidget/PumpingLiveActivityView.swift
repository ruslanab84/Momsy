import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

private func pumpSideLabel(_ side: String) -> String {
    switch side {
    case "left":  return NSLocalizedString("Left", comment: "")
    case "right": return NSLocalizedString("Right", comment: "")
    default:      return NSLocalizedString("Both", comment: "")
    }
}

struct PumpingLockScreenView: View {
    let context: ActivityViewContext<PumpingActivityAttributes>

    var body: some View {
        ZStack {
            BabyPatternBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "drop.circle.fill")
                        .foregroundStyle(.pink)
                    Text(context.attributes.babyName.isEmpty
                         ? NSLocalizedString("Pumping", comment: "")
                         : context.attributes.babyName)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Text(NSLocalizedString("Pumping", comment: ""))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack {
                    Label {
                        Text(pumpSideLabel(context.attributes.side))
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    } icon: {
                        Image(systemName: "drop.circle.fill")
                            .foregroundStyle(.pink)
                    }
                    Spacer()
                    timerView
                }
            }
            .padding()
        }
        .activityBackgroundTint(.clear)
    }

    @ViewBuilder
    private var timerView: some View {
        if context.isStale {
            Text(NSLocalizedString("Updating…", comment: ""))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        } else {
            Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                 countsDown: false)
                .monospacedDigit()
                .font(.title3.bold())
                .foregroundStyle(.white)
        }
    }
}

struct PumpingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PumpingActivityAttributes.self) { context in
            PumpingLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(pumpSideLabel(context.attributes.side))
                    } icon: {
                        Image(systemName: "drop.circle.fill")
                            .foregroundStyle(.pink)
                    }
                    .font(.caption)
                    .foregroundStyle(.pink)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                         countsDown: false)
                        .monospacedDigit()
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.babyName.isEmpty
                         ? NSLocalizedString("Pumping", comment: "")
                         : context.attributes.babyName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label(NSLocalizedString("Pumping…", comment: ""),
                          systemImage: "drop.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
            } compactLeading: {
                Image(systemName: "drop.circle.fill")
                    .foregroundStyle(.pink)
            } compactTrailing: {
                Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                     countsDown: false)
                    .monospacedDigit()
                    .font(.caption2)
                    .frame(width: 44)
            } minimal: {
                Image(systemName: "drop.circle.fill")
                    .foregroundStyle(.pink)
            }
            .keylineTint(.pink)
        }
    }
}
