//
//  ScreenRecorder.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreGraphics
import CoreVideo

class ScreenRecorderFrame: NSObject {
    let image: NSImage
    let duration: Float
    
    init(image: NSImage, duration: Float) {
        self.image = image
        self.duration = duration
    }
}

class ScreenRecorder: NSObject {
    
    var captureSession: AVCaptureSession?
    var output: AVCaptureVideoDataOutput?
    
    var statusItem: NSStatusItem?
    
    var frames: [ScreenRecorderFrame]? = []
    
    static let shared = ScreenRecorder()
    
    private override init() {
        super.init()
    }
    
    func menuIconClicked(_ sender: Any) {
        if (captureSession == nil) || !(captureSession!.isRunning) {
            startRecording()
        } else {
            captureSession?.stopRunning()
        }
    }
    
    func isRecording() -> Bool {
        return captureSession != nil && captureSession!.isRunning
    }
    
    func startRecording(rect: CGRect? = nil) {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        
        // TODO: OTHER MONITORS
        //Display = CGGetDisplaysWithPoint... etc
        let input = AVCaptureScreenInput(displayID: CGMainDisplayID())
        
        if let rect = rect {
            input?.cropRect = rect
        }
        
        input?.capturesMouseClicks = true
        input?.capturesCursor = false
        
        captureSession?.addInput(input)
        
        output = AVCaptureVideoDataOutput()
        output?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        captureSession?.addOutput(output)
        
        captureSession?.startRunning()
        output?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.citytransit.screenrecorder"))

        statusItem?.recordingIcon()
    }
    
    func stopRecording() {
        
        captureSession?.stopRunning()
        
        if let _ = frames {
            Giffer.createGif(path(), frames: frames!) { success in
                self.frames = []
            }
        }
        
        statusItem?.defaultIcon()
    }
    
    func path() -> URL {
        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Desktop/" + filename())
    }
    
    func filename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return "screengiffer-\(dateFormatter.string(from: Date())).gif"
    }
}

extension ScreenRecorder: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

        if !isRecording() {
            return
        }

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let durationCM = CMSampleBufferGetDuration(sampleBuffer)
        let durationSeconds = Float(durationCM.value) / Float(durationCM.timescale)
        
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0));
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        let width = CVPixelBufferGetWidth(imageBuffer);
        let height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data
        if let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8,
                                   bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue ) {

            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0));
            
            // Create a Quartz image from the pixel data in the bitmap graphics context
            if let quartzImage = context.makeImage() {
                // Create an image object from the Quartz image
                let image = NSImage(cgImage: quartzImage, size: NSSize(width: width, height: height))
                if frames == nil {
                    frames = []
                }
                frames?.append(ScreenRecorderFrame(image: image, duration: durationSeconds))
            }
        } else {
            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0));
        }

    }
}
