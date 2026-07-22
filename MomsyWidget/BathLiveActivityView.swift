import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

struct BathLockScreenView: View {
    let context: ActivityViewContext<BathActivityAttributes>

    var body: some View {
        ZStack {
            BabyPatternBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.cyan)
                    Text(context.attributes.babyName.isEmpty
                         ? WidgetL10n.current.bath
                         : context.attributes.babyName)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Text(WidgetL10n.current.bath)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack {
                    Label {
                        Text(WidgetL10n.current.bathing)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    } icon: {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.cyan)
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

struct BathLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BathActivityAttributes.self) { context in
            BathLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(WidgetL10n.current.bath)
                    } icon: {
                        Image(systemName: "drop.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.cyan)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                         countsDown: false)
                        .monospacedDigit()
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.babyName.isEmpty
                         ? WidgetL10n.current.bath
                         : context.attributes.babyName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label {
                        Text(WidgetL10n.current.bathing)
                    } icon: {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(.cyan)
                    }
                    .font(.caption)
                    .foregroundStyle(.cyan)
                }
            } compactLeading: {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
            } compactTrailing: {
                Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                     countsDown: false)
                    .monospacedDigit()
                    .font(.caption2)
                    .frame(width: 44)
            } minimal: {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
            }
            .keylineTint(.cyan)
        }
    }
}
