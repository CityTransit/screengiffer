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
    
    let statusItem: NSStatusItem = {
        
        let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        
        statusItem.defaultIcon()
        
        return statusItem;
    }()
    
    let overlayController = OverlayWindowController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        ScreenRecorder.shared.statusItem = statusItem
        statusItem.action = #selector(menuIconClicked(_:))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func menuIconClicked(_ sender: Any) {
        
        if !ScreenRecorder.shared.isRecording() {
            
            if let button = sender as? NSStatusBarButton {
                if let screen = button.window?.screen {
                    
                    ScreenRecorder.shared.screen = screen
                    
                    self.overlayController.show(on: screen)
                }
            }
        } else {
            ScreenRecorder.shared.stopRecording()
        }
    }

    func quit() {
        NSApp.terminate(self)
    }
}
