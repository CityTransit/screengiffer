//
//  OverlayWindowPanel.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Cocoa
import CoreGraphics

class OverlayWindowPanel: NSPanel {
    
    let selectionMaskContainer = SelectionMaskContainerView(frame: NSRect.zero)
    
    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        self.isFloatingPanel = true
        self.collectionBehavior = [NSWindowCollectionBehavior.canJoinAllSpaces, NSWindowCollectionBehavior.fullScreenAuxiliary]
        self.backgroundColor = NSColor.black.withAlphaComponent(0.5)
        self.isMovableByWindowBackground = false
        self.isExcludedFromWindowsMenu = true
        self.alphaValue = 1.0
        self.isOpaque = false
        self.hasShadow = false
        self.hidesOnDeactivate = false
        self.level = Int(CGWindowLevelForKey(.maximumWindow))
        self.isRestorable = false
        self.disableSnapshotRestoration()
        self.contentView = selectionMaskContainer
    }

    func crop(rect: CGRect) {
        self.selectionMaskContainer.selectionMask.frame = rect
    }
    
    override var acceptsFirstResponder: Bool{
        return true;
    }
    
    override var canBecomeKey: Bool{
        return true;
    }
}
