//
//  StatusMenuController.swift
//  Coiny
//
//  Created by Krzysztof Kraszewski on 05/03/17.
//  Copyright © 2017 Krzysztof Kraszewski. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var bitcoinPrice: NSMenuItem!
    
    @IBOutlet weak var everyMinute: NSMenuItem!
    @IBOutlet weak var every5: NSMenuItem!
    @IBOutlet weak var every10: NSMenuItem!
    @IBOutlet weak var every30: NSMenuItem!
    @IBOutlet weak var everyHour: NSMenuItem!
    
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let coinbaseAPI = CoinbaseAPI()
    var timer = Timer()
    let defaults = UserDefaults.standard
    
    override func awakeFromNib() {
        statusItem.title = "Fetching..."
        statusItem.menu = statusMenu
        
        // User settings
        var updateInterval: Double = defaults.double(forKey: "updateInterval")
        updateInterval = updateInterval < 60 ? 60 : updateInterval
        toggleRefreshIntervalStates(updateInterval)
        
        var showDecimalsOver1000 = defaults.bool(forKey: "showDecimalsOver1000")
        
        updatePrices()
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(self.updatePrices), userInfo: nil, repeats: true)
    }
    
    func updatePrices() {
        coinbaseAPI.fetchBitcoinPrice() { amount in
            self.bitcoinPrice.title = "BTC: $\(self.convertPrice(amount))"
            self.statusItem.title = "$\(self.convertPrice(amount))"
        }
    }
    
    func convertPrice(_ amount: Double) -> String {
        if amount > 1000 {
            return String(Int(round(amount)))
        } else {
            return String(amount)
        }
    }
    
    func toggleRefreshIntervalStates (_ interval: Double) {
        let tag = Int(interval / 60)
        everyMinute.state = everyMinute.tag == tag ? 1 : 0
        every5.state = every5.tag == tag ? 1 : 0
        every10.state = every10.tag == tag ? 1 : 0
        every30.state = every30.tag == tag ? 1 : 0
        everyHour.state = everyHour.tag == tag ? 1 : 0
    }
    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        updatePrices()
    }
    
    @IBAction func changeUpdateInterval(_ sender: NSMenuItem) {
        let newInterval = Double(sender.tag * 60)
        defaults.set(newInterval, forKey: "updateInterval")
        toggleRefreshIntervalStates(newInterval)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        timer.invalidate()
        NSApplication.shared().terminate(self)
    }
}
