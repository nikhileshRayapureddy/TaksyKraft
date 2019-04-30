//
//  EmployeeCustomCell.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 22/11/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class EmployeeCustomCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
