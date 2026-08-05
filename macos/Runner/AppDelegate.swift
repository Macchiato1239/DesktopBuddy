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
    var overlayChannel: FlutterMethodChannel?
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

        overlayChannel = FlutterMethodChannel(
            name: "overlay_window",
            binaryMessenger: controller.engine.binaryMessenger
        )
        overlayChannel?.setMethodCallHandler { call, result in
            switch call.method {
            
            case "ImportImg":
                guard let args = call.arguments as? [String: Any],
                    let id = args["id"] as? Int else {
                    result(FlutterError(
                        code: "INVALID_ARGS",
                        message: "Missing index",
                        details: nil))
                    return
                }

                let imageName = args["imageName"] as? String

                self.ImportImg(id: id, imageName: imageName)

                result(nil)



            case "destroyOverlay":
                if let args = call.arguments as? [String: Any],
                let id = args["id"] as? Int {

                    self.destroyOverlay(id: id)
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

  func createOverlay(id:Int) {
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

      layerCollection[id]=window //--saving the overlay to the dict with an index key
      window.orderFront(nil)
  }

/// ### DESTROYING THE OVERLAY

    func destroyOverlay(id:Int) {
        layerCollection[id]?.close()
        layerCollection.removeValue(forKey: id)
    }


/// ### Importing a supported file types [PNG, GIF] into the created OVERLAY
    func ImportImg(id: Int, imageName: String?) {
        if let imageName = imageName {

            createOverlay(id: id)

            guard let image = NSImage(named: imageName) else {
                print("Couldn't load image named \(imageName)")
                return
            }

            displayImage(image, id: id)

        } else {

            guard let window = mainFlutterWindow else {
                return
            }

            let openPanel = NSOpenPanel()
            // ...

            openPanel.beginSheetModal(for: window) { [weak self] response in
                if response == .OK,
                let selectedURL = openPanel.url {
                    //send a message to dart to save the display index and the id of the layer
                    self?.createOverlay(id: id)
                    self?.importSelectedImage(from: selectedURL, id: id)

                    self?.overlayChannel?.invokeMethod(
                        "ImportSuccess",
                        arguments: [
                            "id": id,
                        ]
                    )
                }
            }
        }
    }
//

    func displayImage(_ image: NSImage, id: Int) {
        guard let contentView = layerCollection[id]?.contentView else {
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

    func importSelectedImage(from url: URL, id: Int) {
        guard let image = NSImage(contentsOf: url) else {
            print("Could not load selected image")
            return
        }
        displayImage(image, id: id)
    }
}
//------------------------------------------------------

class DraggableImageView: NSImageView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

}


