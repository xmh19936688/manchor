import Cocoa

class ColorManager {

    private var lastColor: NSColor?

    // 生成一个可读性强的随机颜色
    func randomReadableColor() -> NSColor {
        var color: NSColor

        repeat {
            color = NSColor(
                calibratedRed: CGFloat.random(in: 0.3...1.0),
                green: CGFloat.random(in: 0.3...1.0),
                blue: CGFloat.random(in: 0.3...1.0),
                alpha: 1.0
            )
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
