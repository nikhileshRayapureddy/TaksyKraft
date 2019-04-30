//
//  AllExpensesTableViewCell.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 11/09/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
protocol AllExpensesTableViewCellDelegate
{
    func btnRejectClicked(expenseId : String,cell : AllExpensesTableViewCell)
    func btnApproveClicked(expenseId : String,cell : AllExpensesTableViewCell)
    func btnVerifyClicked(expenseId : String,cell : AllExpensesTableViewCell)
    func btnPayNowClicked(expenseId : String,cell : AllExpensesTableViewCell)
    func imgVwClicked(expense : ReceiptBO,cell : AllExpensesTableViewCell)
}
class AllExpensesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblExpenseID: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblEmployeeName: UILabel!
    @IBOutlet weak var lblEmpID: UILabel!
    @IBOutlet weak var lblUploadedDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgVwExpense: UIImageView!
    @IBOutlet weak var btnPayNow: UIButton!
    @IBOutlet weak var btnApprove: UIButton!
    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var vwBase: UIView!
    @IBOutlet weak var constLblDescriptionHeight: NSLayoutConstraint!

    
    var expense = ReceiptBO()
    var rejectPopup : RejectPopup!
    var callback : AllExpensesTableViewCellDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btnRejectClicked(_ sender: UIButton) {
        if self.callback != nil
        {
            self.callback.btnRejectClicked(expenseId: expense.expenseId, cell: self)
        }
    }
    @IBAction func btnPayNowClicked(_ sender: UIButton) {
        if self.callback != nil
        {
            self.callback.btnPayNowClicked(expenseId: expense.expenseId, cell: self)
        }
    }
    @IBAction func btnApproveClicked(_ sender: UIButton) {
        if self.callback != nil
        {
            self.callback.btnApproveClicked(expenseId: expense.expenseId, cell: self)
        }
    }
    @IBAction func btnVerifyClicked(_ sender: UIButton) {
        if self.callback != nil
        {
            self.callback.btnVerifyClicked(expenseId: expense.expenseId, cell: self)
        }
    }
    @IBAction func btnImgVwClicked(_ sender: UIButton) {
        if self.callback != nil
        {
            self.callback.imgVwClicked(expense: expense, cell: self)
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
