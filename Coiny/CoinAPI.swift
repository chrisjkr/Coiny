//
//  CoinbaseAPI.swift
//  Coiny
//
//  Created by Krzysztof Kraszewski on 05/03/17.
//  Copyright © 2017 Krzysztof Kraszewski. All rights reserved.
//

import Foundation

class CoinAPI {
    let COINBASE_URL = "https://coinmarketcap-nexuist.rhcloud.com/api"
    
    func fetchBitcoinPrice(success: @escaping (Double) -> Void) {
        let session = URLSession.shared
        
        let url = URL(string: "\(COINBASE_URL)/btc")
        let task = session.dataTask(with: url!) { data, response, err in
            if let error = err {
                NSLog("API error: \(error)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let parsed = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                        let data = parsed["price"] as! [String: Any]
                        let amount = data["usd"] as! Double
                        
                        success(amount)
                        
                    } catch let error as NSError {
                        NSLog(error.localizedDescription)
                    }
                    
                default:
                    NSLog("API returned response \(httpResponse.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                }
            }
        }
        task.resume()
    }
}
