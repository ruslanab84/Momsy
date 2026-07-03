import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

struct WalkLockScreenView: View {
    let context: ActivityViewContext<WalkActivityAttributes>

    var body: some View {
        ZStack {
            BabyPatternBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    BabyFaceIcon(size: 20)
                    Text(context.attributes.babyName.isEmpty
                         ? WidgetL10n.current.walk
                         : context.attributes.babyName)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Text(WidgetL10n.current.walk)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack {
                    Label {
                        Text(WidgetL10n.current.walking)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    } icon: {
                        Image(systemName: "stroller.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.green)
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

struct WalkLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WalkActivityAttributes.self) { context in
            WalkLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(WidgetL10n.current.walk)
                    } icon: {
                        BabyFaceIcon(size: 14)
                    }
                    .font(.caption)
                    .foregroundStyle(.green)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                         countsDown: false)
                        .monospacedDigit()
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.babyName.isEmpty
                         ? WidgetL10n.current.walk
                         : context.attributes.babyName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label {
                        Text(WidgetL10n.current.walking)
                    } icon: {
                        Image(systemName: "stroller.fill")
                            .foregroundStyle(.green)
                    }
                    .font(.caption)
                    .foregroundStyle(.green)
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
            .keylineTint(.green)
        }
    }
}
