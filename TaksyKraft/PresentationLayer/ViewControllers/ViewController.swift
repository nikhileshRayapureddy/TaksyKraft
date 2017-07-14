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
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtFldOTP.text = ""
        txtFldMobileNo.text = ""
    }
    func sendOTP()
    {
        self.view.endEditing(true)
        app_delegate.showLoader(message: "")
        let serviceLayer = ServiceLayer()
        serviceLayer.loginWithEmailId(mobileNo: txtFldMobileNo.text!, successMessage: { (SR) in
            print("SR : \(SR)")
            app_delegate.removeloder()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert!", message: "A new OTP Have Been Sent To Your Mobile Number, Please Verify!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                    self.vwLogin.isHidden = true
                    self.vwOTP.isHidden = false
                    self.lblOTPSenTO.text = "OTP sent to \(self.txtFldMobileNo.text!)"
                    TaksyKraftUserDefaults.setUserMobile(object: self.txtFldMobileNo.text!)
                    }
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
        self.view.endEditing(true)
        app_delegate.showLoader(message: "")
        let serviceLayer = ServiceLayer()
        serviceLayer.checkLoginWith(mobileNo: txtFldMobileNo.text!, Otp: txtFldOTP.text!, successMessage: { (SR) in
            app_delegate.removeloder()
            print("SR : \(SR)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert!", message: "OTP Verified Sucessfully.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                    let bo = SR as! UserBO
                    UIApplication.shared.statusBarStyle = .lightContent
                    let statWindow = UIApplication.shared.value(forKey:"statusBarWindow") as! UIView
                    let statusBar = statWindow.subviews[0] as UIView
                    statusBar.backgroundColor = Color_NavBarTint
                    TaksyKraftUserDefaults.setLoginStatus(object: true)
                    let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
                    if bo.role == "1"
                    {
                        vc.isMyExpense = true
                        vc.isFromExpenses = false
                    }
                    else if bo.role == "2"
                    {
                        vc.isMyExpense = true
                        vc.isFromExpenses = false
                    }
                    else
                    {
                        vc.isMyExpense = false
                        vc.isFromExpenses = false
                    }
                        TaksyKraftUserDefaults.setUserRole(object: bo.role)
                        TaksyKraftUserDefaults.setIsMyExpense(object: vc.isMyExpense)
                        TaksyKraftUserDefaults.setIsFromExpenses(object: vc.isFromExpenses)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
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
        txtFldOTP.text = ""
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
        vwLogin.isHidden = false
        txtFldOTP.text = ""
        txtFldMobileNo.text = ""
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
