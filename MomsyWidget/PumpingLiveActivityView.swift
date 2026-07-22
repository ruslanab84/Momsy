import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

private func pumpSideLabel(_ side: String) -> String {
    WidgetL10n.current.pumpingSideLabel(side)
}

struct PumpingLockScreenView: View {
    let context: ActivityViewContext<PumpingActivityAttributes>

    var body: some View {
        ZStack {
            BabyPatternBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "drop.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.pink)
                    Text(context.attributes.babyName.isEmpty
                         ? WidgetL10n.current.pumping
                         : context.attributes.babyName)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Text(WidgetL10n.current.pumping)
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
                            .font(.system(size: 14))
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
            Text(WidgetL10n.current.updating)
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
                        Image(systemName: "drop.fill")
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
                         ? WidgetL10n.current.pumping
                         : context.attributes.babyName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label {
                        Text(WidgetL10n.current.pumpingActive)
                    } icon: {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(.pink)
                    }
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
