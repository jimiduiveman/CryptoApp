//
//  CoinsViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 21-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class CoinsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    
    var coins = [Coin]()
    var filteredCoins = [Coin]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    
    var userID = Auth.auth().currentUser?.uid
    
    let usersRef = Database.database().reference(withPath: "online")
    var user: User!

    @IBOutlet weak var tableSearchResults: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSearchResults.delegate = self
        tableSearchResults.dataSource = self
        
        configureSearchController()

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
    
    func updateUI(with coins: [Coin]) {
        DispatchQueue.main.async {
            self.coins = coins
            self.tableSearchResults.reloadData()
        }
    }
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.black
        
        // Place the search bar view to the tableview headerview.
        tableSearchResults.tableHeaderView = searchController.searchBar
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCoins.count
        }
        else {
            return coins.count
        }
    }
    
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        filteredCoins = coins.filter({ (coin) -> Bool in
            let coinText: NSString = coin.name as NSString
            
            return (coinText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        tableSearchResults.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toFavorites", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let indexPath = tableSearchResults.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                let coin: Coin
                if isFiltering() {
                    coin = filteredCoins[indexPath.row]
                } else {
                    coin = coins[indexPath.row]
                }
                controller.detailCoin = coin
                searchController.isActive = false
            }
        }
    }
    

    

}
