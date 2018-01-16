//
//  FavoritesTableViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 15-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class FavoritesTableViewController: UITableViewController {

    
    var coins = [Coin]()
    
    var userID = Auth.auth().currentUser?.uid
    let favoritesRef = Database.database().reference(withPath: "favorites")
    
    
    func loadFromFirebase() {
        favoritesRef.child(userID!).observeSingleEvent(of: .value) { (snap: DataSnapshot) in
            if snap.exists() {
                if let dict = snap.value as? [String: NSDictionary] {
                    for item in dict {
                        let id = (item.value as NSDictionary)["id"] as! String
                        let name = (item.value as NSDictionary)["name"] as! String
                        let symbol = (item.value as NSDictionary)["symbol"] as! String
                        let price = (item.value as NSDictionary)["price"] as! String
                        let onehr_change = (item.value as NSDictionary)["onehr_change"] as! String
                        let twentyfourhr_change = (item.value as NSDictionary)["twentyfourhr_change"] as! String
                        let twentyfourhr_volume = (item.value as NSDictionary)["twentyfourhr_volume"] as! String
                        let marketcap = (item.value as NSDictionary)["marketcap"] as! String
                        let logo = (item.value as NSDictionary)["logo"] as! String
                        
                        let coin = Coin(id: id, name: name, symbol: symbol, price: price, onehr_change: onehr_change, twentyfourhr_change: twentyfourhr_change, twentyfourhr_volume: twentyfourhr_volume, marketcap: marketcap, logo: logo) 
                        self.coins.append(coin)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        loadFromFirebase()
        myGroup.leave()
        myGroup.notify(queue: DispatchQueue.main) {
            self.tableView!.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableViewCell") as! FavoriteTableViewCell
        let coin = coins[indexPath.row]
        cell.coinName!.text = "\(coin.name)"
        cell.coinSymbol!.text = "\(coin.symbol)"
        cell.coinChange!.text = "\(coin.twentyfourhr_change) %"
        if coin.twentyfourhr_change.starts(with: "-") {
            cell.coinChange!.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            cell.coinChange!.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
        }
        
        let coinPrice = (coin.price as NSString).doubleValue
        cell.coinPrice.text = "$ \((coinPrice).formattedWithSeparator)"
        
        CoinController.shared.fetchImage(url: URL(string: coin.logo)! ) { (image) in
            guard let image = image else { return }
            DispatchQueue.main.async {
                cell.coinLogo.image = image
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }



    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let detailViewController = segue.destination as! DetailViewController
            if CoinController.shared.favoriteCoins.count > 0 {
                let indexPath = self.tableView?.indexPath(for: sender as! UITableViewCell)
                detailViewController.detailCoin = CoinController.shared.favoriteCoins[(indexPath?.row)!]
            }
        }
    }
 

}
