//
//  StatusMenuController.swift
//  Coiny
//
//  Created by Krzysztof Kraszewski on 05/03/17.
//  Copyright © 2017 Krzysztof Kraszewski. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var bitcoinPrice: NSMenuItem!
    
    @IBOutlet weak var showDecimals: NSMenuItem!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let coinAPI = CoinAPI()
    var timer = Timer()
    let defaults = UserDefaults.standard
    
    var btcPrice: Double!
    
    var preferencesWindow: PreferencesWindow!
    
    override func awakeFromNib() {
        statusItem.title = "Fetching..."
        statusItem.menu = statusMenu
        
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        // User settings
        var updateInterval: Double = defaults.double(forKey: "updateInterval")
        updateInterval = updateInterval < 60 ? 60 : updateInterval
        
        showDecimals.state = defaults.bool(forKey: "showDecimalsOver1000") ? 1 : 0
        
        updatePrices()
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(self.updatePrices), userInfo: nil, repeats: true)
    }
    
    func updatePrices() {
        coinAPI.fetchPrice("btc") { amount in
            self.btcPrice = amount
            self.updateView()
        }
    }
    
    func updateView() {
        bitcoinPrice.title = "BTC: $\(convertPrice(btcPrice))"
        statusItem.title = "$\(convertPrice(btcPrice))"
    }
    
    func convertPrice(_ amount: Double) -> String {
        if amount > 1000 && !defaults.bool(forKey: "showDecimals") {
            return String(Int(round(amount)))
        } else {
            return String(amount)
        }
    }
    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        updatePrices()
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func toggleShowDecimals(_ sender: NSMenuItem) {
        defaults.set(!defaults.bool(forKey: "showDecimals"), forKey: "showDecimals")
        sender.state = sender.state == 1 ? 0 : 1
        updateView()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        timer.invalidate()
        NSApplication.shared().terminate(self)
    }
    
    func preferencesDidClose() {
        NSLog("App knows preferences were just closed.")
    }
    
    func showDecimalsStateChanged() {
        updateView()
    }
}
