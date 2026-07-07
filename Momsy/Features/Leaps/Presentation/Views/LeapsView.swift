import SwiftUI

struct LeapsView: View {
    @StateObject private var vm: LeapsViewModel
    @State private var calendarScope: LeapCalendarScope = .week
    @State private var isSkillDiarySheetPresented = false
    @EnvironmentObject var loc: LocalizationManager
    @EnvironmentObject var appState: AppState

    init(container: AppContainer) {
        _vm = StateObject(wrappedValue: container.makeLeapsViewModel())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                currentLeapCard
                calendarGridSection
                todayActionsSection
                checkInSection
                behaviorInsightsSection
                normalDoctorCard
                timelineSection
                historySection
                tipCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .sheet(isPresented: $isSkillDiarySheetPresented) {
            LeapSkillDiarySheet(skills: vm.leapSkills(vm.currentLeap)) { skill in
                Task { await vm.recordSkillToDiary(label: skill) }
            }
            .environmentObject(loc)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: loc.strings.developmentalLeaps)
            Text(vm.currentLeap.isCurrent
                 ? loc.strings.currentLeapTitle(id: vm.currentLeap.id)
                 : loc.strings.nextLeapTitle(id: vm.currentLeap.id))
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            leapSubtitle
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var leapSubtitle: some View {
        switch vm.currentLeapPhase {
        case .hardDays(let day, let total, _, _, _, _):
            HStack(spacing: 4) {
                Text(loc.strings.hardDaysProgress(day: day, total: total))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Text(loc.strings.hangInThere)
                    .font(.custom("Georgia", size: 17))
                    .italic()
                    .foregroundColor(.bbCoralDeep)
            }
        case .consolidation:
            Text(loc.strings.leapSettled)
                .font(.custom("Georgia", size: 17))
                .italic()
                .foregroundColor(.bbCoralDeep)
        case .upcoming, .completed:
            Text(vm.leapPhaseDetail(vm.currentLeapPhase))
                .font(.custom("Georgia", size: 17))
                .italic()
                .foregroundColor(.bbCoralDeep)
        }
    }

    // MARK: - Current Leap Card

    private var currentLeapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CuteBlobView(kind: .star, size: 56, tone: Color.white.opacity(0.4))
                Spacer()
                BBPill(text: loc.strings.weekPill(n: vm.currentLeap.week),
                       color: .white.opacity(0.9), fg: .black)
            }

