//
//  ViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 29/06/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
let app_delegate =  UIApplication.shared.delegate as! AppDelegate

class ViewController: BaseViewController {

    @IBOutlet weak var vwOTP: UIView!
    @IBOutlet weak var vwLogin: UIView!
    @IBOutlet weak var txtFldOTP: FloatLabelTextField!
    @IBOutlet weak var txtFldMobileNo: FloatLabelTextField!
    
    @IBOutlet weak var btnSendOTP: UIButton!
    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet weak var lblOTPSenTO: UILabel!
    
    @IBOutlet weak var btnResendOTP: UIButton!
    @IBOutlet weak var btnWrongNo: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtFldMobileNo.text = "9985655665"
    }
    func sendOTP()
    {
        app_delegate.showLoader(message: "")
        let serviceLayer = ServiceLayer()
        serviceLayer.loginWithEmailId(mobileNo: txtFldMobileNo.text!, successMessage: { (SR) in
            print("SR : \(SR)")
            app_delegate.removeloder()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert!", message: "A new OTP Have Been Sent To Your Mobile Number, Please Verify!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    self.vwLogin.isHidden = true
                    self.vwOTP.isHidden = false
                    self.lblOTPSenTO.text = "OTP sent to \(self.txtFldMobileNo.text!)"
                    TaksyKraftUserDefaults.setUserMobile(object: self.txtFldMobileNo.text!)
                }))
                self.present(alert, animated: true, completion: nil)


            }
        }) { (FR) in
            print("FR : \(FR)")
            app_delegate.removeloder()
            self.showAlertWith(title: "Alert!", message: FR as! String)
        }
    }
    func CheckOTP()
    {
        app_delegate.showLoader(message: "")
        let serviceLayer = ServiceLayer()
        serviceLayer.checkLoginWith(mobileNo: txtFldMobileNo.text!, Otp: txtFldOTP.text!, successMessage: { (SR) in
            app_delegate.removeloder()
            print("SR : \(SR)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert!", message: "OTP Verified Sucessfully.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }

        }) { (FR) in
            app_delegate.removeloder()
            print("FR : \(FR)")
            self.showAlertWith(title: "Alert!", message: "OTP Verification Failed.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnResendOTPClicked(_ sender: UIButton) {
        self.sendOTP()
    }
    @IBAction func btnSendOTPClicked(_ sender: UIButton) {
        if txtFldMobileNo.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter valid Mobile Number.")
        }
        else
        {
            self.sendOTP()
        }
    }

    @IBAction func btnWrongNoClicked(_ sender: UIButton) {
            vwOTP.isHidden = true
    }
    @IBAction func btnVerifyClicked(_ sender: UIButton) {
        if txtFldOTP.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter valid OTP.")
        }
        else
        {
            self.CheckOTP()
        }
    }
}
extension ViewController:UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
