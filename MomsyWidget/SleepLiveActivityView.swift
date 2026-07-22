import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

struct SleepLockScreenView: View {
    let context: ActivityViewContext<SleepActivityAttributes>

    var body: some View {
        ZStack {
            BabyPatternBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    BabyFaceIcon(size: 20)
                    Text(context.attributes.babyName.isEmpty
                         ? WidgetL10n.current.sleep
                         : context.attributes.babyName)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Text(WidgetL10n.current.sleep)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack {
                    Label {
                        Text(WidgetL10n.current.sleeping)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    } icon: {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.purple)
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
            Text(timerInterval: context.state.timerInterval,
                 countsDown: false)
                .monospacedDigit()
                .font(.title3.bold())
                .foregroundStyle(.white)
        }
    }
}

struct SleepLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SleepActivityAttributes.self) { context in
            SleepLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(WidgetL10n.current.sleep)
                    } icon: {
                        BabyFaceIcon(size: 14)
                    }
                    .font(.caption)
                    .foregroundStyle(.purple)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.timerInterval,
                         countsDown: false)
                        .monospacedDigit()
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.babyName.isEmpty
                         ? WidgetL10n.current.sleep
                         : context.attributes.babyName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label {
                        Text(WidgetL10n.current.sleeping)
                    } icon: {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(.purple)
                    }
                    .font(.caption)
                    .foregroundStyle(.purple)
                }
            } compactLeading: {
                BabyFaceIcon(size: 14)
            } compactTrailing: {
                Text(timerInterval: context.state.timerInterval,
                     countsDown: false)
                    .monospacedDigit()
                    .font(.caption2)
                    .frame(width: 44)
            } minimal: {
                BabyFaceIcon(size: 14)
            }
            .keylineTint(.purple)
        }
    }
}