            Text("«\(vm.leapName(vm.currentLeap))»")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)

            Text("\(appState.displayName) \(vm.leapDesc(vm.currentLeap))")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.bbInk.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            LeapPhaseBadge(
                title: vm.leapPhaseTitle(vm.currentLeapPhase),
                detail: vm.leapPhaseDetail(vm.currentLeapPhase)
            )

            HStack(spacing: 8) {
                LeapInfoBlock(
                    title: loc.strings.whatYouNotice,
                    items: vm.leapSigns(vm.currentLeap),
                    accent: .bbCoralDeep
                )
                LeapInfoBlock(
                    title: loc.strings.comingSoon,
                    items: vm.leapSkills(vm.currentLeap),
                    accent: .bbMintDeep
                )
            }

            Button {
                isSkillDiarySheetPresented = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 13, weight: .bold))
                    Text(loc.strings.leapRecordSkillButton)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
                .background(Color.bbSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(vm.isRecordingSkill)

            if let message = vm.skillDiaryMessage {
                Text(message)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.bbMintDeep)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(loc.strings.leapWillPass(hardDays: vm.currentLeap.hardDays))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(10)
                .background(Color.bbSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .bbCard(pad: 18, bg: .bbCoral)
    }

    // MARK: - Timeline

    private var calendarGridSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                BBSectionLabel(text: loc.strings.leapCalendar)
                Spacer()
                Picker(loc.strings.leapCalendar, selection: $calendarScope) {
                    ForEach(LeapCalendarScope.allCases) { scope in
                        Text(vm.calendarScopeTitle(scope)).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 154)
            }

            LeapCalendarGrid(
                days: vm.calendarDays(scope: calendarScope),
                phaseTitle: vm.calendarPhaseTitle
            )
        }
        .bbCard(pad: 14)
    }

    private var todayActionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: loc.strings.leapTodayActionsTitle)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(vm.todayActions) { action in
                    LeapTodayActionRow(action: action)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .bbCard(pad: 14, bg: Color.bbButter.opacity(0.24))
    }

    private var checkInSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.leapCheckInTitle)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text(loc.strings.leapCheckInSubtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: 8)], spacing: 8) {
                ForEach(LeapCheckInSymptom.allCases) { symptom in
                    LeapSymptomChip(
                        title: vm.symptomTitle(symptom),
                        systemImage: symptom.systemImage,
                        isSelected: vm.selectedSymptoms.contains(symptom)
                    ) {
                        Task { await vm.toggleSymptom(symptom) }
                    }
                }
            }
        }
        .bbCard(pad: 14)
    }

    @ViewBuilder
    private var behaviorInsightsSection: some View {
        if !vm.behaviorInsights.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(vm.behaviorInsights) { insight in
                    LeapInsightRow(insight: insight)
                }
            }
            .bbCard(pad: 14, bg: Color.bbSky.opacity(0.18))
        }
    }

    private var normalDoctorCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: loc.strings.leapNormalDoctorTitle)
            Text(loc.strings.leapNormalText)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            Text(loc.strings.leapDoctorText)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.bbCoralDeep)
                .fixedSize(horizontal: false, vertical: true)
        }
        .bbCard(pad: 14, bg: Color.bbRose.opacity(0.18))
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: loc.strings.leapCalendar)
            VStack(spacing: 0) {
                ForEach(vm.leaps) { leap in
                    let phase = vm.leapPhase(for: leap)
                    LeapTimelineRow(
                        leap: leap,
                        phaseTitle: vm.leapPhaseTitle(phase),
                        phaseDetail: vm.leapPhaseDetail(phase),
                        isExpanded: vm.expandedLeapID == leap.id,
                        isLast: leap.id == vm.leaps.last?.id
                    ) {
                        vm.toggleExpand(leap.id)
                    }
                }
            }
            .bbCard(pad: 14)
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(loc.strings.leapHistoryTitle.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.bbLilacDeep)
                .kerning(0.6)
            Text(loc.strings.leapHistorySubtitle)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color.bbSurface.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)

            if vm.historySummaries.isEmpty {
                Text(loc.strings.leapHistoryEmpty)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.bbSurface.opacity(0.64))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            } else {
                VStack(spacing: 8) {
                    ForEach(vm.historySummaries) { summary in
                        LeapHistoryRow(
                            summary: summary,
                            difficultyTitle: vm.historyDifficultyTitle(summary.difficulty),
                            durationText: vm.historyDurationText(summary),
                            symptomsText: vm.historySymptomsText(summary)
                        )
                    }
                }
            }
        }
        .bbCard(pad: 14, bg: Color.white.opacity(0.9))
    }

    // MARK: - Tip Card

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(loc.strings.tipOfTheDay)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.bbMintDeep)
                .kerning(0.5)
            Text(loc.strings.forLeapTip(name: vm.leapName(vm.currentLeap)))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.bbInk)
            Text(vm.leapTip(vm.currentLeap))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.bbInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .bbCard(pad: 14, bg: Color.bbMint.opacity(0.3))
    }
}

// MARK: - Leap Phase Badge

private struct LeapPhaseBadge: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(.bbCoralDeep)
                .kerning(0.6)
            if !detail.isEmpty {
                Text(detail)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.bbSurface)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Calendar Grid

private struct LeapCalendarGrid: View {
    let days: [LeapCalendarDay]
    let phaseTitle: (LeapCalendarDayPhase) -> String

