import SwiftUI

struct DoctorMenuView: View {
    @EnvironmentObject private var lm: LocalizationManager
    @Environment(\.appContainer) private var container

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                NavigationLink(destination: SymptomView()) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Image(systemName: "cross.fill")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(lm.t("SYMPTOMS", "СИМПТОМЫ"))
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white.opacity(0.75))
                                    .kerning(0.5)
                                Text(lm.t("Something wrong?", "Что-то не так?"))
                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Text(lm.t("Note symptoms — get guidance. Not a diagnosis, just navigation.",
                               "Отметьте симптомы — получите подсказку. Не диагноз, а навигация."))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(18)
                    .background(Color.bbCoralDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.bbCoralDeep.opacity(0.35), radius: 12, y: 6)
                }
                .buttonStyle(.plain)

                VStack(spacing: 1) {
                    DoctorMenuRow(
                        destination: ReportView(),
                        icon: "doc.text.fill",
                        iconColor: .bbSkyDeep,
                        iconBg: Color.bbSky.opacity(0.3),
                        title: lm.t("Pediatrician Report", "Отчёт для педиатра"),
                        sub: lm.t("PDF for the week — sleep, feeding, weight", "PDF за неделю — сон, кормление, вес")
                    )
                    Divider().padding(.leading, 60)
                    DoctorMenuRow(
                        destination: TrackingView(container: container),
                        icon: "chart.xyaxis.line",
                        iconColor: .bbMintDeep,
                        iconBg: Color.bbMint.opacity(0.3),
                        title: lm.t("Height & Weight", "Рост и вес"),
                        sub: lm.t("WHO percentile chart", "График по перцентилям ВОЗ")
                    )
                }
                .background(Color.bbCard)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle(lm.t("Doctor", "Доктор"))
    }
}

struct DoctorMenuRow<D: View>: View {
    let destination: D
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let sub: String

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconBg)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(iconColor)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(sub)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.bbInkSoft)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}
