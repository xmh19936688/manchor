import Cocoa

class WindowManager: NSObject, NSWindowDelegate {

    private var window: NSWindow!
    private var timer: Timer?
    private let timeView = TimeView(frame: NSRect(x: 0, y: 0, width: 200, height: 60))
    private let colorManager = ColorManager()
    private var isTransparentMode = true

    var isTransparent: Bool {
        return isTransparentMode
    }

    override init() {
        super.init()
        createWindow()
        restoreWindowFrame()
        startColorTimer()
    }

    // MARK: - Create Transparent Window
    private func createWindow() {
        let frame = NSRect(x: 0, y: 0, width: 200, height: 60)

        window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.delegate = self

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        timeView.frame = window.contentView!.bounds
        timeView.autoresizingMask = [.width, .height]
        window.contentView = timeView
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - Position Window at Bottom Right
    private func positionWindow() {
        guard let screen = window.screen ?? NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let windowSize = window.frame.size

        let x = screenFrame.maxX - windowSize.width - 20
        let y = screenFrame.minY + 20

        window.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // MARK: - Random Color Timer
    private func startColorTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let color = self.colorManager.randomReadableColor()
            self.timeView.updateColor(color)
        }
    }

    // MARK: - Toggle Mode
    func toggleWindowMode() {
        isTransparentMode.toggle()

        if isTransparentMode {
            // 透明模式：先隐藏窗口，让系统重置窗口角色
            window.orderOut(nil)

            window.styleMask = [.borderless]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.ignoresMouseEvents = true
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            // 再显示回来
            window.makeKeyAndOrderFront(nil)

        } else {
            // 普通窗口模式
            window.styleMask = [.titled, .closable, .resizable]
            window.isOpaque = true
            window.backgroundColor = NSColor.windowBackgroundColor
            window.ignoresMouseEvents = false
            window.level = .normal
            window.collectionBehavior = [.managed]

            window.makeKeyAndOrderFront(nil)
        }
    }

    private func saveWindowFrame() {
        guard let screen = window.screen else { return }

        let screenFrame = screen.visibleFrame
        let frame = window.frame

        let left = frame.minX - screenFrame.minX
        let right = screenFrame.maxX - frame.maxX
        let top = screenFrame.maxY - frame.maxY
        let bottom = frame.minY - screenFrame.minY

        let centerX = abs(frame.midX - screenFrame.midX)
        let centerY = abs(frame.midY - screenFrame.midY)

        var corner = ""
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0

        // 横向判断
        if centerX < 10 {
            corner = "centerX"
            offsetX = 0
        } else if left < right {
            corner = "left"
            offsetX = left
        } else {
            corner = "right"
            offsetX = right
        }

        // 纵向判断
        if centerY < 10 {
            corner += "CenterY"
            offsetY = 0
        } else if bottom < top {
            corner += "Bottom"
            offsetY = bottom
        } else {
            corner += "Top"
            offsetY = top
        }

        let dict: [String: Any] = [
            "corner": corner,
            "offsetX": offsetX,
            "offsetY": offsetY,
            "width": frame.width,
            "height": frame.height
        ]

        UserDefaults.standard.set(dict, forKey: "SavedWindowFrame")
    }


    private func restoreWindowFrame() {
        guard
            let dict = UserDefaults.standard.dictionary(forKey: "SavedWindowFrame") as? [String: Any],
            let screen = NSScreen.main
        else { 
            self.positionWindow()
            return 
        }

        let screenFrame = screen.visibleFrame

        let corner = dict["corner"] as? String ?? "bottomRight"
        let offsetX = dict["offsetX"] as? CGFloat ?? 20
        let offsetY = dict["offsetY"] as? CGFloat ?? 20
        let width = dict["width"] as? CGFloat ?? 200
        let height = dict["height"] as? CGFloat ?? 60

        var x: CGFloat = 0
        var y: CGFloat = 0

        switch corner {
        case "centerXCenterY":
            x = screenFrame.midX - width / 2
            y = screenFrame.midY - height / 2

        case "centerXBottom":
            x = screenFrame.midX - width / 2
            y = screenFrame.minY + offsetY

        case "centerXTop":
            x = screenFrame.midX - width / 2
            y = screenFrame.maxY - height - offsetY

        case "leftCenterY":
            x = screenFrame.minX + offsetX
            y = screenFrame.midY - height / 2

        case "rightCenterY":
            x = screenFrame.maxX - width - offsetX
            y = screenFrame.midY - height / 2

        case "leftBottom":
            x = screenFrame.minX + offsetX
            y = screenFrame.minY + offsetY

        case "leftTop":
            x = screenFrame.minX + offsetX
            y = screenFrame.maxY - height - offsetY

        case "rightBottom":
            x = screenFrame.maxX - width - offsetX
            y = screenFrame.minY + offsetY

        case "rightTop":
            x = screenFrame.maxX - width - offsetX
            y = screenFrame.maxY - height - offsetY

        default:
            x = screenFrame.maxX - width - 20
            y = screenFrame.minY + 20
        }

        let frame = NSRect(x: x, y: y, width: width, height: height)
        window.setFrame(frame, display: true)
    }

    func windowWillClose(_ notification: Notification) {
        saveWindowFrame()
        NSApp.terminate(nil)
    }

}
