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
  @IBOutlet weak var currencyList: NSTextField!
  @IBOutlet weak var addCurrencyText: NSTextField!
  @IBOutlet weak var currencyTable: NSTableView!
  @IBOutlet weak var removeCurrencyButton: NSButton!
  
  var defaults = UserDefaults.standard

  override var windowNibName: String! {
    return "PreferencesWindow"
  }
    
  override func windowDidLoad() {
    super.windowDidLoad()
        
    self.window?.center()
    self.window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
    window?.level = Int(CGWindowLevelForKey(.floatingWindow))
    
    currencyTable.delegate = self
    currencyTable.dataSource = self

    updateView()
  }
  
  func updateView() {
    intervalSlider.doubleValue = defaults.double(forKey: "updateInterval")
    showDecimals.state = defaults.bool(forKey: "showDecimals") ? 1 : 0
    
    currencyTable.reloadData()
  }
  
  func displayWarning(title: String, description: String) {
    let popup = NSAlert()
    popup.messageText = title
    popup.informativeText = description
    popup.alertStyle = NSAlertStyle.warning
    popup.addButton(withTitle: "OK")
    popup.runModal()
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
  
  @IBAction func AddCurrency(_ sender: NSButton) {
    if let currency = addCurrencyText?.stringValue {
      addCurrencyText.stringValue = ""
      var currencies = defaults.array(forKey: "currencies") as! [String]
      if !currencies.contains(currency) {
        currencies.append(currency)
        defaults.set(currencies, forKey: "currencies")
      } else {
        displayWarning(title: "Duplicate currency", description: "Currency you are trying to add is already saved.")
        return
      }
      updateView()
    }
  }
  
  @IBAction func removeCurrency(_ sender: NSButton) {
    
    var currencies = defaults.array(forKey: "currencies")!
    if currencies.count == 1 {
      displayWarning(title: "Cannot delete the only currency", description: "You need to have at least 1 currency present.")
    } else {
      currencies.remove(at: currencyTable.selectedRow)
      defaults.set(currencies, forKey: "currencies")
      updateView()
    }
  }
  
  func windowWillClose(_ notification: Notification) {
    delegate?.preferencesDidClose()
  }
}

extension PreferencesWindow: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return defaults.array(forKey: "currencies")?.count ?? 0
  }
}

extension PreferencesWindow: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    guard let item = defaults.array(forKey: "currencies")?[row] as? String else {
      return nil
    }
    
    if let cell = tableView.make(withIdentifier: "CurrencyCellID", owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = item
      return cell
    }
    
    return nil
  }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    removeCurrencyButton.isEnabled = currencyTable.selectedRowIndexes.count > 0
  }
}
