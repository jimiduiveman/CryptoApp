//
//  MarketTableViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 11-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class MarketTableViewController: UITableViewController {
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var coins = [Coin]()
    var filteredCoins = [Coin]()
    
    var userID = Auth.auth().currentUser?.uid
    
    let usersRef = Database.database().reference(withPath: "online")
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
        CoinController.shared.fetchCoins() { (coins) in
            if let coins = coins {
                self.updateUI(with: coins)
            }
        }
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
    }
    
    func setupSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.view.tintColor = UIColor.black
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.placeholder = "Search coins.."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCoins = coins.filter({( coin : Coin) -> Bool in
            return coin.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    
    func updateUI(with coins: [Coin]) {
        DispatchQueue.main.async {
            self.coins = coins
            self.tableView.reloadData()
        }
    }


    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return filteredCoins.count
        }
        
        return coins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinTableViewCell") as! CoinTableViewCell
        var coin: Coin
        
        if isFiltering() {
            coin = filteredCoins[indexPath.row]
        }
        else {
            coin = coins[indexPath.row]
        }
        
        cell.coinName!.text = "\(coin.name)"
        cell.coinSymbol!.text = "\(coin.symbol)"
        cell.coinChange!.text = "\(coin.twentyfourhr_change)%"
        if coin.twentyfourhr_change.starts(with: "-") {
            cell.coinChange!.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            cell.coinChange!.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
        }
        
        let coinPrice = (coin.price as NSString).doubleValue
        cell.coinPrice.text = "\((coinPrice).formattedWithSeparator)"
        
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
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toFavorites", sender: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                let coin: Coin
                if isFiltering() {
                    coin = filteredCoins[indexPath.row]
                } else {
                    coin = coins[indexPath.row]
                }
                controller.detailCoin = coin
            }
        }
    }
    

}

extension MarketTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
