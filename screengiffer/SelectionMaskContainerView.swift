//
//  SelectionMaskContainerView.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Cocoa
import CoreGraphics

class SelectionMaskView: NSView {
    
    let backgroundColor: NSColor = NSColor.clear
    
    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.current()?.saveGraphicsState()
        self.backgroundColor.setFill()
        NSRectFill(dirtyRect)
        super.draw(dirtyRect)
        NSGraphicsContext.current()?.restoreGraphicsState()
    }
}

class SelectionMaskContainerView: NSView {
    
    let selectionMask: SelectionMaskView = SelectionMaskView(frame: CGRect.zero)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.autoresizingMask = [NSAutoresizingMaskOptions.viewHeightSizable, NSAutoresizingMaskOptions.viewWidthSizable]
        self.autoresizesSubviews = true
        
        self.addSubview(selectionMask)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Initializer not implemented")
    }
}
