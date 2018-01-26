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
    var favorites = [Coin]()
    
    var shouldShowSearchResults = false
    
    let favoritesRef = Database.database().reference(withPath: "favorites")
    
    var userID = Auth.auth().currentUser?.uid
    let usersRef = Database.database().reference(withPath: "online")
    var user: User!

    @IBOutlet weak var tableSearchResults: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var searchController: UISearchController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        configureSearchController()
        checkDatabase()
        
        tableSearchResults.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableSearchResults.delegate = self
        tableSearchResults.dataSource = self
        
        configureSearchController()
        
        checkDatabase()

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
    
    func checkDatabase() {
        var newFavorites: [Coin] = []
        favoritesRef.child(userID!).observeSingleEvent(of: .value) { (snap: DataSnapshot) in
            if snap.exists() {
                if let list = snap.value as? NSDictionary {
                    for item in list {
                        for coin in self.coins {
                            if coin.symbol == item.value as! String {
                                newFavorites.append(coin)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.favorites = newFavorites
                        self.tableSearchResults.reloadData()
                    }
                }
            }
        }
        self.tableSearchResults.reloadData()
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
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = .white
        textFieldInsideSearchBar?.backgroundColor = .black
        
        // Place the search bar view to the tableview headerview.
        tableSearchResults.tableHeaderView = searchController.searchBar
    }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        checkDatabase()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var returnValue = 0
        
        switch(segmentedControl.selectedSegmentIndex) {
        case 0:
            if isFiltering() {
                returnValue = filteredCoins.count
            }
            else {
                returnValue = coins.count
            }
            break
        case 1:
            if isFiltering() {
                returnValue = filteredCoins.count
            }
            else {
                returnValue = favorites.count
            }

            break
            
        default:
            break
            
        }
        
        return returnValue
    }
    
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        switch(segmentedControl.selectedSegmentIndex) {
        case 0:
            let searchString = searchController.searchBar.text
            filteredCoins = coins.filter({ (coin) -> Bool in
                let coinText: NSString = coin.name as NSString
                
                return (coinText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
            
            tableSearchResults.reloadData()
            break
            
        case 1:
            let searchString = searchController.searchBar.text
            filteredCoins = favorites.filter({ (coin) -> Bool in
                let coinText: NSString = coin.name as NSString
                
                return (coinText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
            
            tableSearchResults.reloadData()
            break
 
        default:
            break
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinTableViewCell") as! CoinTableViewCell
        var coin: Coin
        
        switch(segmentedControl.selectedSegmentIndex) {
        case 0:
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
            if coin.price.starts(with: "0") {
                cell.coinPrice.text = "$\(coin.price)"
            }
            else {
                let coinPrice = (coin.price as NSString).doubleValue
                cell.coinPrice.text = "\((coinPrice).formattedWithSeparator)"
            }
            
            CoinController.shared.fetchImage(url: URL(string: coin.logo)! ) { (image) in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    cell.coinLogo.image = image
                }
            }
            
            break
        case 1:
            if isFiltering() {
                coin = filteredCoins[indexPath.row]
            }
            else {
                coin = favorites[indexPath.row]
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
            
            break

        default:
            break
            
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let indexPath = tableSearchResults.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                let coin: Coin
                
                switch(segmentedControl.selectedSegmentIndex) {
                case 0:
                    if isFiltering() {
                        coin = filteredCoins[indexPath.row]
                    }
                    else {
                        coin = coins[indexPath.row]
                    }
                    controller.detailCoin = coin
                    break
                case 1:
                    if isFiltering() {
                        coin = filteredCoins[indexPath.row]
                    }
                    else {
                        coin = favorites[indexPath.row]
                    }
                    controller.detailCoin = coin
                    break
                    
                default:
                    break
                    
                }
            }
        }
        searchController.isActive = false
    }
    

    

}
