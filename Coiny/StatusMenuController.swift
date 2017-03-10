//
//  StatusMenuController.swift
//  Coiny
//
//  Created by Krzysztof Kraszewski on 05/03/17.
//  Copyright © 2017 Krzysztof Kraszewski. All rights reserved.
//

import Cocoa

struct Currency {
  var symbol: String
  var price: Double
}

class StatusMenuController: NSObject, PreferencesWindowDelegate, NSTableViewDelegate, NSTableViewDataSource {
  @IBOutlet weak var statusMenu: NSMenu!
    
  let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  let coinAPI = CoinAPI()
  var timer = Timer()
  let defaults = UserDefaults.standard
  
  var preferencesWindow: PreferencesWindow!
  
  var prices: [Currency] = []
  @IBOutlet weak var pricesMenuItem: NSMenuItem!
  @IBOutlet weak var priceTable: NSTableView!
  @IBOutlet weak var priceView: NSScrollView!
    
  override func awakeFromNib() {
    statusItem.title = "Fetching..."
    statusItem.menu = statusMenu
        
    preferencesWindow = PreferencesWindow()
    preferencesWindow.delegate = self
    
    pricesMenuItem.view = priceView
        
    // User settings
    var updateInterval: Double = defaults.double(forKey: "updateInterval")
    updateInterval = updateInterval < 60 ? 60 : updateInterval
    defaults.set(defaults.array(forKey: "currencies") ?? ["btc"], forKey: "currencies")

        
    updatePrices()
    timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(self.updatePrices), userInfo: nil, repeats: true)
  }
    
  func updatePrices() {
    let currencies = defaults.array(forKey: "currencies") as! [String]
    for currency in currencies {
      coinAPI.fetchPrice(currency) { amount in
        self.prices.append(Currency(symbol: currency, price: amount))
        self.updateView()
      }
    }
  }
    
  func updateView() {
    priceTable.reloadData()
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
  
  // MARK: - Price Table
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return prices.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    var text: String = ""
    var cellIdentifier: String = ""
    let item = prices[row]
    
    if tableColumn == priceTable.tableColumns[0] {
      text = item.symbol
      cellIdentifier = "SymbolCell"
    } else if tableColumn == priceTable.tableColumns[1] {
      text = convertPrice(item.price)
      cellIdentifier = "PriceCell"
    }
    
    if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    
    return nil
  }
  
}
