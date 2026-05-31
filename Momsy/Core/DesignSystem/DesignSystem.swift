import SwiftUI
import UIKit

// MARK: - Color Palette

extension Color {
    // Adaptive neutral tokens — flip between light and dark based on color scheme
    static let bbCream     = Color(UIColor(light: UIColor(bbHex: "FFF6EC"), dark: UIColor(bbHex: "0C0804")))
    static let bbCreamSoft = Color(UIColor(light: UIColor(bbHex: "FFFAF2"), dark: UIColor(bbHex: "120C07")))
    static let bbCard      = Color(UIColor(light: .white,                   dark: UIColor(bbHex: "1A1109")))
    static let bbInk       = Color(UIColor(light: UIColor(bbHex: "3D2A20"), dark: UIColor(bbHex: "F8F2EC")))
    static let bbInkSoft   = Color(UIColor(light: UIColor(bbHex: "6B5446"), dark: UIColor(bbHex: "CCAA8A")))
    static let bbInkMute   = Color(UIColor(light: UIColor(bbHex: "A89484"), dark: UIColor(bbHex: "8A6A58")))

    // Fixed dark surface — always warm dark brown regardless of color scheme.
    // Use for elements that are intentionally dark: now-playing card, action buttons, disclaimer banners.
    static let bbSurface   = Color(bbHex: "2C1C12")

    // Accent colors — more vibrant for punch on both light and dark backgrounds
    static let bbCoral      = Color(bbHex: "FF8C72")
    static let bbCoralDeep  = Color(bbHex: "E8582A")
    static let bbMint       = Color(bbHex: "78D4B8")
    static let bbMintDeep   = Color(bbHex: "30A882")
    static let bbButter     = Color(bbHex: "FFD070")
    static let bbButterDeep = Color(bbHex: "F09418")
    static let bbLilac      = Color(bbHex: "C0A4F8")
    static let bbLilacDeep  = Color(bbHex: "7C4ED8")
    static let bbSky        = Color(bbHex: "88CCEC")
    static let bbSkyDeep    = Color(bbHex: "3A8EC8")
    static let bbRose       = Color(bbHex: "F898BE")
    static let bbRoseDeep   = Color(bbHex: "D44088")

    init(bbHex hex: String) {
        var n: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&n)
        self.init(
            red:   Double((n >> 16) & 0xFF) / 255,
            green: Double((n >> 8)  & 0xFF) / 255,
            blue:  Double( n        & 0xFF) / 255
        )
    }

    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
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

// MARK: - SemanticColor → SwiftUI Color

extension SemanticColor {
    var color: Color {
        switch self {
        case .rose:   return .bbRose
        case .butter: return .bbButter
        case .mint:   return .bbMint
        case .coral:  return .bbCoral
        case .lilac:  return .bbLilac
        case .sky:    return .bbSky
        }
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
