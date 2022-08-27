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
    
    init(image: NSImage) {
        self.statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        self.statusItem.button?.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStatusMenu() {
        statusItem.button?.target = self
        statusItem.button?.action = #selector(self.statusMenuButtonClicked(_:))
        statusItem.button?.sendAction(on: [.leftMouseDown, .rightMouseUp])
//        statusItem.button?.title = "MurConverter"
    }

    @objc func statusMenuButtonClicked(_ sender: NSStatusBarButton) {

        if let event = NSApp.currentEvent, event.isRightClickUp {
            // handle right-click
            showMenuAdditional()
        } else {
            // handle left-click
            togglePopover(sender)
        }
    }
    
    @objc func togglePopover(_ sender: Any?) {
        popover.contentViewController = SettingsViewController.freshController()
        
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }

    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    
    func showMenuAdditional() {
        let menu = NSMenu()

//        let openWindow = NSMenuItem(title: "Open", action: #selector(openWindow) , keyEquivalent: "o")
//        openWindow.target = self
//        menu.addItem(openWindow)
//        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
}

extension NSEvent {
    var isRightClickUp: Bool {
        let rightClick = (self.type == .rightMouseUp)
        let controlClick = self.modifierFlags.contains(.control)
        return rightClick || controlClick
    }
}
