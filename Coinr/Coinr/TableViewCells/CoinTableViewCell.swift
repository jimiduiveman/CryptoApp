//
//  CoinTableViewCell.swift
//  Coinr
//
//  Created by Jimi Duiveman on 12-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

    
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var coinChange: UILabel!
    @IBOutlet weak var coinPrice: UILabel!
    @IBOutlet weak var coinLogo: UIImageView!
    @IBOutlet weak var coinSymbol: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
