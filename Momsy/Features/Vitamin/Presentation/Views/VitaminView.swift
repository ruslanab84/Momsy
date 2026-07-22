import SwiftUI
import SwiftData

enum VitaminPosterPalette {
    static let paper = Color(bbHex: "FFF9F0")
    static let paperSoft = Color(bbHex: "FFF4D7")
    static let ink = Color(bbHex: "3D2A20")
    static let inkSoft = Color(bbHex: "6B5446")
    static let inkMute = Color(bbHex: "8F7B6C")
}

struct VitaminView: View {
    @ObservedObject var vm: VitaminViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loc: LocalizationManager

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                VitaminScreenBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        inputSection
                        listSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(loc.strings.vitamins)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.bbButter, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(loc.strings.close) { dismiss() }
                        .foregroundStyle(Color.white)
                }
            }
        }
        .tint(Color.bbButterDeep)
    }

    private var inputSection: some View {
        ZStack {
            ZStack {
                VitaminPosterPalette.paper

                VitaminOrganicBlob(variant: .topLeading)
                    .fill(Color.bbButter.opacity(0.34))
                    .frame(width: 230, height: 160)
                    .offset(x: -92, y: -54)

                VitaminOrganicBlob(variant: .bottomTrailing)
                    .fill(Color.bbMint.opacity(0.18))
                    .frame(width: 220, height: 190)
                    .offset(x: 98, y: 82)

                VitaminCapsules(color: Color.bbButterDeep.opacity(0.30))
                    .frame(width: 78, height: 62)
                    .offset(x: 106, y: -52)
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    CuteBlobView(kind: .vitamin, size: 54, tone: Color.bbButter.opacity(0.34))
                        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .stroke(Color.white.opacity(0.86), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.strings.vitamins)
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(VitaminPosterPalette.ink)
                        Text(loc.strings.vitaminNameLabel)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundStyle(VitaminPosterPalette.inkMute)
                            .kerning(0.5)
                    }
                }

                HStack(spacing: 10) {
                    TextField(loc.strings.vitaminNamePlaceholder, text: $vm.vitaminName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(VitaminPosterPalette.ink)
                        .submitLabel(.done)
                        .onSubmit { vm.add() }

                    Button(action: { vm.add() }) {
                        Text(loc.strings.add)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(vm.vitaminName.trimmingCharacters(in: .whitespaces).isEmpty ? VitaminPosterPalette.inkMute : Color.bbButterDeep)
                    }
                    .disabled(vm.vitaminName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(14)
                .background(VitaminPosterPalette.paper.opacity(0.94))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.68), lineWidth: 1)
                )
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.70), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    @ViewBuilder
    private var listSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(loc.strings.todaysVitamins)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.bbButterDeep)
                    .kerning(0.5)

                Spacer()

                VitaminCapsules(color: Color.bbButterDeep.opacity(0.38))
                    .frame(width: 34, height: 24)
            }

            if vm.todayEntries.isEmpty {
                HStack {
                    Spacer()
                    Text(loc.strings.noVitaminsYet)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(VitaminPosterPalette.inkMute)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 22)
                    Spacer()
                }
                .background(VitaminPosterPalette.paper.opacity(0.94))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(vm.todayEntries.enumerated()), id: \.element.id) { index, entry in
                        HStack(spacing: 12) {
                            Text(timeFormatter.string(from: entry.time))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(VitaminPosterPalette.inkMute)
                                .frame(width: 44, alignment: .leading)

                            CuteBlobView(kind: .vitamin, size: 32, tone: .bbButter)

                            Text(entry.label)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(VitaminPosterPalette.ink)
                                .lineLimit(1)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(VitaminPosterPalette.paper.opacity(0.94))
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))

                        if index < vm.todayEntries.count - 1 {
                            VitaminDottedLine()
                                .stroke(Color.bbButterDeep.opacity(0.18), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [1, 6]))
                                .frame(height: 1)
                                .padding(.leading, 102)
                                .background(VitaminPosterPalette.paper.opacity(0.94))
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(16)
        .background(VitaminPosterPalette.paper.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.68), lineWidth: 1)
        )
        .bbShadowSoft()
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.todayEntries.count)
    }
}

struct VitaminScreenBackground: View {
    var body: some View {
        ZStack {
            Color.bbButter.ignoresSafeArea()

            VitaminOrganicBlob(variant: .screenTop)
                .fill(Color.bbButterDeep.opacity(0.18))
                .frame(width: 330, height: 260)
                .offset(x: 120, y: -218)
                .ignoresSafeArea()

            VitaminOrganicBlob(variant: .screenBottom)
                .fill(Color.bbMint.opacity(0.20))
                .frame(width: 330, height: 270)
                .offset(x: -148, y: 230)
                .ignoresSafeArea()

            VitaminCapsules(color: Color.white.opacity(0.30))
                .frame(width: 94, height: 78)
                .rotationEffect(.degrees(-8))
                .offset(x: 120, y: -164)
                .accessibilityHidden(true)

            Image(systemName: "pills.fill")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.24))
                .offset(x: -120, y: 120)
                .accessibilityHidden(true)
        }
    }
}

