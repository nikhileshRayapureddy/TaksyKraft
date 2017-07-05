//
//  CreateExpenseViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class CreateExpenseViewController: BaseViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var txtFldAmount: FloatLabelTextField!
    @IBOutlet weak var txtVwDesc: FloatLabelTextView!
    @IBOutlet weak var lblImageName: UILabel!
    @IBOutlet weak var btnUploadImage: UIButton!
    @IBOutlet weak var btnNoReceipt: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var vwUploadBg: UIView!
    @IBOutlet weak var constVwUploagImageBgHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtVwDesc.layer.cornerRadius = 5
        txtVwDesc.layer.masksToBounds = true
        txtVwDesc.layer.borderColor = UIColor.lightGray.cgColor
        txtVwDesc.layer.borderWidth = 1
        vwUploadBg.layer.cornerRadius = 5
        vwUploadBg.layer.masksToBounds = true
        vwUploadBg.layer.borderColor = UIColor.lightGray.cgColor
        vwUploadBg.layer.borderWidth = 1
        self.designNavBarWithTitleAndBack(title: "Create New Form",showBack: true)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func btnSubmitClicked(_ sender: UIButton) {
    }
    @IBAction func btnUploadImageClicked(_ sender: UIButton) {
    }
    @IBAction func btnNoReceiptClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected
        {
            constVwUploagImageBgHeight.constant = 0
            vwUploadBg.isHidden = true
        }
        else
        {
            constVwUploagImageBgHeight.constant = 40
            vwUploadBg.isHidden = false
        }
    }
}
