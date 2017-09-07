//
//  MyExpensesTableViewCell.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class MyExpensesTableViewCell: UITableViewCell {

    @IBOutlet weak var constLblNameHeight: NSLayoutConstraint!
    @IBOutlet weak var imgVwItem: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTktNo: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnApprove: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblStatusText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
