import Cocoa

class TimeView: NSView {

    private let timeLabel: CATextLayer = {
        let layer = CATextLayer()
        layer.alignmentMode = .center
        layer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        layer.font = NSFont.monospacedDigitSystemFont(ofSize: 32, weight: .medium)
        layer.fontSize = 32
        layer.foregroundColor = NSColor.white.cgColor
        return layer
    }()

    private var timer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        layer?.addSublayer(timeLabel)
        startTimer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        timeLabel.frame = self.bounds

        // 1. 根据高度给一个初始字体大小（占高度的 60%）
        let maxFontSize = bounds.height * 0.6
        var fontSize = maxFontSize

        // 2. 计算文本宽度，确保不超过窗口宽度
        let text = timeLabel.string as? String ?? ""
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
        ]

        let textWidth = (text as NSString).size(withAttributes: attributes).width

        // 3. 如果文本宽度超出窗口宽度，按比例缩小
        if textWidth > bounds.width {
            let scale = bounds.width / textWidth
            fontSize = floor(fontSize * scale)
        }

        // 4. 设置最终字体大小
        timeLabel.fontSize = fontSize
    }


    // MARK: - Timer
    private func startTimer() {
        updateTime()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTime()
        }
    }

    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let text = formatter.string(from: Date())

        timeLabel.string = text
    }

    // MARK: - External Color Update
    func updateColor(_ color: NSColor) {
        timeLabel.foregroundColor = color.cgColor
    }
}
