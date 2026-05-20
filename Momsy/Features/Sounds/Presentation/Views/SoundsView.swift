import SwiftUI

// MARK: - SoundsView

struct SoundsView: View {
    @StateObject private var vm = SoundsViewModel()
    @AppStorage("babyName")    private var babyName = ""
    @AppStorage("appLanguage") private var lang = "en"

    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    private func tone(for sound: SoundItem) -> Color {
        switch sound.categoryEn {
        case "white noise":  return .bbLilac
        case "nature":       return .bbMint
        case "pink noise":   return .bbRose
        case "melody":       return .bbButter
        case "for newborns": return .bbCoral
        default:             return .bbSky
        }
    }

    private var displayNameSuffix: String {
        babyName.isEmpty ? "" : t(" for \(babyName)", " для \(babyName)")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                moonHero
                    .padding(.top, 4)

                if vm.anyPlaying {
                    nowPlayingCard
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal:   .move(edge: .top).combined(with: .opacity)
                        ))
                }

                soundGrid
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .padding(.bottom, 40)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.anyPlaying)
        }
        .background(Color.bbLilac.opacity(0.28).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { vm.stopCountdown() }
    }

    // MARK: - Moon Hero

    private var moonHero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(bbHex: "B5A3E0"), Color(bbHex: "DDD4F5")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            GeometryReader { geo in
                Canvas { ctx, size in
                    let stars: [(CGFloat, CGFloat, CGFloat)] = [
                        (0.08, 0.22, 3.5), (0.18, 0.58, 2.5), (0.30, 0.14, 4.0),
                        (0.47, 0.40, 2.0), (0.58, 0.20, 3.2), (0.66, 0.65, 3.5),
                        (0.80, 0.18, 2.5), (0.90, 0.52, 2.0), (0.94, 0.32, 3.0),
                    ]
                    for (rx, ry, d) in stars {
                        let pt = CGPoint(x: size.width * rx, y: size.height * ry)
                        ctx.fill(
                            Path(ellipseIn: CGRect(x: pt.x - d/2, y: pt.y - d/2, width: d, height: d)),
                            with: .color(.white.opacity(0.8))
                        )
                    }
                }
                CuteBlobView(kind: .moon, size: 90, tone: .clear)
                    .position(x: geo.size.width - 60, y: 56)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(t("sleep tight", "пусть спит крепко"))
                    .font(.custom("Georgia", size: 18))
                    .italic()
                    .foregroundColor(Color.bbInk.opacity(0.5))
                Text(t("Lullaby\(displayNameSuffix)", "Колыбельная\(displayNameSuffix)"))
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
                    .fill(vm.nowPlaying.map { tone(for: $0) } ?? .bbCoral)
                    .frame(width: 52, height: 52)
                    .overlay(
                        EqualizerBars(isPlaying: vm.anyPlaying, color: .bbInk, count: 5, maxH: 20, minH: 5)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(t("NOW PLAYING", "СЕЙЧАС ИГРАЕТ"))
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbButter)
                        .kerning(0.5)
                    if let np = vm.nowPlaying {
                        Text("\(np.displayName(lang: lang)) · \(np.displayCategory(lang: lang))")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Text(vm.timerDisplay)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 0.4), value: vm.timerSecondsLeft)
                }

                Spacer()

                Button(action: { vm.stopAll() }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.bbInk)
                                .frame(width: 15, height: 15)
                        )
                }
            }

            HStack(spacing: 6) {
                ForEach(vm.timerLabels.indices, id: \.self) { i in
                    Button { vm.selectTimer(i) } label: {
                        Text(vm.timerLabels[i])
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(i == vm.selectedTimerIdx ? .bbInk : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(i == vm.selectedTimerIdx ? Color.bbButter : Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .bbCard(pad: 14, bg: .bbSurface)
    }

    // MARK: - Sound Grid

    private var soundGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            BBSectionLabel(text: t("Sounds", "Звуки"))
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                spacing: 8
            ) {
                ForEach(vm.sounds.indices, id: \.self) { i in
                    SoundCard(sound: vm.sounds[i]) { vm.play(i) }
                }
            }
        }
    }
}

// MARK: - Equalizer Bars

private struct EqualizerBars: View {
    let isPlaying: Bool
    let color: Color
    var count: Int = 5
    var maxH: CGFloat = 22
    var minH: CGFloat = 6

    @State private var bars: [CGFloat] = []
    @State private var animTask: Task<Void, Never>? = nil

    var body: some View {
        HStack(spacing: 3) {
            ForEach(bars.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(color)
                    .frame(width: 3, height: bars[i])
                    .animation(.easeInOut(duration: 0.25), value: bars[i])
            }
        }
        .onAppear {
            bars = Array(repeating: minH, count: count)
            if isPlaying { startAnim() }
        }
        .onChange(of: isPlaying) { _, playing in
            playing ? startAnim() : stopAnim()
        }
        .onDisappear { animTask?.cancel() }
    }

    private func startAnim() {
        animTask?.cancel()
        animTask = Task {
            while !Task.isCancelled {
                let next = (0..<count).map { _ in CGFloat.random(in: minH...maxH) }
                withAnimation(.easeInOut(duration: 0.25)) { bars = next }
                try? await Task.sleep(nanoseconds: 320_000_000)
            }
        }
    }

    private func stopAnim() {
        animTask?.cancel()
        animTask = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            bars = Array(repeating: minH, count: count)
        }
    }
}

// MARK: - Sound Card

private struct SoundCard: View {
    let sound: SoundItem
    let onPlay: () -> Void

    @AppStorage("appLanguage") private var lang = "en"
    private func t(_ en: String, _ ru: String) -> String { lang == "en" ? en : ru }

    private var cardTone: Color {
        switch sound.categoryEn {
        case "white noise":  return .bbLilac
        case "nature":       return .bbMint
        case "pink noise":   return .bbRose
        case "melody":       return .bbButter
        case "for newborns": return .bbCoral
        default:             return .bbSky
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(cardTone)
                    .aspectRatio(1.65, contentMode: .fit)
                    .overlay(
                        EqualizerBars(
                            isPlaying: sound.isPlaying,
                            color: Color.bbInk.opacity(0.5),
                            count: 8,
                            maxH: 18,
                            minH: 4
                        )
                    )

                if sound.isPlaying {
                    Text(t("playing", "играет"))
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.bbLilacDeep)
                        .clipShape(Capsule())
                        .padding(8)
                        .transition(.scale(scale: 0.7).combined(with: .opacity))
                }
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(sound.displayName(lang: lang))
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.bbInk)
                    Text(sound.displayCategory(lang: lang))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.bbInkMute)
                }
                Spacer()
                Image(systemName: sound.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(sound.isPlaying ? .bbLilacDeep : Color.bbInkMute.opacity(0.4))
                    .animation(.spring(response: 0.25), value: sound.isPlaying)
            }
        }
        .bbCard(pad: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(sound.isPlaying ? Color.bbLilacDeep : Color.clear, lineWidth: 2.5)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onPlay)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: sound.isPlaying)
    }
}

#Preview {
    NavigationStack { SoundsView() }
}
