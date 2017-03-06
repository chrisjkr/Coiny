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
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let coinbaseAPI = CoinbaseAPI()
    var timer = Timer()
    var updateInterval: Double = 60
    
    override func awakeFromNib() {
        statusItem.title = "Fetching..."
        statusItem.menu = statusMenu
        
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
    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        updatePrices()
    }
    
    @IBAction func changeUpdateInterval(_ sender: NSMenuItem) {
        updateInterval = Double(sender.tag * 60)
        NSLog("will now refresh every \(updateInterval) seconds")
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        timer.invalidate()
        NSApplication.shared().terminate(self)
    }
}
