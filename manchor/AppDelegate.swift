import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var windowManager: WindowManager!
    var statusBarController: StatusBarController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 创建透明窗口
        windowManager = WindowManager()

        // 创建菜单栏图标
        statusBarController = StatusBarController(windowManager: windowManager)

    }
}
