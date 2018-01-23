//
//  DetailViewController.swift
//  Coinr
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
    
    // Variables and constants
    
    var inFavorites = false
    var userID = Auth.auth().currentUser?.uid
    let favoritesRef = Database.database().reference(withPath: "favorites")
    var coinHistory: [[Double]] = []
    
    var detailCoin: Coin? {
        didSet {
            configureView()
        }
    }
    
    
    // Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.lineChartView.noDataText = ""
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
    
    func checkDatabase() {
        favoritesRef.child(userID!).observeSingleEvent(of: .value) { (snap: DataSnapshot) in
            if snap.exists() {
                if let dict = snap.value as? [String: NSDictionary] {
                    for item in dict {
                        if (item.value as NSDictionary)["symbol"] as! String == self.detailCoin!.symbol {
                            self.updateButton()
                        }
                    }
                }
            }
        }
    }
    
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
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        markerView.priceLabel.text = "\(entry.y.formattedWithSeparator)"
        let date = Date(timeIntervalSince1970: entry.x)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
        markerView.dateLabel.text = "\(dateFormatter.string(from: date))"
        
        let graphPoint = lineChartView.getMarkerPosition(highlight: highlight)
        markerView.center = CGPoint(x:graphPoint.x, y:markerView.center.y)
        markerView.isHidden = false
        
    }
    
//    func chartValueNothingSelected(_ chartView: ChartViewBase) {
//        let emptyVals = [Highlight]()
//        lineChartView.highlightValues(emptyVals)
//    }
    
    func updateChartWithData() {
        var dataEntries: [ChartDataEntry] = []
        
        for list in coinHistory {
            let dataEntry = ChartDataEntry(x: Double(list[0]), y: list[1] )
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        let data = LineChartData()
        data.addDataSet(chartDataSet)
        self.lineChartView.data = data
        
        
        self.lineChartView.chartDescription = nil
        self.lineChartView.lineData!.setDrawValues(false)
        
        self.lineChartView.xAxis.drawGridLinesEnabled = false
        self.lineChartView.xAxis.drawLabelsEnabled = false
        self.lineChartView.xAxis.drawAxisLineEnabled = false
        self.lineChartView.xAxis.drawLimitLinesBehindDataEnabled = false
        
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        self.lineChartView.leftAxis.drawAxisLineEnabled = false
        self.lineChartView.leftAxis.drawLabelsEnabled = false
        
        self.lineChartView.rightAxis.drawGridLinesEnabled = false
        self.lineChartView.rightAxis.drawAxisLineEnabled = false
        self.lineChartView.rightAxis.drawLabelsEnabled = false
        
        
        chartDataSet.colors = [#colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 1)]
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawFilledEnabled = true
        chartDataSet.highlightColor = UIColor.white
        
        let gradientColors = [#colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 1).cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        //chartDataSet.fill = Fill.fillWithColor(#colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 0.5))
        chartDataSet.fillAlpha = 1

        self.lineChartView.legend.enabled = false
        
        self.lineChartView.highlightPerDragEnabled = true
        self.lineChartView.highlightPerTapEnabled = true
        self.lineChartView.drawMarkers = false
        self.lineChartView.minOffset = 0
        
    }
    
    
    // Actions (buttons tapped)
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if inFavorites {
            // Remove item from list
            detailCoin!.deleteFromFirebase(symbol: (detailCoin?.symbol)!, userID: userID!)
            updateButton()
        }
        else {
            // Add item to list
            detailCoin!.saveToFirebase(userID: userID!)
            updateButton()
        }
    }
    
    @IBAction func segmentedTouched(_ sender: UISegmentedControl) {
        var interval = ""
        var amount = ""
        if segmentDetailPage.selectedSegmentIndex == 0 {
            interval = "histominute"
            amount = "60"
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
        
        CoinController.shared.fetchCoinHistory(interval: interval, amount: amount ,coinSymbol: (detailCoin?.symbol)!) { (coinhistory) in
            if let coinhistory = coinhistory {
                self.updateUI(with: coinhistory)
            }
        }
        
    }
    
    @IBAction func transactionButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "addTransaction", sender: nil)
    }
    
    
}

// Extensions

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


