import Cocoa
import FlutterMacOS
import SwiftUI
import UserNotifications

@NSApplicationMain
class AppDelegate: FlutterAppDelegate, UNUserNotificationCenterDelegate {
    private var clipboardTimer: Timer?
    private var lastCopiedText: String?
    private var methodChannel: FlutterMethodChannel?
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var flutterViewController: FlutterViewController?

    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        flutterViewController = mainFlutterWindow?.contentViewController as? FlutterViewController
        methodChannel = FlutterMethodChannel(name: "clipboard_monitor", binaryMessenger: flutterViewController!.engine.binaryMessenger)

        startClipboardMonitoring()
        setupStatusBarItem()

        mainFlutterWindow?.styleMask.remove(.fullScreen)
        setInitialWindowSize()

        // Request notification permissions and set the delegate
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }

        super.applicationDidFinishLaunching(aNotification)
    }

    private func bringToFront() {
        NSApp.activate(ignoringOtherApps: true)
    }

    override func applicationWillTerminate(_ aNotification: Notification) {
        clipboardTimer?.invalidate()
    }

    private func startClipboardMonitoring() {
        clipboardTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
    }

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
            } else {
                button.image = NSImage(named: NSImage.Name("NSMenuOnStateTemplate"))
            }
               button.action = #selector(AppDelegate.togglePopover(sender:))
               button.target = self // Ensure the target is set to the AppDelegate instance
        popover = NSPopover()
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: FlutterViewWrapper(flutterViewController: flutterViewController!))
        }

        popover = NSPopover()
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: FlutterViewWrapper(flutterViewController: flutterViewController!))
    }

    @objc private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if let copiedText = pasteboard.string(forType: .string), copiedText != lastCopiedText {
            lastCopiedText = copiedText
            methodChannel?.invokeMethod("clipboardChanged", arguments: copiedText)
        }
    }

    private func setInitialWindowSize() {
        mainFlutterWindow?.setContentSize(NSSize(width: 350, height: 500))
        mainFlutterWindow?.minSize = NSSize(width: 350, height: 500)
    }

 @objc private func togglePopover(sender: AnyObject?) {
     if let button = statusItem?.button {
         if popover?.isShown == true {
             popover?.performClose(sender)
         } else {
             popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
             NSApp.activate(ignoringOtherApps: true)

         }
     }
 }

    // Implement UNUserNotificationCenterDelegate method
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        bringToFront()
        completionHandler()
    }
}

struct FlutterViewWrapper: NSViewControllerRepresentable {
    var flutterViewController: FlutterViewController

    func makeNSViewController(context: Context) -> NSViewController {
        return flutterViewController
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
}
