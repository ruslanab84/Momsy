import SwiftUI

// MARK: - Step Enum

private enum OBStep: Int, CaseIterable {
    case age, profile, role, ready
}

// MARK: - OnboardingView

struct OnboardingView: View {
    let onDone: () -> Void

    @AppStorage("babyName")      private var savedName = ""
    @AppStorage("babyBirthDate") private var savedBirthDate: Double = 0
    @AppStorage("babyStage")     private var savedStage = BabyAgeStage.baby.rawValue
    @AppStorage("parentRole")    private var savedParentRole = "mom"
    @AppStorage("parentName")    private var savedParentName = ""
    @AppStorage("appLanguage")   private var lang = "en"

    @State private var step: OBStep = .age
    @State private var forward = true

    @State private var selectedStage: BabyAgeStage = .baby
    @State private var babyName = ""
    @State private var birthDate: Date = {
        Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date()
    }()
    @State private var parentName = ""
    @State private var parentRole = "mom"

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    private var canContinue: Bool {
        step == .profile ? !babyName.trimmingCharacters(in: .whitespaces).isEmpty : true
    }

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                navBar
                    .padding(.top, 56)
                    .padding(.horizontal, 24)

                stepContent
                    .transition(
                        forward
                        ? .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity))
                        : .asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal:   .move(edge: .trailing).combined(with: .opacity))
                    )
                    .id(step)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.bbCream, stepColor.opacity(0.18)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: step)
    }

    private var stepColor: Color {
        switch step {
        case .age:     return .bbCoral
        case .profile: return .bbMint
        case .role:    return .bbLilac
        case .ready:   return .bbButter
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(spacing: 12) {
            Button(action: goBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.bbInkSoft)
                    .frame(width: 36, height: 36)
                    .background(Color.bbCard.opacity(0.7))
                    .clipShape(Circle())
            }
            .opacity(step == .age ? 0 : 1)
            .disabled(step == .age)

            HStack(spacing: 6) {
                ForEach(OBStep.allCases, id: \.self) { s in
                    Capsule()
                        .fill(s.rawValue <= step.rawValue ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.2))
                        .frame(width: s == step ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: step)
                }
            }
            .frame(maxWidth: .infinity)

            Text("\(step.rawValue + 1) / \(OBStep.allCases.count)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.bbInkMute)
                .frame(width: 36)
        }
        .padding(.bottom, 12)
    }

    // MARK: - Step Router

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .age:
            AgeStep(selected: $selectedStage, lang: lang, onContinue: advance)
        case .profile:
            ProfileStep(babyName: $babyName, birthDate: $birthDate,
                        lang: lang, canContinue: canContinue, onContinue: advance)
        case .role:
            RoleStep(parentName: $parentName, selectedRole: $parentRole, lang: lang, onContinue: advance)
        case .ready:
            ReadyStep(
                babyName: babyName,
                birthDate: birthDate,
                stage: selectedStage,
                parentName: parentName,
                role: parentRole,
                lang: lang,
                onStart: finish
            )
        }
    }

    // MARK: - Navigation

    private func advance() {
        guard canContinue else { return }
        forward = true
        let all = OBStep.allCases
        if let idx = all.firstIndex(of: step), idx + 1 < all.count {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                step = all[idx + 1]
            }
        }
    }

    private func goBack() {
        forward = false
        let all = OBStep.allCases
        if let idx = all.firstIndex(of: step), idx > 0 {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                step = all[idx - 1]
            }
        }
    }

    private func finish() {
        savedName = babyName.trimmingCharacters(in: .whitespaces)
        savedBirthDate = birthDate.timeIntervalSince1970
        savedStage = selectedStage.rawValue
        savedParentRole = parentRole
        savedParentName = parentName.trimmingCharacters(in: .whitespaces)
        onDone()
    }
}

// MARK: - Step 1: Age

private struct AgeStep: View {
    @Binding var selected: BabyAgeStage
    let lang: String
    let onContinue: () -> Void

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(Color.bbButter).frame(width: 130, height: 130)
                    Circle().fill(Color.bbCoral).frame(width: 100, height: 100)
                    CuteBlobView(kind: .baby, size: 64, tone: .clear)
                }
                .padding(.top, 12)
                .padding(.bottom, 20)

                Text(t("Hello, mama!", "Привет, мама!"))
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)

                Text(t("How old is your baby?\nWe'll tailor everything to their age.",
                       "Сколько вашему малышу?\nМы настроим всё под его возраст."))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 12)

                VStack(spacing: 10) {
                    ForEach(BabyAgeStage.allCases) { stage in
                        OBAgeCard(stage: stage, isSelected: selected == stage, lang: lang)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) { selected = stage }
                            }
                    }
                }
                .padding(.horizontal, 24)

                tipBanner
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                OBContinueButton(label: t("Continue →", "Продолжить →"), action: onContinue)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
            }
        }
    }

    private var tipBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.bbMintDeep)
                .frame(width: 24, height: 24)
                .overlay(Text("✓").font(.system(size: 12, weight: .heavy)).foregroundColor(.white))
            Text(t("Age can be changed later. We'll highlight developmental leaps specifically for you.",
                   "Возраст можно изменить позже. Мы подсветим скачки развития именно для вас."))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.bbMint.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Step 2: Baby Profile

