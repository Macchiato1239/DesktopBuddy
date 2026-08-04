import Cocoa
import FlutterMacOS
import AppKit
import SwiftUI
import UniformTypeIdentifiers

@main

//toggling draggability on NSImageView without having a title bar
class AppDelegate: FlutterAppDelegate {
    var imageAdded: Bool = false
    var layerCollection: [Int: NSPanel] = [:]
    //start storing the overlays in a dict instead
    override func applicationDidFinishLaunching(
        _ notification: Notification
    ) {
        guard let window = mainFlutterWindow,
              let controller = window.contentViewController as? FlutterViewController
        else {
            return
        }

// ###SECTION: HEARING MESSAGES FROM DART

        let overlayChannel = FlutterMethodChannel(
            name: "overlay_window",
            binaryMessenger: controller.engine.binaryMessenger
        )
        overlayChannel.setMethodCallHandler { call, result in
            switch call.method {
            
            case "ImportImg":
                guard let args = call.arguments as? [String: Any],
                    let index = args["index"] as? Int else {
                    result(FlutterError(
                        code: "INVALID_ARGS",
                        message: "Missing index",
                        details: nil))
                    return
                }

                let imageName = args["imageName"] as? String

                self.ImportImg(index: index, imageName: imageName)

                result(nil)



            case "destroyOverlay":
                if let args = call.arguments as? [String: Any],
                let index = args["index"] as? Int {

                    self.destroyOverlay(index: index)
                }
                result(nil)
            default:
            result(
                FlutterMethodNotImplemented
            )
            }
        }

        super.applicationDidFinishLaunching(notification)
    }

/// ## FUNCTIONS

/// ### CREATING AN OVERLAY to import images/gifs into it

  func createOverlay(index:Int) {
      let window = NSPanel( //Variable for the child transparent frame
          contentRect: NSRect(
              x: 100,
              y: 500,
              width: 200,
              height: 200
          ),
          styleMask:[
            .borderless,
            .nonactivatingPanel
            ],
          backing: .buffered,
          defer: false
      )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [
            .stationary, //reduces the flicker whenever switching between windows on macbook.
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
        window.ignoresMouseEvents = false
        window.hidesOnDeactivate = false //

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
      window.contentView = view
      window.hasShadow=false

      layerCollection[index]=window
      window.orderFront(nil)
  }

/// ### DESTROYING THE OVERLAY

    func destroyOverlay(index:Int) {
        layerCollection[index]?.close()
        layerCollection.removeValue(forKey: index)
    }


/// ### Importing a supported file types [PNG, GIF] into the created OVERLAY
    func ImportImg(index: Int, imageName: String?) {
        if let imageName = imageName {

            createOverlay(index: index)

            guard let image = NSImage(named: imageName) else {
                print("Couldn't load image named \(imageName)")
                return
            }

            displayImage(image, index: index)

        } else {

            guard let window = mainFlutterWindow else {
                return
            }

            let openPanel = NSOpenPanel()
            // ...

            openPanel.beginSheetModal(for: window) { [weak self] response in
                if response == .OK,
                let selectedURL = openPanel.url {

                    self?.createOverlay(index: index)
                    self?.importSelectedImage(from: selectedURL, index: index)
                }
            }
        }
    }
//

    func displayImage(_ image: NSImage, index: Int) {
        guard let contentView = layerCollection[index]?.contentView else {
            print("No overlay for index \(index)")
            return
        }

        contentView.subviews.forEach {
            if $0 is NSImageView {
                $0.removeFromSuperview()
            }
        }

        let imageView = DraggableImageView(frame: contentView.bounds)
        imageView.image = image
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.autoresizingMask = [.width, .height]

        contentView.addSubview(imageView)
        imageAdded = true
    }

/// ###LOAD THE FILE INTO AN NSImage and PUT IT IN THE OVERLAY

    func importSelectedImage(from url: URL, index: Int) {
        guard let image = NSImage(contentsOf: url) else {
            print("Could not load selected image")
            return
        }
        displayImage(image, index: index)
    }
}
//------------------------------------------------------

class DraggableImageView: NSImageView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

}


