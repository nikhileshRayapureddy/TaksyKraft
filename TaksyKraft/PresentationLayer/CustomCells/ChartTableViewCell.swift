//
//  ChartTableViewCell.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 06/06/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit

class ChartTableViewCell: UITableViewCell {

    @IBOutlet weak var imgStatusColor: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var btnViewBills: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
