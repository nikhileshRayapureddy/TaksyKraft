//
//  MyChequesTableViewCell.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 01/03/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class MyChequesTableViewCell: UITableViewCell {
    @IBOutlet weak var lblAmt: UILabel!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblUploadedDate: UILabel!
    @IBOutlet weak var lblChequeNo: UILabel!
    @IBOutlet weak var lblClearanceDate: UILabel!
    @IBOutlet weak var lblDesc: UILabel!    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var vwBtnBase: UIView!
    @IBOutlet weak var btnReUpload: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblAttachsCount: UILabel!
    @IBOutlet weak var btnImg: UIButton!
    @IBOutlet weak var imgCheque: UIImageView!
    @IBOutlet weak var constVwBtnBaseHeight: NSLayoutConstraint!
    @IBOutlet weak var constLblReasonHeight: NSLayoutConstraint!
    @IBOutlet weak var constLblDescriptionHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func btnReUploadClicked(_ sender: UIButton) {
    }
    
    @IBAction func btnDeleteClicked(_ sender: UIButton) {
    }
    
}
