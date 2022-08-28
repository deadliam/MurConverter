//
//  AppDelegate.swift
//  MurConverter
//
//  Created by Anatolii Kasianov on 07.08.2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
//    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    private(set) var image = NSImage(named: NSImage.Name("StatusItemIcon"))!
    lazy var menu = StatusMenuController(image: image)
    
    override init() {
        super.init()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        menu.setupStatusMenu()
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

