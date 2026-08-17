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

                let imageURL = args["imageURL"] as? String

                self.ImportImg(id: id, imageURL: imageURL)

                result(nil)



            case "destroyOverlay":
                if let args = call.arguments as? [String: Any],
                let id = args["id"] as? Int {

                    self.destroyOverlay(id: id)
                }
                result(nil)

            case "updateOverlay":

                if let args = call.arguments as? [String: Any],
                let id = args["id"] as? Int,
                let property = args["property"] as? String,
                let value = args["value"] as? String {
                    self.updateOverlay(
                        id: id,
                        property: property,
                        value: value
                    )
                } else {
                    print("Invalid updateOverlay arguments")
                }


            case "ToggleVisibility":
                if let args = call.arguments as? [String: Any],
                let id = args["id"] as? Int {

                    self.toggleVisibility(id: id)
                }
                result(nil)

            case "displayInfo":

                guard let args = call.arguments as? [String: Any],
                    let id = args["id"] as? Int else {
                    
                    result(FlutterError(
                        code: "INVALID_ARGS",
                        message: "Missing id",
                        details: nil
                    ))
                    print("tung1")
                    return
                }

                self.passLayerInfo(id: id)

                result(nil)
            case "modifyProperty":
                guard let args = call.arguments as? [String: Any],
                    let id = args["id"] as? Int,
                    let property = args["property"] as? String,
                    let change = args["change"] as? String else {
                    result(FlutterError(
                        code: "INVALID_ARGS",
                        message: "Missing or invalid arguments",
                        details: nil
                    ))
                    return
                }
                self.updateOverlay(id:id, property:property, value:change)

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
//make a function getting the id of the layer and send its info back to dart.
//

    func toggleVisibility(id: Int) {
        print("Hi")
        guard let panel = layerCollection[id] else {
            return
        }

        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.orderFront(nil)
        }
    }


    func layerObserver(panel: NSPanel) { // add on creation of layer
        panel.addObserver(
            self, //register the function to appdelegate
            forKeyPath: "frame",
            options: [.new],
            context: nil
        )
    }

    override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey : Any]?,
    context: UnsafeMutableRawPointer?
    ) {
    guard keyPath == "frame",
        let panel = object as? NSPanel else {
        return
    }

    guard let id = layerCollection.first(where: {
        $0.value === panel
    })?.key else {
        return
    }

    passLayerInfo(id: id) //this should send everything to dart
    }

    func passLayerInfo(id:Int) {
        guard let layer=layerCollection[id] else{
            print("No such id")
            return
        }

        let frame=layer.frame
        print(id, frame.size.width)
        overlayChannel?.invokeMethod (
            "layerInfo",
            arguments: [
            "id":id,
            "width": frame.size.width,
            "height": frame.size.height,
            "x": frame.origin.x,
            "y": frame.origin.y
            ]
        )
    }

    func updateOverlay(id:Int, property: String, value: String) {
        guard let layer=layerCollection[id] else {
            return
        }

        switch property {
        case "width":

            if let width = Double(value) {

                var frame = layer.frame

                frame.size.width = width

                layer.setFrame(
                    frame,
                    display: true
                )
            }

        case "height":

            if let height = Double(value) {

                var frame = layer.frame

                frame.size.height = height

                layer.setFrame(
                    frame,
                    display: true
                )
            }

        case "x":

            if let x = Double(value) {

                var frame = layer.frame

                frame.origin.x = x

                layer.setFrame(
                    frame,
                    display: true
                )
            }

        case "y":

            if let y = Double(value) {

                var frame = layer.frame

                frame.origin.y = y

                layer.setFrame(
                    frame,
                    display: true
                )
            }
        case "name":
            print("Tung tung sahur"); //lowkey have to change name
            //No need for changing name
        default:
            print("Unknown property")
        }
    }
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
      layerObserver(
        panel: window
      )
  }

/// ### DESTROYING THE OVERLAY

    func destroyOverlay(id:Int) {
        layerCollection[id]?.close()
        layerCollection.removeValue(forKey: id)
    }


/// ### Importing a supported file types [PNG, GIF] into the created OVERLAY
    func ImportImg(id: Int, imageURL: String?) {
        if let imageURL = imageURL {

            createOverlay(id: id)
            let developmentURL = URL(fileURLWithPath: imageURL)

            if let image = NSImage(contentsOf: developmentURL) {
                displayImage(image, id: id)
                return
            }

            // If development path didn't work, look inside the
            // packaged Flutter application.
            let bundledURL = Bundle.main.bundleURL
                .appendingPathComponent("Contents/Frameworks/App.framework")
                .appendingPathComponent("Versions/A/Resources/flutter_assets")
                .appendingPathComponent(imageURL)

            guard let image = NSImage(contentsOf: bundledURL) else {
                print("Couldn't load image")
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


    //-----
    override func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        return true
    }

    override func applicationWillTerminate(_ notification: Notification) {
        for (_, panel) in layerCollection {
            panel.close()
        }

        layerCollection.removeAll()
    }
}
//------------------------------------------------------

class DraggableImageView: NSImageView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

}


