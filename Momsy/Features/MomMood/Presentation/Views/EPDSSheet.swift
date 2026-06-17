import SwiftUI

struct EPDSSheet: View {
    @ObservedObject var vm: MomMoodViewModel
    @EnvironmentObject private var lm: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var page = 0
    @State private var answers: [Int] = Array(repeating: -1, count: 10)
    @State private var mood = 3
    @State private var energy = 3
    @State private var showResult = false

    private let faces = ["😔", "😕", "😐", "🙂", "😊"]

    private var questions: [String] {
        [lm.strings.epdsQ1, lm.strings.epdsQ2, lm.strings.epdsQ3, lm.strings.epdsQ4,
         lm.strings.epdsQ5, lm.strings.epdsQ6, lm.strings.epdsQ7, lm.strings.epdsQ8,
         lm.strings.epdsQ9, lm.strings.epdsQ10]
    }

    // EPDS scoring: Q1/Q2 are reverse-scored (0→3, 1→2, 2→1, 3→0)
    private func score(at index: Int) -> Int {
        let raw = answers[index]
        if index == 0 || index == 1 { return 3 - raw }
        return raw
    }

    private var totalScore: Int { (0..<10).map { score(at: $0) }.reduce(0, +) }

    private var riskLabel: String {
        if totalScore >= 13 { return lm.strings.epdsHighRisk }
        if totalScore >= 10 { return lm.strings.epdsMildRisk }
        return lm.strings.epdsLowRisk
    }

    private var riskColor: Color {
        if totalScore >= 13 { return .bbCoral }
        if totalScore >= 10 { return .bbButter }
        return .bbMint
    }

    var body: some View {
        NavigationStack {
            if showResult {
                resultView
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(lm.strings.cancel) { dismiss() }
                                .foregroundColor(.bbInkSoft)
                        }
                    }
            } else {
                questionView
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(lm.strings.cancel) { dismiss() }
                                .foregroundColor(.bbInkSoft)
                        }
                    }
            }
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.horizontal, 20)
                .padding(.top, 8)

            TabView(selection: $page) {
                ForEach(0..<questions.count, id: \.self) { i in
                    questionCard(index: i)
                        .tag(i)
                        .padding(.horizontal, 20)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)

            navButtons
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.epdsTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var progressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(lm.strings.epdsProgress) \(page + 1) \(lm.strings.epdsOf) \(questions.count)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Spacer()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.bbInkMute.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.bbRoseDeep)
                        .frame(width: geo.size.width * CGFloat(page + 1) / CGFloat(questions.count),
                               height: 6)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: page)
                }
            }
            .frame(height: 6)
        }
    }

    private func questionCard(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(questions[index])
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInk)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)

            VStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { opt in
                    answerRow(question: index, option: opt)
                }
            }
            Spacer()
        }
    }

    private func answerRow(question: Int, option: Int) -> some View {
        let labels = lm.strings.epdsOptions
        let label = labels[min(question, labels.count - 1)][option]
        let isSelected = answers[question] == option
        return Button {
            answers[question] = option
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .strokeBorder(isSelected ? Color.bbRoseDeep : Color.bbInkMute.opacity(0.3), lineWidth: 2)
                    .background(Circle().fill(isSelected ? Color.bbRoseDeep : Color.clear))
                    .frame(width: 20, height: 20)
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInk)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(14)
            .background(isSelected ? Color.bbRose.opacity(0.3) : Color.bbCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: answers[question])
    }

    private var navButtons: some View {
        HStack(spacing: 12) {
            if page > 0 {
                Button {
                    withAnimation { page -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.bbInkSoft)
                        .frame(width: 52, height: 52)
                        .background(Color.bbCard)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            let isLast = page == questions.count - 1
            let canAdvance = answers[page] >= 0
            Button {
                if isLast {
                    showResult = true
                } else {
                    withAnimation { page += 1 }
                }
            } label: {
                Text(isLast ? lm.strings.epdsYourScore : lm.strings.epdsNextButton)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(canAdvance ? Color.bbRoseDeep : Color.bbInkMute.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .disabled(!canAdvance)
            .buttonStyle(.plain)
        }
    }

    // MARK: - Result View

    private var resultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(lm.strings.epdsYourScore.uppercased())
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.5)
                    Text("\(totalScore)")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundColor(riskColor)
                    Text("/ 30")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(riskColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                Text(riskLabel)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(riskColor)

                VStack(alignment: .leading, spacing: 8) {
                    Text(lm.strings.momMoodEnergyLabel.uppercased())
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.5)
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { val in
                            Button { energy = val } label: {
                                Text(["🪫","😴","⚡️","💪","🚀"][val - 1])
                                    .font(.system(size: 26))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(energy == val ? Color.bbRose.opacity(0.35) : Color.bbCard)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Text(lm.strings.epdsDisclaimer)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Button {
                    Task {
                        await vm.saveEPDS(scores: answers, mood: mood, energy: energy)
                        dismiss()
                    }
                } label: {
                    Text(lm.strings.epdsDoneButton)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.bbRoseDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .padding(20)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.strings.epdsTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
