//
//  OnlineTableViewCell.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 27/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit
protocol OnlineTableViewCellDelegate
{
    func btnImgAttachmentsClicked(trxBO : TransactionBO,cell : OnlineTableViewCell)
}

class OnlineTableViewCell: UITableViewCell {

    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblAmt: UILabel!
    @IBOutlet weak var imgVwOnline: UIImageView!
    @IBOutlet weak var lblEmpName: UILabel!
    @IBOutlet weak var lblEmpId: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblOtp: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblAttachCount: UILabel!
    @IBOutlet weak var btnImgAttachments: UIButton!
    
    @IBOutlet weak var constLblDescriptionHeight: NSLayoutConstraint!
    var callBack : OnlineTableViewCellDelegate!
    var trxBO = TransactionBO()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnImgAttachmentsClicked(_ sender: Any) {
        if self.callBack != nil
        {
            self.callBack.btnImgAttachmentsClicked(trxBO: trxBO, cell: self)
        }

    }
}