private struct ProfileStep: View {
    @Binding var babyName: String
    @Binding var birthDate: Date
    let lang: String
    let canContinue: Bool
    let onContinue: () -> Void

    @FocusState private var nameFocused: Bool

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    var ageDescription: String {
        let comps = Calendar.current.dateComponents([.month, .day], from: birthDate, to: Date())
        let months = comps.month ?? 0
        let days   = comps.day ?? 0
        if months == 0 { return "\(days) \(t("d", "дн"))" }
        return "\(months) \(t("mo", "мес")) \(days) \(t("d", "дн"))"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                VStack(spacing: 8) {
                    CuteBlobView(kind: .star, size: 64, tone: .bbMint)
                        .padding(.top, 12)
                    Text(t("What's your baby's name?", "Как зовут малыша?"))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(t("Name and birth date help track\nleaps and development more accurately.",
                           "Имя и дата рождения помогут точнее\nотслеживать скачки и развитие."))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(t("BABY'S NAME", "ИМЯ МАЛЫША"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.6)

                    TextField(t("E.g., Leo", "Например, Лёва"), text: $babyName)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                        .tint(.bbCoralDeep)
                        .focused($nameFocused)
                        .submitLabel(.next)
                        .onSubmit { nameFocused = false }
                        .padding(16)
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    nameFocused ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.15),
                                    lineWidth: nameFocused ? 2 : 1.5
                                )
                        )
                        .bbShadowSoft()
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text(t("DATE OF BIRTH", "ДАТА РОЖДЕНИЯ"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.6)
                        .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        DatePicker(
                            "",
                            selection: $birthDate,
                            in: Calendar.current.date(byAdding: .year, value: -3, to: Date())!...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(.bbCoralDeep)
                        .padding(.horizontal, 8)

                        HStack {
                            CuteBlobView(kind: .baby, size: 32, tone: .bbCoral)
                            Text(t("Age: \(ageDescription)", "Возраст: \(ageDescription)"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.bbInk)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                    }
                    .background(Color.bbCard)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .bbShadow()
                    .padding(.horizontal, 24)
                }

                OBContinueButton(
                    label: t("Continue →", "Продолжить →"),
                    enabled: canContinue,
                    action: onContinue
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear { nameFocused = true }
    }
}

// MARK: - Step 3: Parent Role

private struct RoleStep: View {
    @Binding var parentName: String
    @Binding var selectedRole: String
    let lang: String
    let onContinue: () -> Void

    @FocusState private var nameFocused: Bool

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    private var roles: [(String, String, BlobKind, Color)] {
        [
            ("mom",   t("Mom",   "Мама"),   .baby, .bbCoral),
            ("dad",   t("Dad",   "Папа"),   .bear, .bbSky),
            ("nanny", t("Nanny", "Няня"),   .sun,  .bbMint),
            ("other", t("Other", "Другой"), .star, .bbButter),
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    CuteBlobView(kind: .heart, size: 64, tone: .bbLilac)
                        .padding(.top, 12)
                    Text(t("Who are you to the baby?", "Кто ты для малыша?"))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(t("This helps configure\nnotifications and access rights.",
                           "Это поможет настроить\nуведомления и права доступа."))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                        .multilineTextAlignment(.center)
                }

                let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(roles, id: \.0) { id, label, blob, tone in
                        let isSelected = selectedRole == id
                        VStack(spacing: 10) {
                            CuteBlobView(kind: blob, size: 52, tone: tone)
                            Text(label)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundColor(.bbInk)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(isSelected ? Color.bbCoralDeep : Color.clear, lineWidth: 2.5)
                        )
                        .bbShadow()
                        .scaleEffect(isSelected ? 1.02 : 1.0)
                        .animation(.spring(response: 0.3), value: selectedRole)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) { selectedRole = id }
                        }
                    }
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text(t("YOUR NAME (optional)", "ВАШЕ ИМЯ (необязательно)"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.6)

                    TextField(t("E.g., Anna", "Например, Аня"), text: $parentName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInk)
                        .tint(.bbCoralDeep)
                        .focused($nameFocused)
                        .padding(14)
                        .background(Color.bbCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(
                                    nameFocused ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.15),
                                    lineWidth: nameFocused ? 2 : 1.5
                                )
                        )
                        .bbShadowSoft()
                }
                .padding(.horizontal, 24)

