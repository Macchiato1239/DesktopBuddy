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
                if let args = call.arguments as? [String: Any],
                let index = args["index"] as? Int {

                    self.ImportImg(index: index)
                }
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
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
        window.ignoresMouseEvents = false
        window.hidesOnDeactivate = false

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

      layerCollection[index]=window
      window.orderFront(nil)
  }

/// ### DESTROYING THE OVERLAY

    func destroyOverlay(index:Int) {
        layerCollection[index]?.close()
        layerCollection.removeValue(forKey: index)
    }


/// ### Importing a supported file types [PNG, GIF] into the created OVERLAY

    func ImportImg(index:Int) {

        guard let window = mainFlutterWindow else {
            return
        }

        let openPanel = NSOpenPanel()

        openPanel.title = "Choose an image to attach"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false

        openPanel.allowedContentTypes = [.png, .gif]


        openPanel.beginSheetModal(
            for: window
        ) { [weak self] response in

            if response == .OK,
            let selectedURL = openPanel.url {

                self?.createOverlay(index:index)

                self?.importSelectedImage(
                    from: selectedURL,
                    index:index
                )
            }

        }
    }

/// ###LOAD THE FILE INTO AN NSImage and PUT IT IN THE OVERLAY

    func importSelectedImage(from url: URL, index:Int) {
    guard let contentView = layerCollection[index]?.contentView else {
        print("No overlay for index \(index)")
        return
    }
        
    // Load the image from the user-selected URL
    if let image = NSImage(contentsOf: url) {
        // Remove old image views if you only want one active image
        contentView.subviews.forEach { if $0 is NSImageView { $0.removeFromSuperview() } }
        
    //START CREATING THE IMAGE-->Use the class draggableImageView to make it draggable
        let image2 = DraggableImageView(frame: contentView.bounds)
        image2.image = image
        image2.imageScaling = .scaleProportionallyUpOrDown
        image2.autoresizingMask = [.width, .height]
        contentView.addSubview(image2)
        imageAdded = true
    } else {
        print("Could not load selected image")
        }
    }
}
//------------------------------------------------------

class DraggableImageView: NSImageView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

}