    private let columns = Array(repeating: GridItem(.flexible(minimum: 28), spacing: 6), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(days) { day in
                    LeapCalendarDayCell(day: day)
                }
            }
            HStack(spacing: 10) {
                ForEach([LeapCalendarDayPhase.calm, .hard, .peak, .recovery], id: \.self) { phase in
                    LeapLegendItem(title: phaseTitle(phase), color: phase.color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct LeapCalendarDayCell: View {
    let day: LeapCalendarDay

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text("\(day.dayNumber)")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(day.phase == .peak ? .white : .bbInk)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(day.phase.color)
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(day.isToday ? Color.bbInk : Color.clear, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            if day.hasCheckIn {
                Circle()
                    .fill(Color.bbMintDeep)
                    .frame(width: 7, height: 7)
                    .padding(4)
            }
        }
        .accessibilityLabel("\(day.dayNumber)")
    }
}

private struct LeapLegendItem: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkMute)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

// MARK: - Personalized Blocks

private struct LeapTodayActionRow: View {
    let action: LeapTodayAction

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: action.systemImage)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.bbButterDeep)
                .frame(width: 24, height: 24)
                .background(Color.white.opacity(0.72))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(action.title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(action.detail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct LeapSymptomChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 0)
            }
            .foregroundColor(isSelected ? .white : .bbInk)
            .padding(.vertical, 9)
            .padding(.horizontal, 10)
            .frame(minHeight: 42)
            .background(isSelected ? Color.bbSurface : Color.bbCreamSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct LeapInsightRow: View {
    let insight: LeapBehaviorInsight

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: insight.systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.bbSkyDeep)
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.75))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbSkyDeep)
                Text(insight.detail)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct LeapHistoryRow: View {
    let summary: LeapHistorySummary
    let difficultyTitle: String
    let durationText: String
    let symptomsText: String
    @EnvironmentObject var loc: LocalizationManager

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: summary.difficulty.systemImage)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(summary.difficulty.tint)
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.78))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(loc.strings.leapPill(summary.leapID))
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbSurface)
                    Spacer(minLength: 6)
                    Text(difficultyTitle)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(summary.difficulty.tint)
                }
                Text(summary.title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.bbSurface)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(durationText)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.bbSurface.opacity(0.68))
                Text(symptomsText)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.bbSurface.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .background(Color.bbLilac.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct LeapSkillDiarySheet: View {
    let skills: [String]
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager
    @State private var selectedSkill: String
    @State private var customSkill: String

    private var trimmedSkill: String {
        customSkill.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(skills: [String], onSave: @escaping (String) -> Void) {
        self.skills = skills
        self.onSave = onSave
        let initial = skills.first ?? ""
        _selectedSkill = State(initialValue: initial)
        _customSkill = State(initialValue: initial)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(loc.strings.leapRecordSkillSubtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .fixedSize(horizontal: false, vertical: true)

                    if !skills.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
                            ForEach(skills, id: \.self) { skill in
                                Button {
                                    selectedSkill = skill
                                    customSkill = skill
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: selectedSkill == skill ? "checkmark.circle.fill" : "sparkles")
                                            .font(.system(size: 12, weight: .bold))
                                        Text(skill)
                                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                        Spacer(minLength: 0)
                                    }
                                    .foregroundColor(selectedSkill == skill ? .white : .bbInk)
                                    .padding(10)
                                    .frame(minHeight: 46)
                                    .background(selectedSkill == skill ? Color.bbSurface : Color.bbCard)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    TextField(loc.strings.leapRecordSkillPlaceholder, text: $customSkill)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .padding(14)
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(20)
            }
            .background(Color.bbCream.ignoresSafeArea())
            .navigationTitle(loc.strings.leapRecordSkillTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.cancel) { dismiss() }
                        .foregroundColor(.bbInkSoft)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(loc.strings.add) {
                        onSave(trimmedSkill)
                        dismiss()
                    }
                    .disabled(trimmedSkill.isEmpty)
                    .foregroundColor(trimmedSkill.isEmpty ? .bbInkMute : .bbCoralDeep)
                }
            }
        }
    }
}

// MARK: - Leap Info Block

