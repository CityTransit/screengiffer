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

class ScreenRecorder: NSObject {
    
    var captureSession: AVCaptureSession?
    var output: AVCaptureMovieFileOutput?
    var statusItem: NSStatusItem?
    
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
        
        output = AVCaptureMovieFileOutput()
        captureSession?.addOutput(output)
        
        captureSession?.startRunning()
        output?.startRecording(toOutputFileURL: path(), recordingDelegate: self)

        let alternateImage = NSImage(named: "BarIconStop")
        alternateImage?.isTemplate = true
        statusItem?.recordingIcon()
    }
    
    func stopRecording() {
        output?.stopRecording()
        statusItem?.defaultIcon()
    }
    
    func path() -> URL {
        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Desktop/" + filename())
    }
    
    func filename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return "screengiffer-\(dateFormatter.string(from: Date())).mov"
    }
}


extension ScreenRecorder: AVCaptureFileOutputRecordingDelegate{
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        captureSession?.stopRunning()
    }
}

