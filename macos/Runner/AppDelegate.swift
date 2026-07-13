import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

    var overlayWindow: NSPanel?

    override func applicationDidFinishLaunching(
        _ notification: Notification
    ) {

        guard let window = mainFlutterWindow,
              let controller = window.contentViewController as? FlutterViewController
        else {
            return
        }

        let overlayChannel = FlutterMethodChannel(
            name: "overlay_window",
            binaryMessenger: controller.engine.binaryMessenger
        )
        overlayChannel.setMethodCallHandler { call, result in

            switch call.method {

            case "showOverlay":
                self.createOverlay()
                print("Main:", self.mainFlutterWindow as Any)
                print("Overlay:", self.overlayWindow as Any)
                result(nil as Any?)
            
            case "destroyOverlay":
                self.destroyOverlay()
                result(nil as Any?)

            case "addImage":
                DispatchQueue.main.async {
                    print("image added")
                    self.addImage()
                }
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

      let inviswindow = NSPanel( //Variable for the child transparent frame
          contentRect: NSRect(
              x: 100,
              y: 500,
              width: 200,
              height: 200
          ),
          styleMask:[
            .borderless,
            .titled,
            .nonactivatingPanel
            ],
          backing: .buffered,
          defer: false
      )

        inviswindow.isOpaque = false
        inviswindow.backgroundColor = .clear
        inviswindow.level = .floating
        inviswindow.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
        inviswindow.ignoresMouseEvents = false
        inviswindow.hidesOnDeactivate = false

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
      inviswindow.contentView = view

      overlayWindow = inviswindow //to check if the overlay window already exists or not.

      inviswindow.orderFront(nil)
  }
    func destroyOverlay() {//Destroy all overlay window?//Later should use a key detection
    // to identify the specific overlay window chosen to be killed
        overlayWindow?.close()
        overlayWindow=nil
    }
    func addImage() {
        let image1=NSImageView(frame: NSRect(
            x: 0,
            y: 0,
            width: 200,
            height: 200
        ))
        let image1_image=NSImage(named: "TestIcon")
        image1.image=image1_image
        print("Image:", image1_image as Any)
        image1.imageScaling = .scaleProportionallyUpOrDown
        overlayWindow?.contentView?.addSubview(image1)
        image1.frame = overlayWindow!.contentView!.bounds
    }
}

