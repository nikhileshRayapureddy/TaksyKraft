//
//  LoginViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 12/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    @IBOutlet weak var txtFldMobileNumber: UITextField!
    @IBOutlet weak var btnGenerateOTP: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    @IBAction func btnGenerateOTPClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if txtFldMobileNumber.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter mobile number.")
        }
        else
        {
            app_delegate.showLoader(message: "Loading.....")
            let layer = ServiceLayer()
            layer.getOtpWith(mobileNo: txtFldMobileNumber.text!, successMessage: { (response) in
                DispatchQueue.main.async {
                    app_delegate.removeloder()
                    let alert = UIAlertController(title: "Alert!", message: response as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        DispatchQueue.main.async {
                            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerifyOTPViewController") as! VerifyOTPViewController
                            vc.mobileNo = self.txtFldMobileNumber.text!
                            self.navigationController?.pushViewController(vc, animated: true)
                            TaksyKraftUserDefaults.setUserMobile(object: self.txtFldMobileNumber.text!)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)

                }
            }, failureMessage: { (error) in
                DispatchQueue.main.async {
                    app_delegate.removeloder()
                    self.showAlertWith(title: "Alert!", message: (error as? String)!)
                }
            })
        }
    }

}
extension LoginViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 10 // Bool
    }

}
