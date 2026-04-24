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
        let frame = window.frame
        let dict: [String: CGFloat] = [
            "x": frame.origin.x,
            "y": frame.origin.y,
            "w": frame.size.width,
            "h": frame.size.height
        ]
        UserDefaults.standard.set(dict, forKey: "SavedWindowFrame")
    }

    private func restoreWindowFrame() {
        guard let dict = UserDefaults.standard.dictionary(forKey: "SavedWindowFrame") as? [String: CGFloat] else { 
            self.positionWindow()
            return 
        }

        let x = dict["x"] ?? 0
        let y = dict["y"] ?? 0
        let w = dict["w"] ?? 200
        let h = dict["h"] ?? 60

        let frame = NSRect(x: x, y: y, width: w, height: h)
        window.setFrame(frame, display: true)
    }

    func windowWillClose(_ notification: Notification) {
        saveWindowFrame()
        NSApp.terminate(nil)
    }

}
