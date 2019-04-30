//
//  MyExpensesTableViewCell.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
protocol MyExpensesTableViewCellDelegate
{
    func btnReuploadClicked(expense : ReceiptBO,cell : MyExpensesTableViewCell)
    func btnDeleteClicked(expenseId : String,cell : MyExpensesTableViewCell)
    func myExpImgVwClicked(expense : ReceiptBO,cell : MyExpensesTableViewCell)
    
}

class MyExpensesTableViewCell: UITableViewCell {

    @IBOutlet weak var lblExpenseID: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblUploadedDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgVwExpense: UIImageView!
    @IBOutlet weak var btnReupload: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var vwBase: UIView!
    @IBOutlet weak var vwBtnBase: UIView!
    @IBOutlet weak var constVwBtnBaseHeight: NSLayoutConstraint!
    var callBack : MyExpensesTableViewCellDelegate!
    var expense = ReceiptBO()
    @IBOutlet weak var lblReason: UILabel!
    @IBOutlet weak var constLblReasonHeight: NSLayoutConstraint!
    @IBOutlet weak var constLblDescriptionHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func btnReuploadClicked(_ sender: UIButton) {
        self.callBack.btnReuploadClicked(expense: expense, cell: self)
    }
    @IBAction func btnDeleteClicked(_ sender: UIButton) {
        self.callBack.btnDeleteClicked(expenseId: expense.expenseId, cell: self)
    }
    @IBAction func btnImgVwClicked(_ sender: UIButton) {
        if self.callBack != nil
        {
            self.callBack.myExpImgVwClicked(expense: expense, cell: self)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
