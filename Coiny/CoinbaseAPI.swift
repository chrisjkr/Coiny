//
//  CoinbaseAPI.swift
//  Coiny
//
//  Created by Krzysztof Kraszewski on 05/03/17.
//  Copyright © 2017 Krzysztof Kraszewski. All rights reserved.
//

import Foundation

class CoinbaseAPI {
    let COINBASE_URL = "https://api.coinbase.com/v2"
    
    func fetchBitcoinPrice(success: @escaping (String) -> Void) {
        let session = URLSession.shared
        
        let url = URL(string: "\(COINBASE_URL)/prices/BTC-USD/buy")
        let request = NSMutableURLRequest(url: url!)
        request.addValue("2017-03-05", forHTTPHeaderField: "CB-VERSION")
        let task = session.dataTask(with: request as URLRequest) { data, response, err in
            if let error = err {
                NSLog("Coinbase API error: \(error)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let parsed = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                        let data = parsed["data"] as! [String: Any]
                        let amount = data["amount"] as! String
                        success(amount)
                        
                    } catch let error as NSError {
                        NSLog(error.localizedDescription)
                    }
                    
                default:
                    NSLog("Coinbase API returned response \(httpResponse.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                }
            }
        }
        task.resume()
    }
}
