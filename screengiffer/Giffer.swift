//
//  Giffer.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Cocoa
import CoreGraphics

class GifBuffer: NSObject {
    
    private var frames: Queue<ScreenRecorderFrame> = Queue<ScreenRecorderFrame>()
    private var complete = false
    private var running = false
    
    private let destination: CGImageDestination
    private let queue = DispatchQueue(label: "com.citytransit.screengiffer.gif.queue")
    private let fileProperties = [kCGImagePropertyGIFDictionary as String: [
        kCGImagePropertyGIFLoopCount as String: 0,
        ]]
    
    var endCalledCompletion: ((Bool) -> ())?
    
    init(_ fileUrl: URL) {
        guard let d = CGImageDestinationCreateWithURL(fileUrl as CFURL, kUTTypeGIF, frames.count, nil) else { fatalError("Failed creating image destination") }
        self.destination = d
    }
    
    func addFrame(_ frame: ScreenRecorderFrame) {
        frames.enqueue(frame)
        if !running && !complete {
            running = true
            run() {
                self.running = false
                if let c = self.endCalledCompletion {
                    self.end(completion: c)
                }
            }
        }
    }
    
    private func run(completion: @escaping () -> ()) {
        queue.async {
            while(!self.frames.isEmpty) {
                
                guard let currentFrame = self.frames.dequeue() else { return }
                
                let frameProperties = [kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFDelayTime as String: currentFrame.duration
                    ]]
                
                var imageRect: CGRect = CGRect(x:0, y:0, width:currentFrame.image.size.width, height:currentFrame.image.size.height)
                if let imageRef = currentFrame.image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) {
                    CGImageDestinationAddImage(self.destination, imageRef, frameProperties as CFDictionary)
                }
            }
            
            completion()
        }
    }
    
    func end(completion: @escaping (Bool) -> ()) {
        
        complete = true
        
        if !running {
            queue.async {
                completion(self.finalizeImage())
            }
        } else {
            endCalledCompletion = completion
        }
    }
    
    func finalizeImage() -> Bool {
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        if !CGImageDestinationFinalize(destination) {
            return false
        } else {
            return true
        }
    }
    
}

class Giffer: NSObject {

    static func createGif(_ fileUrl: URL, frames: [ScreenRecorderFrame], completion: @escaping (Bool) -> ()) {
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [
            kCGImagePropertyGIFLoopCount as String: 0,
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
