//
//  MyExpensesTableViewCell.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class MyExpensesTableViewCell: UITableViewCell {

    @IBOutlet weak var imgVwItem: UIImageView!
    @IBOutlet weak var lblTktNo: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblStatusText: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblTotalAmt: UILabel!
    @IBOutlet weak var lblWalletAmt: UILabel!
    @IBOutlet weak var lblNetAmt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
