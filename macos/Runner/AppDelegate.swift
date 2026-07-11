import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

    var overlayWindow: NSWindow?

    override func applicationDidFinishLaunching(
        _ notification: Notification
    ) {

        guard let window = mainFlutterWindow,
              let controller = window.contentViewController as? FlutterViewController
        else {
            return
        }

        let channel = FlutterMethodChannel(
            name: "overlay_window",
            binaryMessenger: controller.engine.binaryMessenger
        )

        channel.setMethodCallHandler { call, result in

            switch call.method {

            case "showOverlay":
                self.createOverlay()
                result(nil as Any?)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        super.applicationDidFinishLaunching(notification)
    }

  func createOverlay() {

      if overlayWindow != nil {
          overlayWindow?.orderFront(nil)
          return
      }

      let window = NSWindow(
          contentRect: NSRect(
              x: 500,
              y: 500,
              width: 200,
              height: 200
          ),
          styleMask: [.borderless],
          backing: .buffered,
          defer: false
      )

      window.isOpaque = false
      window.backgroundColor = .clear
      window.level = .floating
      window.collectionBehavior = [.canJoinAllSpaces]

      // TEST CONTENT
      let view = NSView(
          frame: NSRect(
              x: 0,
              y: 0,
              width: 200,
              height: 200
          )
      )

      view.wantsLayer = true
      view.layer?.backgroundColor = NSColor.red.cgColor

      window.contentView = view

      overlayWindow = window

      window.makeKeyAndOrderFront(nil)
  }
}