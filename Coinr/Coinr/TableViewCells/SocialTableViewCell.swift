//
//  SocialTableViewCell.swift
//  Coinr
//
//  Created by Jimi Duiveman on 16-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit

class SocialTableViewCell: UITableViewCell {

    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
