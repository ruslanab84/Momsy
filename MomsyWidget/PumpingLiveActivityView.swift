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
                    BabyFaceIcon(size: 20)
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
                        BabyFaceIcon(size: 16)
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
                        BabyFaceIcon(size: 14)
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
                    Label {
                        Text(NSLocalizedString("Pumping…", comment: ""))
                    } icon: {
                        BabyFaceIcon(size: 14)
                    }
                    .font(.caption)
                    .foregroundStyle(.pink)
                }
            } compactLeading: {
                BabyFaceIcon(size: 14)
            } compactTrailing: {
                Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                     countsDown: false)
                    .monospacedDigit()
                    .font(.caption2)
                    .frame(width: 44)
            } minimal: {
                BabyFaceIcon(size: 14)
            }
            .keylineTint(.pink)
        }
    }
}
