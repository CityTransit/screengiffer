//
//  OverlayWindowController.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Cocoa
import Carbon

class OverlayWindowController: NSWindowController {
    
    fileprivate var startPoint: NSPoint!
    
    let panel = OverlayWindowPanel(contentRect: NSRect.zero, styleMask: NSNonactivatingPanelMask, backing: NSBackingStoreType.buffered, defer: false)
    
    init() {
        super.init(window: panel)
        panel.delegate = self
        startPoint = NSPoint.zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("Initializer not implemented")
    }
    
    var overlayPanel: OverlayWindowPanel? {
        get {
            return self.window as? OverlayWindowPanel
        }
    }
    
    override var acceptsFirstResponder: Bool{
        return true
    }
    
    func show(on screen: NSScreen) {
        self.window?.setFrame(screen.frame, display: true)
        self.showWindow(self)
        self.window?.becomeKey()
        overlayPanel?.crop(rect: CGRect.zero)
    }
    
    func hide() {
        overlayPanel?.crop(rect: CGRect.zero)
        self.window?.orderOut(self)
    }
    
    func rectFromStart(to endPoint: NSPoint) -> CGRect {
        return CGRect(x: min(startPoint.x, endPoint.x), y: min(startPoint.y, endPoint.y),
                              width: fabs(startPoint.x - endPoint.x), height: fabs(startPoint.y - endPoint.y))

    }
}

extension OverlayWindowController: NSWindowDelegate {
    
    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
    }
    
    override func mouseUp(with event: NSEvent) {
        hide()
        ScreenRecorder.shared.startRecording(rect: rectFromStart(to: event.locationInWindow))
        startPoint = NSPoint.zero
    }

    override func mouseDragged(with event: NSEvent) {
        overlayPanel?.crop(rect: rectFromStart(to:event.locationInWindow))
    }
    
    override func keyDown(with event: NSEvent) {
        switch(Int(event.keyCode)) {
            case kVK_Escape:
                hide()
                startPoint = NSPoint.zero
            default:
                super.keyDown(with: event)
        }
    }
}