                OBContinueButton(label: t("Continue →", "Продолжить →"), action: onContinue)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Step 4: Ready

private struct ReadyStep: View {
    let babyName: String
    let birthDate: Date
    let stage: BabyAgeStage
    let parentName: String
    let role: String
    let lang: String
    let onStart: () -> Void

    @State private var pulse = false

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    private var ageDescription: String {
        let comps = Calendar.current.dateComponents([.month, .day], from: birthDate, to: Date())
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        if m == 0 { return "\(d) \(t("days", "дней"))" }
        return "\(m) \(t("mo", "мес")) \(d) \(t("d", "дн"))"
    }

    private var parentLabel: String {
        let name = parentName.isEmpty ? nil : parentName
        switch role {
        case "mom":   return name.map { "\($0)!" } ?? t("Mama!", "Мама!")
        case "dad":   return name.map { "\($0)!" } ?? t("Papa!", "Папа!")
        case "nanny": return name.map { "\($0)!" } ?? t("Nanny!", "Няня!")
        default:      return name.map { "\($0)!" } ?? t("Hello!", "Привет!")
        }
    }

    private var roleBlob: BlobKind {
        switch role {
        case "dad":   return .bear
        case "nanny": return .sun
        default:      return .baby
        }
    }

    private var roleName: String {
        switch role {
        case "mom":   return t("Mom",   "Мама")
        case "dad":   return t("Dad",   "Папа")
        case "nanny": return t("Nanny", "Няня")
        default:      return t("Other", "Другой")
        }
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
                    Text(t("All set,", "Всё готово,"))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(parentLabel)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbCoralDeep)
                }
                .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    summaryRow(blob: .baby, tone: .bbCoral,
                               label: t("Baby", "Малыш"),
                               value: babyName.isEmpty ? "—" : babyName)
                    Divider().opacity(0.3)
                    summaryRow(blob: .moon, tone: .bbLilac,
                               label: t("Age", "Возраст"),
                               value: ageDescription)
                    Divider().opacity(0.3)
                    summaryRow(blob: roleBlob, tone: .bbSky,
                               label: t("Caregiver", "Кто следит"),
                               value: roleName)
                    Divider().opacity(0.3)
                    summaryRow(blob: .star, tone: .bbButter,
                               label: t("Stage", "Стадия"),
                               value: lang == "en" ? stage.labelEn : stage.label)
                }
                .bbCard(pad: 16)
                .padding(.horizontal, 24)

                Text(t("Data is stored only on your phone. Nothing extra.",
                       "Данные хранятся только на вашем телефоне. Ничего лишнего."))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: onStart) {
                    HStack {
                        Text(t("Start", "Начать"))
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.bbCoralDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.bbCoralDeep.opacity(0.35), radius: 12, y: 6)
                }
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

// MARK: - Shared Components

private struct OBAgeCard: View {
    let stage: BabyAgeStage
    let isSelected: Bool
    let lang: String

    var body: some View {
        HStack(spacing: 14) {
            CuteBlobView(kind: stage.blobKind, size: 56, tone: stage.tone)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text(lang == "en" ? stage.labelEn : stage.label)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text((lang == "en" ? stage.subtitleEn : stage.subtitle).uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                        .kerning(0.4)
                }
                Text(lang == "en" ? stage.focusEn : stage.focus)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.bbInkSoft)
            }
            Spacer()
            Circle()
                .strokeBorder(isSelected ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.25), lineWidth: 2)
                .background(Circle().fill(isSelected ? Color.bbCoralDeep : Color.clear))
                .frame(width: 24, height: 24)
                .overlay(Circle().fill(.white).frame(width: 8, height: 8).opacity(isSelected ? 1 : 0))
        }
        .padding(14)
        .background(Color.bbCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(isSelected ? Color.bbCoralDeep : Color.clear, lineWidth: 2.5)
        )
        .bbShadow()
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

private struct OBContinueButton: View {
    let label: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(enabled ? Color.bbCoralDeep : Color.bbInkMute.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(enabled ? 0.08 : 0), radius: 0, y: 4)
        }
        .disabled(!enabled)
        .animation(.easeInOut(duration: 0.2), value: enabled)
    }
}

#Preview {
    OnboardingView(onDone: {})
}
