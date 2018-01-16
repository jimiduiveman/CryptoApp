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


    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var onehour_change: UILabel!
    @IBOutlet weak var twentyfourhour_change: UILabel!
    @IBOutlet weak var twentyfourhour_volume: UILabel!
    @IBOutlet weak var marketcap: UILabel!
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    var detailCoin: Coin? {
        didSet {
            configureView()
        }
    }
    
    var inFavorites = false
    var userID = Auth.auth().currentUser?.uid
    let favoritesRef = Database.database().reference(withPath: "favorites")

    var coinHistory: [[Double]] = []
    
    func configureView() {
        if let detailCoin = detailCoin {

            self.navigationItem.titleView = setTitle(title:detailCoin.name, subtitle:detailCoin.symbol)
            let coinPrice = (detailCoin.price as NSString).doubleValue
            price.text = "$ \((coinPrice).formattedWithSeparator)"
            
            if detailCoin.onehr_change.starts(with: "-") {
                onehour_change!.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else {
                onehour_change!.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
            }
            
            if detailCoin.twentyfourhr_change.starts(with: "-") {
                twentyfourhour_change.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else {
                twentyfourhour_change.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
            }
            
            onehour_change.text = "\(detailCoin.onehr_change) %"
            twentyfourhour_change.text = "\(detailCoin.twentyfourhr_change) %"
            let coinVolume = (detailCoin.twentyfourhr_volume as NSString).doubleValue
            twentyfourhour_volume.text = "$ \((coinVolume).formattedWithSeparator)"
            let coinCap = (detailCoin.marketcap as NSString).doubleValue
            marketcap.text = "$ \((coinCap).formattedWithSeparator)"
            
        }
    }
    
    // Inspiration : http://stackoverflow.com/questions/12914004/uinavigationbar-titleview-with-subtitle
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-5, width: view.frame.width - 60, height: 20))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "AvenirMedium", size: 16)
        titleLabel.text = title
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width: view.frame.width - 60, height: 10))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.darkGray
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
        // If movie already on watch list, button will (display) remove
        if inFavorites {
            favoriteButton.setTitleColor( #colorLiteral(red: 0.2284384445, green: 0.5989627731, blue: 1, alpha: 1), for: UIControlState.normal)
            favoriteButton.setTitle("ADD TO FAVORITES", for: UIControlState.normal)
            inFavorites = false
        }
            // If movie not on watch list, button will (display) add
        else {
            favoriteButton.setTitleColor(UIColor.orange, for: UIControlState.normal)
            favoriteButton.setTitle("REMOVE FROM FAVORITES", for: UIControlState.normal)
            inFavorites = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinController.shared.fetchCoinHistory(coinSymbol: (detailCoin?.symbol)!) { (coinhistory) in
            if let coinhistory = coinhistory {
                self.updateUI(with: coinhistory)
            }
        }
        lineChartView.delegate = self

        checkDatabase()

    }
    
    func updateUI(with coinhistory: [[Double]]) {
        DispatchQueue.main.async {
            self.coinHistory = coinhistory
            self.updateChartWithData()
        }
    }
    
    
    
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
        
        chartDataSet.colors = [NSUIColor.darkGray] //#colorLiteral(red: 0.2535856366, green: 0.48979491, blue: 0.8384879231, alpha: 1)
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawFilledEnabled = true
        
        let gradientColors = [UIColor.gray.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)

        self.lineChartView.legend.enabled = false
        
        self.lineChartView.highlightPerDragEnabled = true
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
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
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Double {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}