enum VitaminOrganicBlobVariant {
    case topLeading
    case bottomTrailing
    case screenTop
    case screenBottom
}

struct VitaminOrganicBlob: Shape {
    let variant: VitaminOrganicBlobVariant

    func path(in rect: CGRect) -> Path {
        let x = rect.minX
        let y = rect.minY
        let w = rect.width
        let h = rect.height

        var path = Path()

        switch variant {
        case .topLeading:
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + w * 0.86, y: y))
            path.addCurve(
                to: CGPoint(x: x + w * 0.70, y: y + h * 0.70),
                control1: CGPoint(x: x + w * 1.02, y: y + h * 0.22),
                control2: CGPoint(x: x + w * 0.98, y: y + h * 0.60)
            )
            path.addCurve(
                to: CGPoint(x: x, y: y + h),
                control1: CGPoint(x: x + w * 0.42, y: y + h * 0.82),
                control2: CGPoint(x: x + w * 0.22, y: y + h * 0.78)
            )
            path.closeSubpath()

        case .bottomTrailing:
            path.move(to: CGPoint(x: x + w, y: y + h))
            path.addLine(to: CGPoint(x: x + w * 0.18, y: y + h))
            path.addCurve(
                to: CGPoint(x: x + w * 0.32, y: y + h * 0.22),
                control1: CGPoint(x: x - w * 0.05, y: y + h * 0.78),
                control2: CGPoint(x: x + w * 0.02, y: y + h * 0.34)
            )
            path.addCurve(
                to: CGPoint(x: x + w, y: y + h * 0.02),
                control1: CGPoint(x: x + w * 0.66, y: y + h * 0.03),
                control2: CGPoint(x: x + w * 0.74, y: y + h * 0.06)
            )
            path.closeSubpath()

        case .screenTop:
            path.move(to: CGPoint(x: x, y: y + h * 0.04))
            path.addCurve(
                to: CGPoint(x: x + w, y: y + h * 0.18),
                control1: CGPoint(x: x + w * 0.30, y: y - h * 0.12),
                control2: CGPoint(x: x + w * 0.78, y: y - h * 0.08)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.66, y: y + h),
                control1: CGPoint(x: x + w * 1.12, y: y + h * 0.50),
                control2: CGPoint(x: x + w * 0.98, y: y + h * 0.88)
            )
            path.addCurve(
                to: CGPoint(x: x, y: y + h * 0.78),
                control1: CGPoint(x: x + w * 0.34, y: y + h * 1.12),
                control2: CGPoint(x: x + w * 0.08, y: y + h * 0.96)
            )
            path.closeSubpath()

        case .screenBottom:
            path.move(to: CGPoint(x: x + w * 0.10, y: y + h))
            path.addCurve(
                to: CGPoint(x: x + w * 0.04, y: y + h * 0.24),
                control1: CGPoint(x: x - w * 0.10, y: y + h * 0.78),
                control2: CGPoint(x: x - w * 0.08, y: y + h * 0.44)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.82, y: y + h * 0.10),
                control1: CGPoint(x: x + w * 0.24, y: y + h * 0.02),
                control2: CGPoint(x: x + w * 0.62, y: y - h * 0.06)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.88, y: y + h),
                control1: CGPoint(x: x + w * 1.06, y: y + h * 0.32),
                control2: CGPoint(x: x + w * 1.16, y: y + h * 0.78)
            )
            path.closeSubpath()
        }

        return path
    }
}

struct VitaminCapsules: View {
    let color: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(color)
                .frame(width: 42, height: 18)
                .rotationEffect(.degrees(-28))
                .offset(x: -10, y: -4)

            Capsule()
                .stroke(color, lineWidth: 3)
                .frame(width: 36, height: 16)
                .rotationEffect(.degrees(24))
                .offset(x: 14, y: 10)

            Circle()
                .fill(color.opacity(0.46))
                .frame(width: 9, height: 9)
                .offset(x: 26, y: -14)
        }
    }
}

struct VitaminDottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    let container = try! ModelContainer(for: VitaminRecord.self,
                                         configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    VitaminView(vm: VitaminViewModel(quickLogRepo: QuickLogRepository(),
                                     vitaminRepo: SwiftDataVitaminRepository(context: ModelContext(container))))
        .environmentObject(LocalizationManager.shared)
}
