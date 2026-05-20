import SwiftUI
import UIKit

// MARK: - Color Palette

extension Color {
    // Adaptive neutral tokens — flip between light and dark based on color scheme
    static let bbCream     = Color(UIColor(light: UIColor(bbHex: "FFF6EC"), dark: UIColor(bbHex: "1C1008")))
    static let bbCreamSoft = Color(UIColor(light: UIColor(bbHex: "FFFAF2"), dark: UIColor(bbHex: "241A10")))
    static let bbCard      = Color(UIColor(light: .white,                   dark: UIColor(bbHex: "30221A")))
    static let bbInk       = Color(UIColor(light: UIColor(bbHex: "3D2A20"), dark: UIColor(bbHex: "F0E4D8")))
    static let bbInkSoft   = Color(UIColor(light: UIColor(bbHex: "6B5446"), dark: UIColor(bbHex: "C4A890")))
    static let bbInkMute   = Color(UIColor(light: UIColor(bbHex: "A89484"), dark: UIColor(bbHex: "9A7868")))

    // Fixed dark surface — always warm dark brown regardless of color scheme.
    // Use for elements that are intentionally dark: now-playing card, action buttons, disclaimer banners.
    static let bbSurface   = Color(bbHex: "3D2A20")

    // Accent colors — unchanged in both modes
    static let bbCoral      = Color(bbHex: "FFB39E")
    static let bbCoralDeep  = Color(bbHex: "F08A6E")
    static let bbMint       = Color(bbHex: "A8DDCB")
    static let bbMintDeep   = Color(bbHex: "5FB99B")
    static let bbButter     = Color(bbHex: "FFE0A3")
    static let bbButterDeep = Color(bbHex: "F2B85C")
    static let bbLilac      = Color(bbHex: "D5C4F0")
    static let bbLilacDeep  = Color(bbHex: "9F82D8")
    static let bbSky        = Color(bbHex: "BBDDF0")
    static let bbSkyDeep    = Color(bbHex: "6FA8CE")
    static let bbRose       = Color(bbHex: "F8C9D6")
    static let bbRoseDeep   = Color(bbHex: "E089A3")

    init(bbHex hex: String) {
        var n: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&n)
        self.init(
            red:   Double((n >> 16) & 0xFF) / 255,
            green: Double((n >> 8)  & 0xFF) / 255,
            blue:  Double( n        & 0xFF) / 255
        )
    }
}

extension UIColor {
    convenience init(bbHex hex: String) {
        var n: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&n)
        self.init(
            red:   CGFloat((n >> 16) & 0xFF) / 255,
            green: CGFloat((n >> 8)  & 0xFF) / 255,
            blue:  CGFloat( n        & 0xFF) / 255,
            alpha: 1
        )
    }

    convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
    }
}

// MARK: - Card Modifier

struct BBCardStyle: ViewModifier {
    var pad: CGFloat
    var bg: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(pad)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color.bbInk.opacity(0.04), radius: 0, y: 2)
            .shadow(color: Color.bbInk.opacity(0.10), radius: 16, y: 8)
    }
}

extension View {
    func bbCard(pad: CGFloat = 16, bg: Color = .bbCard, radius: CGFloat = 22) -> some View {
        modifier(BBCardStyle(pad: pad, bg: bg, radius: radius))
    }
    func bbShadow() -> some View {
        self.shadow(color: Color.bbInk.opacity(0.04), radius: 0, y: 2)
            .shadow(color: Color.bbInk.opacity(0.10), radius: 16, y: 8)
    }
    func bbShadowSoft() -> some View {
        self.shadow(color: Color.bbInk.opacity(0.03), radius: 0, y: 1)
            .shadow(color: Color.bbInk.opacity(0.07), radius: 10, y: 4)
    }
}

// MARK: - Pill

struct BBPill: View {
    let text: String
    var color: Color = .bbCoral
    var fg: Color = .bbInk
    var size: CGFloat = 12

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .bold, design: .rounded))
            .foregroundColor(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - Section Label

struct BBSectionLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundColor(.bbInkMute)
            .kerning(0.6)
    }
}

// MARK: - Chip Row (scrollable)

struct BBChipRow: View {
    let chips: [String]
    var selected: Int = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(chips.indices, id: \.self) { i in
                    Text(chips[i])
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(i == selected ? .white : .bbInkSoft)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(i == selected ? Color.bbSurface : Color.bbCard)
                        .clipShape(Capsule())
                        .bbShadowSoft()
                }
            }
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Toggle Row (iOS-style)

struct BBToggleRow: View {
    let label: String
    var isOn: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.bbInk)
            Spacer()
            Capsule()
                .fill(isOn ? Color.bbMintDeep : Color(bbHex: "E5E5E5"))
                .frame(width: 42, height: 24)
                .overlay(
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .shadow(radius: 1)
                        .offset(x: isOn ? 9 : -9),
                    alignment: .center
                )
        }
        .padding(.vertical, 6)
    }
}
