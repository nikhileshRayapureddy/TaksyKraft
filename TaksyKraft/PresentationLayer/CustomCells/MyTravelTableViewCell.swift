//
//  MyTravelTableViewCell.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 21/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit
protocol MyTravelTableViewCellDelegate
{
    func btnReuploadClicked(travel : TravelBO,cell : MyTravelTableViewCell)
    func btnDeleteClicked(travelId : String,cell : MyTravelTableViewCell)
    
}

class MyTravelTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTravelID: UILabel!
    @IBOutlet weak var lblFare: UILabel!
    @IBOutlet weak var lblUploadedDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblSrcAndDest: UILabel!
    
    @IBOutlet weak var btnReUpload: UIButton!
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var vwBase: UIView!
    
    @IBOutlet weak var lblReason: UILabel!
    
    @IBOutlet weak var constLblReasonHeight: NSLayoutConstraint!
    @IBOutlet weak var constLblDescriptionHeight: NSLayoutConstraint!

    @IBOutlet weak var constVwBtnBaseHeight: NSLayoutConstraint!
    @IBOutlet weak var vwBtnBase: UIView!
    var callBack : MyTravelTableViewCellDelegate!
    var travel = TravelBO()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnDeleteClicked(_ sender: UIButton) {
        self.callBack.btnDeleteClicked(travelId: travel.travelId, cell: self)
    }
    @IBAction func btnReUploadClicked(_ sender: UIButton) {
        self.callBack.btnReuploadClicked(travel: travel, cell: self)
    }
}
