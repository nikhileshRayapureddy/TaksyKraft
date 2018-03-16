//
//  AllTravelTableViewCell.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 21/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit
protocol AllTravelTableViewCellDelegate
{
    func btnRejectClicked(travelId : String,cell : AllTravelTableViewCell)
    func btnApproveClicked(travelId : String,cell : AllTravelTableViewCell)
    func btnBookNowClicked(travelId : String,cell : AllTravelTableViewCell)
}

class AllTravelTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTravelID: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblEmployeeName: UILabel!
    @IBOutlet weak var lblEmpID: UILabel!
    @IBOutlet weak var lblUploadedDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblSrcAndDest: UILabel!
    @IBOutlet weak var btnBookNow: UIButton!
    @IBOutlet weak var btnApprove: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var vwBase: UIView!
    var travel = TravelBO()
    var rejectPopup : RejectPopup!
    var callback : AllTravelTableViewCellDelegate!

    @IBOutlet weak var constLblDescriptionHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func btnRejectClicked(_ sender: UIButton) {
        self.callback.btnRejectClicked(travelId: travel.travelId, cell: self)
    }
    @IBAction func btnBookNowClicked(_ sender: UIButton) {
        self.callback.btnBookNowClicked(travelId: travel.travelId, cell: self)
    }
    @IBAction func btnApproveClicked(_ sender: UIButton) {
        self.callback.btnApproveClicked(travelId: travel.travelId, cell: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
