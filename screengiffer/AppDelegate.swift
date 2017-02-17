//
//  AppDelegate.swift
//  screengiffer
//
//  Created by Nico Richard on 2017-02-17.
//  Copyright © 2017 CityTransit. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreGraphics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem: NSStatusItem = {
        let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        let image = NSImage(named: "BarIcon")
        image?.isTemplate = true // Adjusts image for dark mode
        statusItem.image = image
        return statusItem;
    }()
    
    let screenRecorder: ScreenRecorder = ScreenRecorder()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.action = #selector(menuIconClicked(_:))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func menuIconClicked(_ sender: Any) {
        if screenRecorder.isRecording() {
            screenRecorder.startRecording()
        } else {
            screenRecorder.stopRecording()
        }
    }

    func quit() {
        NSApp.terminate(self)
    }
}
