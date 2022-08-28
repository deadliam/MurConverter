//
//  StatusMenuController.swift
//  MurConverter
//
//  Created by Anatolii Kasianov on 07.08.2022.
//

import Foundation
import Cocoa

class StatusMenuController {
    
    var statusItem: NSStatusItem
    let popover = NSPopover()
    let menu = NSMenu()
    
    init(image: NSImage) {
        self.statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        self.statusItem.button?.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStatusMenu() {
        statusItem.button?.target = self
        statusItem.button?.action = #selector(self.statusBarButtonClicked(_:))
        statusItem.button?.sendAction(on: [.leftMouseDown, .rightMouseUp])
//        statusItem.button?.title = "MurConverter"
        popover.behavior = .semitransient
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
//            print("Right Click")
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
//            print("Left Click")
            togglePopover(sender)
            statusItem.menu = nil
        }
    }

    @objc func togglePopover(_ sender: Any?) {
        popover.contentViewController = SettingsViewController.freshController()
        
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    @objc func showPopover(_ sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }

    func closePopover(_ sender: Any?) {
        popover.performClose(sender)
    }
}

extension NSEvent {
    var isRightClickUp: Bool {
        let rightClick = (self.type == .rightMouseUp)
        let controlClick = self.modifierFlags.contains(.control)
        return rightClick || controlClick
    }
}
