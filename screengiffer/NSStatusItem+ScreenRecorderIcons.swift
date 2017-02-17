//
//  ScreenRecorderStatusItem.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Cocoa

class NSStatusItemImages: NSObject {
    static let defaultImage: NSImage? = {
        let image = NSImage(named: "BarIcon")
        image?.isTemplate = true // Adjusts image for dark mode
        return image
    }()
    
    static let recordingImage: NSImage? = {
        let image = NSImage(named: "BarIconStop")
        image?.isTemplate = true // Adjusts image for dark mode
        return image
    }()
}

extension NSStatusItem {
    
    func defaultIcon() {
        self.image = NSStatusItemImages.defaultImage
    }
    
    func recordingIcon() {
        self.image = NSStatusItemImages.recordingImage
    }
}
