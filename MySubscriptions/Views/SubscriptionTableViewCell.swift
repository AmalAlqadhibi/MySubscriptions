//
//  SubscriptionTableViewCell.swift
//  MySubscriptions
//
//  Created by Amal Alqadhibi on 22/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit

class SubscriptionTableViewCell: UITableViewCell {
    @IBOutlet weak var companyLogo: UIView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var subscriptionPrice: UILabel!
    @IBOutlet weak var firstBill: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
