//
//  Giffer.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Cocoa
import CoreGraphics

class Giffer: NSObject {
    static func createGif(_ fileUrl: URL, frames: [ScreenRecorderFrame], completion: @escaping (Bool) -> ()) {
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [
            kCGImagePropertyGIFLoopCount as String: 0
            ]]
        
        guard let destination = CGImageDestinationCreateWithURL(fileUrl as CFURL, kUTTypeGIF, frames.count, nil) else {
            completion(false)
            return
        }
        
        for currentFrame in frames {
            
            let frameProperties = [kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: currentFrame.duration
                ]]
            
            var imageRect: CGRect = CGRect(x:0, y:0, width:currentFrame.image.size.width, height:currentFrame.image.size.height)
            if let imageRef = currentFrame.image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) {
                CGImageDestinationAddImage(destination, imageRef, frameProperties as CFDictionary)
            }
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        if !CGImageDestinationFinalize(destination) {
            completion(false)
        }
        else {
            completion(true)
        }
    }
}
