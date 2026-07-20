import Cocoa
import FlutterMacOS
import AppKit
import SwiftUI
import UniformTypeIdentifiers
@main


class AppDelegate: FlutterAppDelegate {
    var overlayWindow: NSPanel?
    var imageAdded: Bool = false

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

            case "showOverlay":
                self.createOverlay()
                print("Main:", self.mainFlutterWindow as Any)
                print("Overlay:", self.overlayWindow as Any)
                result(nil as Any?)
            
            case "destroyOverlay":
                self.destroyOverlay()
                result(nil as Any?)

            case "ImportImg":
                print("Importing 2")
                self.ImportImg()
                result(nil as Any?)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        super.applicationDidFinishLaunching(notification)
    }

/// ## FUNCTIONS

/// ### CREATING AN OVERLAY to import images/gifs into it

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
            .nonactivatingPanel
            ],
          backing: .buffered,
          defer: false
      )

        inviswindow.isOpaque = false
        inviswindow.backgroundColor = .clear
        inviswindow.level = .floating
        inviswindow.isMovableByWindowBackground = true
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

/// ### DESTROYING THE OVERLAY

    func destroyOverlay() {//Destroy all overlay window?//Later should use a key detection
    // to identify the specific overlay window chosen to be killed
        overlayWindow?.close()
        overlayWindow=nil
        imageAdded = false
    }


/// ### Importing a supported file types [PNG, GIF] into the created OVERLAY

    func ImportImg() { //OPEN THE OS's NATIVE LOCAL FILES BROWSER
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose an image to attach"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false

        //file types RESTRICTION
        openPanel.allowedContentTypes = [.png, .gif]

        //----------------------------

        guard let window = overlayWindow else {
            print("Error: No window found to present the file panel on.")
            return
        }
        openPanel.beginSheetModal(for: window) { [weak self] response in

        // If the user clicked "Open" (and didn't cancel)

        if response == .OK, let selectedURL = openPanel.url {
            print("User selected file: \(selectedURL.path)")
            
            // 5. Hand the URL off to your image importer
            self?.importSelectedImage(from: selectedURL) //SEND TO THE DISPLAY FUNC
            }
        }
    }

/// ###LOAD THE FILE INTO AN NSImage and PUT IT IN THE OVERLAY

    func importSelectedImage(from url: URL) {
    guard let contentView = overlayWindow?.contentView else {
        print("Error: No overlayWindow")
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
        overlayWindow?.contentView?.addSubview(image2)
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

