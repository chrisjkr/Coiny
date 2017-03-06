//
//  PreferencesWindow.swift
//  Coiny
//
//  Created by Krzysztof Kraszewski on 06/03/17.
//  Copyright © 2017 Krzysztof Kraszewski. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidClose()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    var delegate: PreferencesWindowDelegate?

    @IBOutlet weak var intervalSlider: NSSlider!
    
    var defaults = UserDefaults.standard

    override var windowNibName: String! {
        return "PreferencesWindow"
    }
    @IBAction func intervalSliderUsed(_ sender: NSSliderCell) {
        let event = NSApplication.shared().currentEvent
        
        if event?.type == NSEventType.leftMouseUp {
            defaults.set(sender.doubleValue, forKey: "updateInterval")
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        intervalSlider.doubleValue = defaults.double(forKey: "updateInterval")
    }
    
    func windowWillClose(_ notification: Notification) {
        delegate?.preferencesDidClose()
    }
}
