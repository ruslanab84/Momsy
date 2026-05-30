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
                        .foregroundStyle(.cyan)
                    Text(context.attributes.babyName.isEmpty
                         ? NSLocalizedString("Bath", comment: "")
                         : context.attributes.babyName)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Text(NSLocalizedString("Bath", comment: ""))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack {
                    Label {
                        Text(NSLocalizedString("Bathing…", comment: ""))
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    } icon: {
                        Image(systemName: "drop.fill")
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

struct BathLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BathActivityAttributes.self) { context in
            BathLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(NSLocalizedString("Bath", comment: ""))
                    } icon: {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(.cyan)
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
                         ? NSLocalizedString("Bath", comment: "")
                         : context.attributes.babyName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label(NSLocalizedString("Bathing…", comment: ""),
                          systemImage: "drop.fill")
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