private struct LeapInfoBlock: View {
    let title: String
    let items: [String]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(accent)
                .kerning(0.6)
            ForEach(items, id: \.self) { item in
                Text("· \(item)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(bbHex: "2A1A12"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Timeline Row

private struct LeapTimelineRow: View {
    let leap: DevelopmentLeap
    let phaseTitle: String
    let phaseDetail: String
    let isExpanded: Bool
    let isLast: Bool
    let onTap: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    private var leapName: String { leap.name(for: loc.current) }
    private var leapDesc: String { leap.description(for: loc.current) }
    private var leapSigns: [String] { leap.signs(for: loc.current) }
    private var leapSkills: [String] { leap.skills(for: loc.current) }
    private var leapTip: String { leap.tip(for: loc.current) }

    private var dotFill: Color {
        if leap.isDone    { return .bbMint }
        if leap.isCurrent { return leap.semanticColor.color }
        return .bbCreamSoft
    }
    private var dotBorder: Color {
        if leap.isCurrent { return .bbCoralDeep }
        if leap.isDone    { return .bbMintDeep }
        return Color.bbInkMute.opacity(0.2)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 0) {
                    Circle()
                        .fill(dotFill)
                        .overlay(Circle().strokeBorder(dotBorder, lineWidth: leap.isCurrent ? 3 : 2))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Group {
                                if leap.isDone {
                                    Text("✓")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.bbMintDeep)
                                } else {
                                    Text("\(leap.id)")
                                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                                        .foregroundColor(leap.isCurrent ? .bbInk : .bbInkMute)
                                }
                            }
                        )
                    if !isLast {
                        Rectangle()
                            .fill(Color.bbCreamSoft)
                            .frame(width: 2)
                            .frame(minHeight: isExpanded ? 28 : 14)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center) {
                        Text(leapName)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(leap.isCurrent ? .bbCoralDeep : .bbInk)
                        Spacer()
                        HStack(spacing: 4) {
                            Text(loc.strings.weekRow(n: leap.week))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.bbInkMute)
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.bbInkMute)
                        }
                    }

                    Group {
                        if leap.isCurrent {
                            Text(phaseTitle)
                                .foregroundColor(.bbCoralDeep)
                        } else if leap.isDone {
                            Text(phaseTitle)
                                .foregroundColor(.bbMintDeep)
                        } else {
                            Text(phaseTitle)
                                .foregroundColor(.bbInkMute)
                        }
                    }
                    .font(.system(size: 11, weight: .bold, design: .rounded))

                    if !phaseDetail.isEmpty {
                        Text(phaseDetail)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInkMute)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if isExpanded {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(leapDesc.prefix(1).uppercased() + leapDesc.dropFirst())
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.bbInkSoft)
                                .fixedSize(horizontal: false, vertical: true)

                            if !leapSigns.isEmpty {
                                HStack(alignment: .top, spacing: 10) {
                                    MiniList(label: loc.strings.notice, items: leapSigns, accent: .bbCoral)
                                    MiniList(label: loc.strings.willLearn, items: leapSkills, accent: .bbMintDeep)
                                }
                            }

                            if !leapTip.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.bbButterDeep)
                                    Text(leapTip)
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(.bbInkSoft)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(8)
                                .background(Color.bbButter.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, isLast ? 0 : 8)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mini List

private struct MiniList: View {
    let label: String
    let items: [String]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundColor(accent)
                .kerning(0.3)
            ForEach(items.prefix(3), id: \.self) { item in
                Text("· \(item)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInk)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension LeapCalendarDayPhase {
    var color: Color {
        switch self {
        case .calm:
            return Color.bbCreamSoft
        case .hard:
            return Color.bbCoral.opacity(0.46)
        case .peak:
            return Color.bbCoralDeep
        case .recovery:
            return Color.bbMint.opacity(0.55)
        }
    }
}

private extension LeapHistoryDifficulty {
    var systemImage: String {
        switch self {
        case .light: return "leaf.fill"
        case .moderate: return "waveform.path.ecg"
        case .hard: return "exclamationmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .light: return .bbMintDeep
        case .moderate: return .bbButterDeep
        case .hard: return .bbCoralDeep
        }
    }
}

#Preview {
    LeapsView(container: AppContainer())
        .environmentObject(LocalizationManager.shared)
        .environmentObject(AppState(
            getBabyProfile: GetBabyProfileUseCase(repository: LocalBabyRepository()),
            getAllBabies: GetAllBabiesUseCase(repository: LocalBabyRepository())))
}
