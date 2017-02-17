//
//  ScreenRecorder.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Foundation
import AVFoundation
import CoreGraphics

class ScreenRecorder: NSObject {
    
    var captureSession: AVCaptureSession?
    var output: AVCaptureMovieFileOutput?
    
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
    
    func startRecording() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        
        //Display = CGGetDisplaysWithPoint... etc
        let input = AVCaptureScreenInput(displayID: CGMainDisplayID())
        captureSession?.addInput(input)
        
        output = AVCaptureMovieFileOutput()
        captureSession?.addOutput(output)
        
        captureSession?.startRunning()
        
        let outputPath = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(filename())
        output?.startRecording(toOutputFileURL: outputPath, recordingDelegate: self)
    }
    
    func stopRecording() {
        captureSession?.stopRunning()
    }
    
    func filename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return "Desktop/screengiffer-\(dateFormatter.string(from: Date())).mov"
    }
}


extension ScreenRecorder: AVCaptureFileOutputRecordingDelegate{
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        captureSession?.stopRunning()
    }
}

