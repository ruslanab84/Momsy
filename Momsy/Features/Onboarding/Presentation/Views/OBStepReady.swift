import SwiftUI

// MARK: - Step 4: Ready

struct ReadyStep: View {
    let babyName: String
    let birthDate: Date
    let stage: BabyAgeStage
    let parentName: String
    let role: FamilyRole
    let lang: String
    let isJoinFlow: Bool
    let cloudSyncEnabled: Bool
    let isFinishing: Bool
    let onStart: () -> Void
    @EnvironmentObject var loc: LocalizationManager

    @State private var pulse = false

    private var ageDescription: String {
        let comps = Calendar.current.dateComponents([.month, .day], from: birthDate, to: Date())
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        if m == 0 { return "\(d) \(loc.strings.days)" }
        return "\(m) \(loc.strings.unitMonth) \(d) \(loc.strings.unitDay)"
    }

    private var parentLabel: String {
        let name = parentName.isEmpty ? nil : parentName
        switch role {
        case .mom:     return name.map { "\($0)!" } ?? loc.strings.greetMom
        case .dad:     return name.map { "\($0)!" } ?? loc.strings.greetDad
        case .nanny:   return name.map { "\($0)!" } ?? loc.strings.greetNanny
        case .grandma: return name.map { "\($0)!" } ?? loc.strings.greetDefault
        }
    }

    private var roleName: String {
        role.displayName(loc.strings)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                ZStack {
                    Circle()
                        .fill(Color.bbButter.opacity(0.5))
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulse ? 1.08 : 1.0)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)
                    Circle().fill(Color.bbButter).frame(width: 130, height: 130)
                    Circle().fill(Color.bbCoral).frame(width: 100, height: 100)
                    CuteBlobView(kind: .star, size: 64, tone: .clear)
                }
                .padding(.top, 12)
                .onAppear { pulse = true }

                VStack(spacing: 6) {
                    Text(isJoinFlow ? loc.strings.familyJoinedReadyTitle : loc.strings.allSet)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(isJoinFlow ? loc.strings.familyJoinedReadySubtitle : parentLabel)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbCoralDeep)
                }
                .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    if isJoinFlow {
                        summaryRow(blob: .heart, tone: .bbSky,
                                   label: loc.strings.family,
                                   value: loc.strings.joinSuccessTitle)
                        Divider().opacity(0.3)
                        summaryRow(blob: .baby, tone: .bbCoral,
                                   label: loc.strings.baby,
                                   value: babyName.isEmpty ? "—" : babyName)
                        Divider().opacity(0.3)
                        summaryRow(blob: .star, tone: .bbButter,
                                   label: loc.strings.stage,
                                   value: stage.label(L10n(Language.from(lang))))
                    } else {
                        summaryRow(blob: .baby, tone: .bbCoral,
                                   label: loc.strings.baby,
                                   value: babyName.isEmpty ? "—" : babyName)
                        Divider().opacity(0.3)
                        summaryRow(blob: .moon, tone: .bbLilac,
                                   label: loc.strings.age,
                                   value: ageDescription)
                        Divider().opacity(0.3)
                        summaryRow(blob: role.defaultBlob, tone: role.defaultTone,
                                   label: loc.strings.caregiver,
                                   value: roleName)
                        Divider().opacity(0.3)
                        summaryRow(blob: .star, tone: .bbButter,
                                   label: loc.strings.stage,
                                   value: stage.label(L10n(Language.from(lang))))
                    }
                }
                .bbCard(pad: 16)
                .padding(.horizontal, 24)

                Text(isJoinFlow
                     ? loc.strings.familyJoinedReadyFootnote
                     : (cloudSyncEnabled ? loc.strings.dataSyncedWithConsent : loc.strings.dataStoredLocally))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: onStart) {
                    HStack {
                        Text(loc.strings.start)
                        if isFinishing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.right")
                        }
                    }
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.bbCoralDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.bbCoralDeep.opacity(0.35), radius: 12, y: 6)
                }
                .disabled(isFinishing)
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }

    private func summaryRow(blob: BlobKind, tone: Color, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            CuteBlobView(kind: blob, size: 36, tone: tone)
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
        }
    }
}
