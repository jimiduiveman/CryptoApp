//
//  CoinController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 11-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import Foundation
import UIKit

class CoinController {

    static let shared = CoinController()

    func fetchCoins(completion: @escaping ([Coin]?) -> Void) {
        var coins = [Coin]()
        
        let url = "https://api.coinmarketcap.com/v1/ticker/?limit=150"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = ("GET")
        
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) { (data, repsonse, error) in
            if error != nil {
                print("Error ")
            }
            else {
                do {
                    let fetchedData = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSArray
                    for eachFetchedCoin in fetchedData {
                        let eachCoin = eachFetchedCoin as! NSDictionary
                        let id = eachCoin["id"] as! String
                        let name = eachCoin["name"] as! String
                        let symbol = eachCoin["symbol"] as! String
                        let price = eachCoin["price_usd"] as! String
                        let marketcap = eachCoin["market_cap_usd"] as! String
                        var onehr_change = "0.0"
                        if (eachCoin["percent_change_1h"] as? String) != nil {
                            onehr_change = eachCoin["percent_change_1h"] as! String
                        }
                        var twentyfourhr_change = "0.0"
                        if (eachCoin["percent_change_24h"] as? String) != nil {
                            twentyfourhr_change = eachCoin["percent_change_24h"] as! String
                        }
                        let twentyfourhr_volume = eachCoin["24h_volume_usd"] as! String
                        let logo = "https://files.coinmarketcap.com/static/img/coins/32x32/\(id).png"
                        
                        coins.append(Coin(id: id, name: name, symbol: symbol, price: price, onehr_change: onehr_change, twentyfourhr_change: twentyfourhr_change, twentyfourhr_volume: twentyfourhr_volume, marketcap: marketcap, logo: logo))
                    }
                    completion(coins)
                }
                catch {
                    print("Error")
                }
            }
        }
        task.resume()
    }
    
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchCoinHistory(coinSymbol: String, completion: @escaping ([[Double]]?) -> Void) {
        var history: [[Double]] = []
        
        let url = "http://coincap.io/history/7day/" + coinSymbol
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = ("GET")
        
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Error ")
            }
            else {
                do {
                    let fetchedData = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                    history = fetchedData["price"]! as! [[Double]]
                    completion(history)
                }
                catch {
                    print("Error")
                }
            }
        }
        task.resume()
    }
    
    var favoriteCoins = [Coin]()
 
}
