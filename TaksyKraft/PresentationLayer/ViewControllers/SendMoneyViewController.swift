//
//  SendMoneyViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 22/11/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class SendMoneyViewController: UIViewController {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var txtFldAmount: FloatLabelTextField!
    @IBOutlet weak var txtVwDesc: FloatLabelTextView!
    @IBOutlet weak var btnTransfer: UIButton!
    var employBO = EmployeBO()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        txtVwDesc.layer.cornerRadius = 5
        txtVwDesc.layer.masksToBounds = true
        txtVwDesc.layer.borderColor = UIColor.lightGray.cgColor
        txtVwDesc.layer.borderWidth = 1
        
        lblName.text = employBO.Name
        lblMobileNo.text = employBO.Mobile

    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnTransferClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if txtFldAmount.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Amount.")
        }
        else if txtVwDesc.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Description.")
        }
        else
        {
            app_delegate.showLoader(message: "Uploading...")
            let layer = ServiceLayer()
            layer.sendMoney(fromUser: TaksyKraftUserDefaults.getUserMobile(), toUser: employBO.Mobile, amt: txtFldAmount.text!, desc: txtVwDesc.text, successMessage: { (response) in
                DispatchQueue.main.async {
                    app_delegate.removeloder()
                    let alert = UIAlertController(title: "Success!", message: "Amount transfer Successfull.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (acction) in
                        DispatchQueue.main.async {
                            self.txtFldAmount.text = ""
                            self.txtVwDesc.text = ""
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)

                }
            }, failureMessage: { (error) in
                DispatchQueue.main.async {
                    app_delegate.removeloder()
                    self.showAlertWith(title: "Alert!", message: "Amount transfer failed.")
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func showAlertWith(title : String,message : String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }

}
