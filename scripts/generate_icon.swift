#!/usr/bin/env swift
import AppKit
import CoreGraphics

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()
guard let context = NSGraphicsContext.current?.cgContext else {
    image.unlockFocus()
    exit(1)
}

// Background: warm pink-to-peach gradient
let colorSpace = CGColorSpaceCreateDeviceRGB()
let gradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [
        CGColor(red: 1.0,  green: 0.76, blue: 0.82, alpha: 1.0),  // soft pink top
        CGColor(red: 1.0,  green: 0.88, blue: 0.72, alpha: 1.0)   // peach bottom
    ] as CFArray,
    locations: [0.0, 1.0]
)!

// Rounded rect clip
let corner: CGFloat = 220
let bgPath = CGPath(
    roundedRect: CGRect(x: 0, y: 0, width: 1024, height: 1024),
    cornerWidth: corner, cornerHeight: corner, transform: nil
)
context.addPath(bgPath)
context.clip()
context.drawLinearGradient(
    gradient,
    start: CGPoint(x: 512, y: 1024),
    end:   CGPoint(x: 512, y: 0),
    options: []
)

// ── Face ──────────────────────────────────────────────────────────────────
// Shadow
context.setShadow(offset: CGSize(width: 0, height: -8), blur: 24,
                  color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.12))
context.setFillColor(CGColor(red: 1.0, green: 0.905, blue: 0.83, alpha: 1.0))
context.fillEllipse(in: CGRect(x: 172, y: 185, width: 680, height: 680))
context.setShadow(offset: .zero, blur: 0, color: nil)

// ── Hair (3 tufts, brown) ─────────────────────────────────────────────────
let hairColor = CGColor(red: 0.48, green: 0.29, blue: 0.14, alpha: 1.0)
context.setFillColor(hairColor)
// Left tuft
let lTuft = CGMutablePath()
lTuft.addEllipse(in: CGRect(x: 335, y: 105, width: 105, height: 130))
context.addPath(lTuft); context.fillPath()
// Center tuft (tallest)
let cTuft = CGMutablePath()
cTuft.addEllipse(in: CGRect(x: 460, y: 78, width: 105, height: 145))
context.addPath(cTuft); context.fillPath()
// Right tuft
let rTuft = CGMutablePath()
rTuft.addEllipse(in: CGRect(x: 585, y: 105, width: 105, height: 130))
context.addPath(rTuft); context.fillPath()

// ── Eyes ──────────────────────────────────────────────────────────────────
let eyeColor = CGColor(red: 0.18, green: 0.12, blue: 0.08, alpha: 1.0)
let eyeY: CGFloat = 450

// Left eye outline
context.setFillColor(eyeColor)
context.fillEllipse(in: CGRect(x: 328, y: eyeY, width: 88, height: 88))
// Right eye
context.fillEllipse(in: CGRect(x: 608, y: eyeY, width: 88, height: 88))

// Highlights
context.setFillColor(CGColor.white)
context.fillEllipse(in: CGRect(x: 346, y: eyeY + 10, width: 26, height: 26))
context.fillEllipse(in: CGRect(x: 626, y: eyeY + 10, width: 26, height: 26))

// ── Rosy cheeks ──────────────────────────────────────────────────────────
context.setFillColor(CGColor(red: 1.0, green: 0.60, blue: 0.65, alpha: 0.45))
context.fillEllipse(in: CGRect(x: 208, y: 548, width: 148, height: 88))
context.fillEllipse(in: CGRect(x: 668, y: 548, width: 148, height: 88))

// ── Nose (tiny dot) ──────────────────────────────────────────────────────
context.setFillColor(CGColor(red: 0.82, green: 0.55, blue: 0.52, alpha: 0.6))
context.fillEllipse(in: CGRect(x: 490, y: 548, width: 44, height: 30))

// ── Smile ─────────────────────────────────────────────────────────────────
context.setStrokeColor(CGColor(red: 0.72, green: 0.33, blue: 0.33, alpha: 1.0))
context.setLineWidth(20)
context.setLineCap(.round)
let smilePath = CGMutablePath()
smilePath.move(to: CGPoint(x: 356, y: 618))
smilePath.addQuadCurve(
    to:      CGPoint(x: 668, y: 618),
    control: CGPoint(x: 512, y: 760)
)
context.addPath(smilePath)
context.strokePath()

// ── Small heart below smile ───────────────────────────────────────────────
context.setFillColor(CGColor(red: 0.95, green: 0.32, blue: 0.48, alpha: 0.8))
let hx: CGFloat = 475, hy: CGFloat = 770, hr: CGFloat = 28
let heartPath = CGMutablePath()
heartPath.move(to: CGPoint(x: hx + hr, y: hy))
heartPath.addArc(center: CGPoint(x: hx + hr + hr/2, y: hy - hr/2),
                 radius: hr/2 * 1.2, startAngle: .pi * 0.75, endAngle: 0, clockwise: false)
heartPath.addArc(center: CGPoint(x: hx + hr * 2 + hr/2, y: hy - hr/2),
                 radius: hr/2 * 1.2, startAngle: .pi, endAngle: .pi * 0.25, clockwise: false)
heartPath.addQuadCurve(to: CGPoint(x: hx + hr, y: hy + hr * 1.4),
                        control: CGPoint(x: hx + hr * 2.5, y: hy + hr))
heartPath.addQuadCurve(to: CGPoint(x: hx + hr, y: hy),
                        control: CGPoint(x: hx - hr * 0.5, y: hy + hr))
heartPath.closeSubpath()
context.addPath(heartPath)
context.fillPath()

// ── Ears ──────────────────────────────────────────────────────────────────
// Drawn behind face — but since face is already painted, add ear hints
context.setFillColor(CGColor(red: 1.0, green: 0.865, blue: 0.77, alpha: 1.0))
context.fillEllipse(in: CGRect(x: 148, y: 468, width: 80, height: 90))
context.fillEllipse(in: CGRect(x: 796, y: 468, width: 80, height: 90))
// Inner ear
context.setFillColor(CGColor(red: 0.95, green: 0.72, blue: 0.68, alpha: 0.5))
context.fillEllipse(in: CGRect(x: 160, y: 480, width: 52, height: 60))
context.fillEllipse(in: CGRect(x: 812, y: 480, width: 52, height: 60))

image.unlockFocus()

// ── Export 1024×1024 PNG ──────────────────────────────────────────────────
guard let tiff = image.tiffRepresentation,
      let rep  = NSBitmapImageRep(data: tiff),
      let png  = rep.representation(using: .png, properties: [:]) else {
    print("❌ Failed to create PNG")
    exit(1)
}

let outPath = "/Users/ruslanabdulov/Desktop/Momsy/Momsy/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
do {
    try png.write(to: URL(fileURLWithPath: outPath))
    print("✅ Icon saved: \(outPath)")
} catch {
    print("❌ Write error: \(error)")
    exit(1)
}
