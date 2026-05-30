import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

private func sideIcon(_ side: String) -> String {
    switch side {
    case "left": return "arrow.left.circle.fill"
    case "right": return "arrow.right.circle.fill"
    default: return "drop.fill"
    }
}

private func sideLabel(_ side: String) -> String {
    switch side {
    case "left": return NSLocalizedString("Left", comment: "")
    case "right": return NSLocalizedString("Right", comment: "")
    default: return NSLocalizedString("Bottle", comment: "")
    }
}

struct FeedingLockScreenView: View {
    let context: ActivityViewContext<FeedingActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                Text(context.attributes.babyName.isEmpty
                     ? NSLocalizedString("Feeding", comment: "")
                     : context.attributes.babyName)
                    .font(.headline)
                    .bold()
                Spacer()
                Text(NSLocalizedString("Feeding", comment: ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label {
                    Text(sideLabel(context.attributes.side))
                        .font(.subheadline)
                } icon: {
                    Image(systemName: sideIcon(context.attributes.side))
                        .foregroundStyle(.pink)
                }
                Spacer()
                timerView
            }
        }
        .padding()
        .activityBackgroundTint(Color.pink.opacity(0.08))
    }

    @ViewBuilder
    private var timerView: some View {
        if context.isStale {
            Text(NSLocalizedString("Updating…", comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
        } else if context.state.isPaused {
            HStack(spacing: 4) {
                Image(systemName: "pause.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text(pausedTimeString)
                    .monospacedDigit()
                    .font(.title3.bold())
            }
        } else {
            Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                 countsDown: false)
                .monospacedDigit()
                .font(.title3.bold())
        }
    }

    private var pausedTimeString: String {
        let m = context.state.pausedSeconds / 60
        let s = context.state.pausedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct FeedingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FeedingActivityAttributes.self) { context in
            FeedingLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(sideLabel(context.attributes.side),
                          systemImage: sideIcon(context.attributes.side))
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    expandedTimerView(context: context)
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.babyName.isEmpty
                         ? NSLocalizedString("Feeding", comment: "")
                         : context.attributes.babyName)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Label(
                        context.state.isPaused
                            ? NSLocalizedString("Paused", comment: "")
                            : NSLocalizedString("Feeding…", comment: ""),
                        systemImage: context.state.isPaused ? "pause.circle" : "heart.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(context.state.isPaused ? .orange : .pink)
                }
            } compactLeading: {
                Image(systemName: sideIcon(context.attributes.side))
                    .foregroundStyle(.pink)
            } compactTrailing: {
                compactTimerView(context: context)
                    .monospacedDigit()
                    .font(.caption2)
                    .frame(width: 44)
            } minimal: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
            }
            .keylineTint(.pink)
        }
    }

    @ViewBuilder
    private func expandedTimerView(context: ActivityViewContext<FeedingActivityAttributes>) -> some View {
        if context.state.isPaused {
            HStack(spacing: 2) {
                Image(systemName: "pause.circle.fill")
                    .foregroundStyle(.orange)
                Text(pausedString(context.state.pausedSeconds))
                    .monospacedDigit()
            }
        } else {
            Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                 countsDown: false)
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func compactTimerView(context: ActivityViewContext<FeedingActivityAttributes>) -> some View {
        if context.state.isPaused {
            Text(pausedString(context.state.pausedSeconds))
        } else {
            Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                 countsDown: false)
        }
    }

    private func pausedString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
