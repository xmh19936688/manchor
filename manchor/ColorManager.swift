import Cocoa

extension NSColor {
    convenience init(hexARGB: String) {
        var hex = hexARGB.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")

        let scanner = Scanner(string: hex)
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)

        let a = CGFloat((value & 0xFF000000) >> 24) / 255.0
        let r = CGFloat((value & 0x00FF0000) >> 16) / 255.0
        let g = CGFloat((value & 0x0000FF00) >> 8) / 255.0
        let b = CGFloat(value & 0x000000FF) / 255.0

        self.init(calibratedRed: r, green: g, blue: b, alpha: a)
    }
}

class ColorManager {

    private var lastColor: NSColor?

    // 生成一个可读性强的随机颜色
    func randomReadableColor() -> NSColor {
        let hexColors = [
            "#7fffc107",
            "#7f3f51b5",
            "#7ff44336",
            "#7f009688",
            "#7fcddc39",
            "#7f9c27b0",
            "#7fff9800",
            "#7f2196f3",
            "#7fe91e63",
            "#7f4caf50",
            "#7fffeb3b",
            "#7f673ab7",
            "#7f00bcd4",
            "#7fff5722",
            "#7f8bc34a"
        ]

        var color: NSColor

        repeat {
            let hex = hexColors.randomElement()!
            color = NSColor(hexARGB: hex)
        } while isTooSimilar(to: color)

        lastColor = color
        return color
    }

    // 判断颜色是否与上一次太接近
    private func isTooSimilar(to newColor: NSColor) -> Bool {
        guard let last = lastColor else { return false }

        let dr = abs(last.redComponent - newColor.redComponent)
        let dg = abs(last.greenComponent - newColor.greenComponent)
        let db = abs(last.blueComponent - newColor.blueComponent)

        // RGB 差异都小于 0.15 就认为太接近
        return (dr + dg + db) < 0.25
    }
}
