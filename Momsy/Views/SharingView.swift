import SwiftUI

struct SharingView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                header
                memberList
                inviteCard
                roleMatrix
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color.bbCream.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            BBSectionLabel(text: "Семья")
            Text("Команда Лёвы")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(.bbInk)
            Text("У всех своя роль — у каждой свой уровень доступа.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Member List

    private var memberList: some View {
        VStack(spacing: 10) {
            ForEach(sampleFamily) { member in
                MemberCard(member: member)
            }
        }
    }

    // MARK: - Invite

    private var inviteCard: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.bbCard)
                .frame(width: 44, height: 44)
                .overlay(
                    Text("+")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.bbCoralDeep)
                )
                .bbShadowSoft()
            VStack(alignment: .leading, spacing: 2) {
                Text("Пригласить")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text("QR-код или ссылка на 24ч")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.bbCreamSoft)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.bbInkMute.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
        )
    }

    // MARK: - Role Matrix

    private let matrixHeaders = ["", "Мама", "Папа", "Няня", "Бабушка"]
    private let matrixRows: [(String, [Bool])] = [
        ("Кормления и сон",         [true, true, true, false]),
        ("Подгузники",              [true, true, true, false]),
        ("Температура / лекарства", [true, true, false, false]),
        ("Симптомы",                [true, true, false, false]),
        ("Фото и дневник",          [true, true, true, true]),
        ("Отчёт врачу",             [true, true, false, false]),
    ]

    private var roleMatrix: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: "Что видит каждая роль")

            VStack(spacing: 0) {
                // header row
                HStack(spacing: 0) {
                    ForEach(matrixHeaders.indices, id: \.self) { i in
                        Text(matrixHeaders[i].uppercased())
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.bbInkSoft)
                            .frame(maxWidth: .infinity, alignment: i == 0 ? .leading : .center)
                            .padding(.vertical, 10)
                            .padding(.horizontal, i == 0 ? 12 : 0)
                            .background(Color.bbCreamSoft)
                    }
                }

                Divider().opacity(0.3)

                ForEach(matrixRows.indices, id: \.self) { ri in
                    HStack(spacing: 0) {
                        Text(matrixRows[ri].0)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.bbInk)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)

                        ForEach(matrixRows[ri].1.indices, id: \.self) { ci in
                            Text(matrixRows[ri].1[ci] ? "●" : "–")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundColor(matrixRows[ri].1[ci] ? .bbMintDeep : Color.bbInkMute.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 10)
                        }
                    }
                    if ri < matrixRows.count - 1 {
                        Divider().opacity(0.2)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .bbShadow()
        }
    }
}

// MARK: - Member Card

private struct MemberCard: View {
    let member: FamilyMember

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                CuteBlobView(kind: member.blob, size: 50, tone: member.tone)
                if member.isOnline {
                    Circle()
                        .fill(Color.bbMintDeep)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: 2.5))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(member.name)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text("· \(member.role.rawValue)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
                Text(member.role.description)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkSoft)
                Text(member.activity.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(member.isOnline ? .bbMintDeep : .bbInkMute)
                    .kerning(0.4)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(member.isMe ? Color.bbCoral : Color.bbCreamSoft)
                .frame(width: 30, height: 24)
                .overlay(
                    Text(member.isMe ? "вы" : "⋯")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(member.isMe ? .bbInk : .bbInkSoft)
                )
        }
        .bbCard(pad: 12)
    }
}

#Preview {
    NavigationStack { SharingView() }
}
