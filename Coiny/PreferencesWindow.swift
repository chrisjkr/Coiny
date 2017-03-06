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
    func showDecimalsStateChanged()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    
    var delegate: PreferencesWindowDelegate?

    @IBOutlet weak var intervalSlider: NSSlider!
    @IBOutlet weak var showDecimals: NSButton!
    
    var defaults = UserDefaults.standard

    override var windowNibName: String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        intervalSlider.doubleValue = defaults.double(forKey: "updateInterval")
        showDecimals.state = defaults.bool(forKey: "showDecimals") ? 1 : 0
    }
    
    @IBAction func intervalSliderUsed(_ sender: NSSliderCell) {
        let event = NSApplication.shared().currentEvent
        
        if event?.type == NSEventType.leftMouseUp {
            defaults.set(sender.doubleValue, forKey: "updateInterval")
        }
    }
    
    @IBAction func showDecimalsUsed(_ sender: NSButton) {
        defaults.set(!defaults.bool(forKey: "showDecimals"), forKey: "showDecimals")
        delegate?.showDecimalsStateChanged()
    }
    
    func windowWillClose(_ notification: Notification) {
        delegate?.preferencesDidClose()
    }
}
