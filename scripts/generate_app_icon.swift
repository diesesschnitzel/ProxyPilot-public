import CoreGraphics
import CoreText
import AppKit
import Foundation
import ImageIO
import UniformTypeIdentifiers

private func usageAndExit() -> Never {
    fputs("usage: generate_app_icon.swift --out-dir /path/to/AppIcon.appiconset\n", stderr)
    exit(2)
}

private func argValue(_ name: String) -> String? {
    guard let idx = CommandLine.arguments.firstIndex(of: name) else { return nil }
    let next = CommandLine.arguments.index(after: idx)
    guard next < CommandLine.arguments.endIndex else { return nil }
    return CommandLine.arguments[next]
}

guard let outDir = argValue("--out-dir") else { usageAndExit() }
let outDirURL = URL(fileURLWithPath: outDir, isDirectory: true)

private func renderImage(side: Int) -> CGImage? {
    let size = CGSize(width: side, height: side)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

    guard let ctx = CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else {
        return nil
    }

    let s = CGFloat(side)
    let rect = CGRect(origin: .zero, size: size)
    let cx = s / 2
    let cy = s / 2

    // ── Background: deep crimson-rose ──────────────────────────────────────
    ctx.setFillColor(CGColor(red: 0.55, green: 0.05, blue: 0.12, alpha: 1.0))
    ctx.fill(rect)

    // ── Radial gradient: rich rose at centre fading to deep red at edge ────
    if let bg = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            CGColor(red: 0.96, green: 0.30, blue: 0.40, alpha: 1.0),  // blush-rose centre
            CGColor(red: 0.72, green: 0.08, blue: 0.18, alpha: 1.0),  // mid crimson
            CGColor(red: 0.38, green: 0.03, blue: 0.08, alpha: 1.0),  // deep edge
        ] as CFArray,
        locations: [0.0, 0.55, 1.0]
    ) {
        ctx.saveGState()
        ctx.addRect(rect)
        ctx.clip()
        ctx.drawRadialGradient(
            bg,
            startCenter: CGPoint(x: cx, y: cy),
            startRadius: 0,
            endCenter: CGPoint(x: cx, y: cy),
            endRadius: s * 0.62,
            options: [.drawsAfterEndLocation]
        )
        ctx.restoreGState()
    }

    // ── Petal layer: 6 translucent ellipses arranged like a rose bloom ─────
    let petalCount = 6
    let petalRadiusX = s * 0.22
    let petalRadiusY = s * 0.14
    let orbitR = s * 0.24
    ctx.saveGState()
    for i in 0..<petalCount {
        let angle = CGFloat(i) * (.pi * 2 / CGFloat(petalCount)) - .pi / 2
        let px = cx + orbitR * cos(angle)
        let py = cy + orbitR * sin(angle)
        let petalRect = CGRect(
            x: px - petalRadiusX / 2,
            y: py - petalRadiusY / 2,
            width: petalRadiusX,
            height: petalRadiusY
        )
        ctx.saveGState()
        ctx.translateBy(x: px, y: py)
        ctx.rotate(by: angle + .pi / 2)
        ctx.translateBy(x: -px, y: -py)
        ctx.setFillColor(CGColor(red: 1.0, green: 0.62, blue: 0.68, alpha: 0.28))
        ctx.fillEllipse(in: petalRect)
        ctx.restoreGState()
    }
    ctx.restoreGState()

    // ── Inner glow ring ────────────────────────────────────────────────────
    if let glow = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            CGColor(red: 1.0, green: 0.75, blue: 0.78, alpha: 0.18),
            CGColor(red: 1.0, green: 0.55, blue: 0.60, alpha: 0.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    ) {
        ctx.saveGState()
        ctx.addRect(rect)
        ctx.clip()
        ctx.drawRadialGradient(
            glow,
            startCenter: CGPoint(x: cx, y: cy),
            startRadius: s * 0.18,
            endCenter: CGPoint(x: cx, y: cy),
            endRadius: s * 0.48,
            options: []
        )
        ctx.restoreGState()
    }

    // ── Bold "E" centred ───────────────────────────────────────────────────
    let fontSize = s * 0.62
    let font = CTFontCreateWithName("Georgia-Bold" as CFString, fontSize, nil)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white.withAlphaComponent(0.97)
    ]
    let attributed = NSAttributedString(string: "E", attributes: attrs)
    let line = CTLineCreateWithAttributedString(attributed)
    let bounds = CTLineGetBoundsWithOptions(line, [.useOpticalBounds])
    // Nudge slightly upward for optical centre on a square icon
    let tx = (size.width  - bounds.width)  / 2 - bounds.minX
    let ty = (size.height - bounds.height) / 2 - bounds.minY - s * 0.02

    ctx.saveGState()
    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)
    ctx.textMatrix = .identity
    ctx.translateBy(x: 0, y: size.height)
    ctx.scaleBy(x: 1, y: -1)
    ctx.textPosition = CGPoint(x: tx, y: ty)
    CTLineDraw(line, ctx)
    ctx.restoreGState()

    // ── Subtle vignette to deepen edges ───────────────────────────────────
    if let vig = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            CGColor(red: 0, green: 0, blue: 0, alpha: 0.0),
            CGColor(red: 0, green: 0, blue: 0, alpha: 0.45),
        ] as CFArray,
        locations: [0.0, 1.0]
    ) {
        ctx.saveGState()
        ctx.addRect(rect)
        ctx.clip()
        ctx.drawRadialGradient(
            vig,
            startCenter: CGPoint(x: cx, y: cy),
            startRadius: s * 0.28,
            endCenter: CGPoint(x: cx, y: cy),
            endRadius: s * 0.70,
            options: [.drawsAfterEndLocation]
        )
        ctx.restoreGState()
    }

    return ctx.makeImage()
}

private func writePNG(image: CGImage, to url: URL) -> Bool {
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        return false
    }
    CGImageDestinationAddImage(dest, image, [kCGImagePropertyPNGDictionary: [:]] as CFDictionary)
    return CGImageDestinationFinalize(dest)
}

let fm = FileManager.default
try? fm.createDirectory(at: outDirURL, withIntermediateDirectories: true)

let sizes = [16, 32, 64, 128, 256, 512, 1024]
var wrote: [String] = []

for side in sizes {
    guard let image = renderImage(side: side) else {
        fputs("Failed to render \(side)x\(side)\n", stderr)
        exit(1)
    }
    let url = outDirURL.appendingPathComponent("icon_\(side).png")
    guard writePNG(image: image, to: url) else {
        fputs("Failed to write \(url.path)\n", stderr)
        exit(1)
    }
    wrote.append(url.lastPathComponent)
}

print("Wrote \(wrote.count) files to \(outDirURL.path): " + wrote.joined(separator: ", "))
