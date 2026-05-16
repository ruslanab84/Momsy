import SwiftUI

struct SoundsView: View {
    @State private var sounds = sampleSounds
    @State private var selectedTimer = 1
    private let timerLabels = ["15 мин", "30 мин", "1 ч", "не выкл."]

    var nowPlaying: SoundItem? { sounds.first(where: { $0.isPlaying }) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                moonHero
                if nowPlaying != nil {
                    nowPlayingCard
                }
                soundGrid
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color.bbLilac.opacity(0.3).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Moon Hero

    private var moonHero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(bbHex: "C5B5E8"), Color(bbHex: "E8DBF5")],
                startPoint: .top, endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .frame(height: 200)

            // Stars
            ForEach([(20, 30, 4.0), (40, 60, 3.0), (70, 25, 5.0), (82, 70, 3.5), (55, 35, 4.5), (12, 80, 3.0)], id: \.0) { x, y, d in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: d, height: d)
                    .position(
                        x: UIScreen.main.bounds.width * CGFloat(x) / 100 - 22,
                        y: CGFloat(y) * 2
                    )
            }

            // Moon
            CuteBlobView(kind: .moon, size: 80, tone: .clear)
                .frame(width: 80, height: 80)
                .position(x: UIScreen.main.bounds.width - 80, y: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text("пусть спит крепко")
                    .font(.custom("Georgia", size: 20))
                    .italic()
                    .foregroundColor(Color.bbInk.opacity(0.55))
                Text("Колыбельная мама")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
            }
            .padding(20)
        }
        .frame(height: 200)
    }

    // MARK: - Now Playing

    private var nowPlayingCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.bbCoral)
                    .frame(width: 50, height: 50)
                    .overlay(
                        HStack(spacing: 2) {
                            ForEach([14, 22, 10, 18, 12], id: \.self) { h in
                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                    .fill(Color.bbInk)
                                    .frame(width: 3, height: CGFloat(h))
                            }
                        }
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("СЕЙЧАС ИГРАЕТ")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.bbButter)
                        .kerning(0.5)
                    Text("\(nowPlaying?.name ?? "") · \(nowPlaying?.category ?? "")")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("таймер: 22 мин до выключения")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                }

                Spacer()

                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        HStack(spacing: 3) {
                            ForEach(0..<2) { _ in
                                RoundedRectangle(cornerRadius: 1, style: .continuous)
                                    .fill(Color.bbInk)
                                    .frame(width: 4, height: 14)
                            }
                        }
                    )
            }

            HStack(spacing: 6) {
                ForEach(timerLabels.indices, id: \.self) { i in
                    Text(timerLabels[i])
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(i == selectedTimer ? .bbInk : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(i == selectedTimer ? Color.bbButter : Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .onTapGesture { selectedTimer = i }
                }
            }
        }
        .bbCard(pad: 14, bg: .bbInk)
    }

    // MARK: - Sound Grid

    private var soundGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: "Звуки")

            let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(sounds.indices, id: \.self) { i in
                    SoundCard(sound: sounds[i]) {
                        for j in sounds.indices { sounds[j].isPlaying = false }
                        sounds[i].isPlaying = true
                    }
                }
            }
        }
    }
}

// MARK: - Sound Card

private struct SoundCard: View {
    let sound: SoundItem
    let onPlay: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(sound.tone)
                    .aspectRatio(1.6, contentMode: .fit)
                    .overlay(
                        HStack(spacing: 3) {
                            ForEach([20, 55, 30, 70, 40, 85, 25, 60], id: \.self) { h in
                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                    .fill(Color.bbInk.opacity(0.55))
                                    .frame(width: 4, height: CGFloat(h) * 0.22)
                            }
                        }
                    )

                if sound.isPlaying {
                    Text("играет")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.bbLilacDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .padding(6)
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(sound.name)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(.bbInk)
                Text(sound.category)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.bbInkMute)
            }
        }
        .bbCard(pad: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(sound.isPlaying ? Color.bbLilacDeep : Color.clear, lineWidth: 2.5)
        )
        .onTapGesture(perform: onPlay)
    }
}

#Preview {
    NavigationStack { SoundsView() }
}
