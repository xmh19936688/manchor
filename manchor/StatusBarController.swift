import Cocoa

class StatusBarController: NSObject {

    private var statusItem: NSStatusItem!
    private weak var windowManager: WindowManager?

    init(windowManager: WindowManager) {
        self.windowManager = windowManager
        super.init()
        setupStatusBar()
        setupEventMonitor()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
            button.target = self
            button.action = #selector(leftClickHandler(_:))   // 只处理左键
        }
    }

    // MARK: - 左键处理（单击无动作，双击切换模式）
    @objc private func leftClickHandler(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .leftMouseUp {
            if event.clickCount == 2 {
                windowManager?.toggleWindowMode()
            }
            // 单击不做任何事
        }
    }

    // MARK: - 右键监听器
    private func setupEventMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: [.rightMouseUp]) { [weak self] event in
            if let button = self?.statusItem.button,
               event.window == button.window {
                self?.showMenu()
                return nil   // 吞掉事件
            }
            return event
        }
    }

    // MARK: - 自定义菜单
    private func showMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(
            title: windowManager?.isTransparent == true ? "Unlock" : "Lock",
            action: #selector(toggleMode),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)

        // 在图标下方弹出菜单
        if let button = statusItem.button {
            menu.popUp(positioning: nil,
                       at: NSPoint(x: 0, y: button.bounds.height),
                       in: button)
        }
    }

    @objc private func toggleMode() {
        windowManager?.toggleWindowMode()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
