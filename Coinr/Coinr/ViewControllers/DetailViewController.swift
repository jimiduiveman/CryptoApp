//
//  DetailViewController.swift
//  Coinr
//
//  Description: Shows details about a coin, including price history and some other statistics
//
//  Created by Jimi Duiveman on 12-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Charts
import Firebase

class DetailViewController: UIViewController, ChartViewDelegate {

    // Outlets
    @IBOutlet weak var sevenday_change: UILabel!
    @IBOutlet weak var twentyfourhour_change: UILabel!
    @IBOutlet weak var marketcap: UILabel!
    @IBOutlet weak var available_supply: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var transactionButton: UIButton!
    @IBOutlet weak var markerView: MarkerView!
    @IBOutlet weak var segmentDetailPage: UISegmentedControl!
    
    // Variables
    var inFavorites = false
    var userID = Auth.auth().currentUser?.uid
    var coinHistory: [[Double]] = []
    var detailCoin: Coin? {
        didSet {
            configureView()
        }
    }
    
    // Constants
    let favoritesRef = Database.database().reference(withPath: "favorites")
    
    
    // Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.lineChartView.noDataText = ""
    }
    
    // Actions
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if inFavorites {
            // Remove item from list
            detailCoin!.deleteFromFirebase(symbol: (detailCoin?.symbol)!, userID: userID!)
            updateButton()
        }
        else {
            // Add item to list
            detailCoin!.saveToFirebase(symbol: (detailCoin?.symbol)!, userID: userID!)
            updateButton()
        }
    }
    
    // Determine which price history interval has to be shown
    @IBAction func segmentedTouched(_ sender: UISegmentedControl) {
        var interval = ""
        var amount = ""
        if segmentDetailPage.selectedSegmentIndex == 0 {
            interval = "histominute"
            amount = "120"
        }
        if segmentDetailPage.selectedSegmentIndex == 1 {
            interval = "histominute"
            amount = "1000"
        }
        if segmentDetailPage.selectedSegmentIndex == 2 {
            interval = "histohour"
            amount = "60"
        }
        if segmentDetailPage.selectedSegmentIndex == 3 {
            interval = "histohour"
            amount = "260"
        }
        if segmentDetailPage.selectedSegmentIndex == 4 {
            interval = "histoday"
            amount = "65"
        }
        if segmentDetailPage.selectedSegmentIndex == 5 {
            interval = "histoday"
            amount = "125"
        }
        
        // Get price history for selected interval
        CoinController.shared.fetchCoinHistory(interval: interval, amount: amount ,coinSymbol: (detailCoin?.symbol)!) { (coinhistory) in
            if let coinhistory = coinhistory {
                self.updateUI(with: coinhistory)
            }
        }
        
    }
    
    @IBAction func transactionButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "addTransaction", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkDatabase()
        
        CoinController.shared.fetchCoinHistory(interval:"histominute", amount:"60" ,coinSymbol: (detailCoin?.symbol)!) { (coinhistory) in
            if let coinhistory = coinhistory {
                self.updateUI(with: coinhistory)
            }
        }
        
        lineChartView.delegate = self
        lineChartView.backgroundColor = UIColor.black

    }
    
    // Functions
    func updateUI(with coinhistory: [[Double]]) {
        DispatchQueue.main.async {
            self.coinHistory = coinhistory
            if self.coinHistory.count > 0 {
                self.markerView.priceLabel.text = "\((self.coinHistory.last![1]).formattedWithSeparator)"
                let currentTime = Date(timeIntervalSince1970: self.coinHistory.last![0])
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
                self.markerView.dateLabel.text = "\(dateFormatter.string(from: currentTime))"
                self.updateChartWithData()
            }
        }
    }
    
    // Check if coin in favorites to be able to adapt favorite logo
    func checkDatabase() {
        favoritesRef.child(userID!).observeSingleEvent(of: .value) { (snap: DataSnapshot) in
            if snap.exists() {
                if let list = snap.value as? NSDictionary {
                    for item in list {
                        if item.value as! String == self.detailCoin!.symbol {
                            self.updateButton()
                        }
                    }
                }
            }
        }
    }
    
    // Adapt logo based on favorites
    func updateButton() {
        
        // If coin already in favorites, button will (display) remove
        if inFavorites {
            navigationItem.rightBarButtonItem?.image = UIImage(named: "icons8-star-50")
            inFavorites = false
        }
            // If movie not on watch list, button will (display) add
        else {
            navigationItem.rightBarButtonItem?.image = UIImage(named: "icons8-star-filled-filled-50")
            inFavorites = true
        }
    }
    
    // Configure the view on the detail page
    func configureView() {
        if let detailCoin = detailCoin {
            
            self.navigationItem.titleView = setTitle(title:detailCoin.name, subtitle:detailCoin.symbol)
            
            if detailCoin.sevenday_change.starts(with: "-") {
                sevenday_change!.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else {
                sevenday_change!.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
            }
            
            if detailCoin.twentyfourhr_change.starts(with: "-") {
                twentyfourhour_change.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else {
                twentyfourhour_change.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
            }
            
            sevenday_change.text = "\(detailCoin.sevenday_change)%"
            twentyfourhour_change.text = "\(detailCoin.twentyfourhr_change)%"
            let coinSupply = (detailCoin.available_supply as NSString).doubleValue
            available_supply.text = "\((coinSupply))"
            let coinCap = (detailCoin.marketcap as NSString).doubleValue
            marketcap.text = "\((coinCap).formattedWithSeparator)"
            
            transactionButton.layer.borderWidth = 1
            transactionButton.layer.borderColor = #colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 1)
            transactionButton.layer.cornerRadius = 4
            
        }
        
        segmentDetailPage.backgroundColor = UIColor.black
        segmentDetailPage.tintColor = .clear
        segmentDetailPage.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Avenir", size: 16) as Any,
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        segmentDetailPage.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Avenir-Black", size: 16) as Any,
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
    }
    
    // Inspiration : http://stackoverflow.com/questions/12914004/uinavigationbar-titleview-with-subtitle
    // Set a title with subtitle in the navigation bar
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-2, width: view.frame.width - 60, height: 20))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 16)
        titleLabel.text = title
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:21, width: view.frame.width - 60, height: 10))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = UIFont(name: "Avenir", size: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.adjustsFontSizeToFitWidth = false
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.textAlignment = .center
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width: view.frame.width, height:30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        return titleView
    }
    
    // Get data point of finger touching chart
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        // Price for touched data point
        markerView.priceLabel.text = "\(entry.y.formattedWithSeparator)"
        let date = Date(timeIntervalSince1970: entry.x)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
        
        // Date for touched data point
        markerView.dateLabel.text = "\(dateFormatter.string(from: date))"
        
        let graphPoint = lineChartView.getMarkerPosition(highlight: highlight)
        markerView.center = CGPoint(x:graphPoint.x, y:markerView.center.y)
        markerView.isHidden = false
        
    }
    
    // Get data for the chart and show it
    func updateChartWithData() {
        var dataEntries: [ChartDataEntry] = []
        
        for list in coinHistory {
            let dataEntry = ChartDataEntry(x: Double(list[0]), y: list[1] )
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        let data = LineChartData()
        data.addDataSet(chartDataSet)
        lineChartView.data = data
        
        
        lineChartView.chartDescription = nil
        lineChartView.lineData!.setDrawValues(false)
        
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawLimitLinesBehindDataEnabled = false
        
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        
        
        chartDataSet.colors = [#colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 1)]
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawFilledEnabled = true
        chartDataSet.highlightColor = UIColor.white
        
        // Colors of the gradient, blue and clear
        let gradientColors = [#colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 1).cgColor, UIColor.clear.cgColor] as CFArray
        
        // Direction of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0]
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        chartDataSet.fillAlpha = 1

        lineChartView.legend.enabled = false
        lineChartView.highlightPerDragEnabled = true
        lineChartView.highlightPerTapEnabled = true
        lineChartView.drawMarkers = false
        lineChartView.minOffset = 0
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTransaction" {
            let controller = segue.destination as! MakeTradeViewController
            let coin = detailCoin
            controller.tradeCoin = coin
        }
    }
    
    
}

// Extensions

// Get format of dollar currency
extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        return formatter
    }()
}

extension Double {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}


