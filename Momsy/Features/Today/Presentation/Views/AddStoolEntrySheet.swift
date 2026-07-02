import SwiftUI

private enum StoolPosterPalette {
    static let paper = Color(bbHex: "FFF9F0")
    static let ink = Color(bbHex: "3D2A20")
}

struct AddStoolEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var loc: LocalizationManager

    let onSave: (Date) -> Void

    @State private var selectedDate = Date()

    private var lm: L10n { loc.strings }

    var body: some View {
        NavigationStack {
            ZStack {
                StoolScreenBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        sheetHero

                        fieldSection(label: lm.stoolTimeLabel) {
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                in: ...Date(),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle(lm.addStoolTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.bbMint, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.cancel) { dismiss() }
                        .foregroundStyle(Color.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lm.save) {
                        onSave(selectedDate)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white)
                }
            }
        }
        .tint(Color.bbMintDeep)
    }

    private var sheetHero: some View {
        ZStack {
            ZStack {
                StoolPosterPalette.paper

                StoolOrganicBlob(variant: .topLeading)
                    .fill(Color.bbMint.opacity(0.36))
                    .frame(width: 230, height: 160)
                    .offset(x: -92, y: -54)

                StoolOrganicBlob(variant: .bottomTrailing)
                    .fill(Color.bbMintDeep.opacity(0.16))
                    .frame(width: 220, height: 190)
                    .offset(x: 98, y: 82)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.bbMintDeep.opacity(0.30))
                    .offset(x: 112, y: 36)
            }

            VStack(spacing: 12) {
                CuteBlobView(kind: .stool, size: 54, tone: Color.bbMint.opacity(0.32))
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .stroke(Color.white.opacity(0.86), lineWidth: 1)
                    )

                Text(lm.stoolLabel)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(StoolPosterPalette.ink)
                    .multilineTextAlignment(.center)

                StoolDottedLine()
                    .stroke(Color.bbMintDeep.opacity(0.24), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 7]))
                    .frame(height: 1)
                    .padding(.horizontal, 36)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 26)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .bbShadowSoft()
    }

    @ViewBuilder
    private func fieldSection<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.78))
                .kerning(0.5)
            content()
                .tint(Color.bbMintDeep)
                .foregroundStyle(StoolPosterPalette.ink)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(StoolPosterPalette.paper.opacity(0.96))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.68), lineWidth: 1)
                )
                .bbShadowSoft()
        }
    }
}

private struct StoolScreenBackground: View {
    var body: some View {
        ZStack {
            Color.bbMint.ignoresSafeArea()

            StoolOrganicBlob(variant: .screenTop)
                .fill(Color.bbMintDeep.opacity(0.22))
                .frame(width: 320, height: 250)
                .offset(x: 120, y: -210)
                .ignoresSafeArea()

            StoolOrganicBlob(variant: .screenBottom)
                .fill(Color.bbSky.opacity(0.22))
                .frame(width: 330, height: 270)
                .offset(x: -150, y: 230)
                .ignoresSafeArea()
        }
    }
}

private enum StoolOrganicBlobVariant {
    case topLeading
    case bottomTrailing
    case screenTop
    case screenBottom
}

private struct StoolOrganicBlob: Shape {
    let variant: StoolOrganicBlobVariant

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

private struct StoolDottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    AddStoolEntrySheet { _ in }
        .environmentObject(LocalizationManager.shared)
}
