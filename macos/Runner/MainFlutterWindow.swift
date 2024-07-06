import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Set maximum window size
    self.maxSize = NSSize(width: 350, height: 500)
    self.minSize = NSSize(width: 350, height: 500)
    self.styleMask.remove(.fullScreen)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  override func toggleFullScreen(_ sender: Any?) {
    // Prevent full-screen mode
  }
}
