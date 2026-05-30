import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

// MARK: - Mini Bottle Icon

private struct MiniBottleIcon: View {
    var size: CGFloat = 18
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
                .fill(Color.white)
                .frame(width: size * 0.52, height: size * 0.72)
                .offset(y: size * 0.06)
            RoundedRectangle(cornerRadius: size * 0.10, style: .continuous)
                .fill(Color(red: 1.0, green: 0.945, blue: 0.87))
                .frame(width: size * 0.40, height: size * 0.30)
                .offset(y: size * 0.20)
            RoundedRectangle(cornerRadius: size * 0.06, style: .continuous)
                .fill(Color(red: 0.941, green: 0.541, blue: 0.431))
                .frame(width: size * 0.36, height: size * 0.16)
                .offset(y: -size * 0.30)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Side helpers

private func sideLabel(_ side: String) -> String {
    switch side {
    case "left":  return NSLocalizedString("Left", comment: "")
    case "right": return NSLocalizedString("Right", comment: "")
    default:      return NSLocalizedString("Bottle", comment: "")
    }
}

@ViewBuilder
private func sideIconView(_ side: String, size: CGFloat = 16) -> some View {
    switch side {
    case "left":
        Image(systemName: "arrow.left.circle.fill")
            .foregroundStyle(.pink)
    case "right":
        Image(systemName: "arrow.right.circle.fill")
            .foregroundStyle(.pink)
    default:
        MiniBottleIcon(size: size)
    }
}

// MARK: - Lock Screen View

struct FeedingLockScreenView: View {
    let context: ActivityViewContext<FeedingActivityAttributes>

    var body: some View {
        ZStack {
            BabyPatternBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                    Text(context.attributes.babyName.isEmpty
                         ? NSLocalizedString("Feeding", comment: "")
                         : context.attributes.babyName)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                    Spacer()
                    Text(NSLocalizedString("Feeding", comment: ""))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                HStack {
                    Label {
                        Text(sideLabel(context.attributes.side))
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    } icon: {
                        sideIconView(context.attributes.side, size: 18)
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
        } else if context.state.isPaused {
            HStack(spacing: 4) {
                Image(systemName: "pause.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text(pausedTimeString)
                    .monospacedDigit()
                    .font(.title3.bold())
                    .foregroundStyle(.white)
            }
        } else {
            Text(timerInterval: context.state.effectiveStartDate...Date.distantFuture,
                 countsDown: false)
                .monospacedDigit()
                .font(.title3.bold())
                .foregroundStyle(.white)
        }
    }

    private var pausedTimeString: String {
        let m = context.state.pausedSeconds / 60
        let s = context.state.pausedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Live Activity Widget

struct FeedingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FeedingActivityAttributes.self) { context in
            FeedingLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(sideLabel(context.attributes.side))
                    } icon: {
                        sideIconView(context.attributes.side, size: 14)
                    }
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
                sideIconView(context.attributes.side, size: 14)
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
