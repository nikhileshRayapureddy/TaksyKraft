//
//  CreateTravelViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 21/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class CreateTravelViewController: BaseViewController {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var txtFldFrom: UITextField!
    @IBOutlet weak var txtFldTo: UITextField!
    @IBOutlet weak var txtVwDesc: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCharCount: UILabel!
    @IBOutlet weak var vwBtnDateBase: UIView!
    let picker = UIPickerView()
    var selectedPickerRow = 0
    var vwSep = UIView()
    var arrCities = [CityBO]()
    var selTxtFld = UITextField()
    var travelBO = TravelBO()
    
    let datePicker = UIDatePicker()
    var isEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Create New Form",showBack: true, isRefresh: false)
        lblMobileNo.text = TaksyKraftUserDefaults.getUser().mobile
        lblName.text = TaksyKraftUserDefaults.getUser().name
        txtFldFrom.inputView = picker
        txtFldTo.inputView = picker
        
        txtFldTo.leftViewMode = .always
        txtFldFrom.leftViewMode = .always

        txtFldTo.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: txtFldTo.frame.size.height))
        txtFldFrom.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: txtFldFrom.frame.size.height))

        txtVwDesc.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtVwDesc.layer.borderWidth = 1.0

        txtFldFrom.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtFldFrom.layer.borderWidth = 1.0

        txtFldTo.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        txtFldTo.layer.borderWidth = 1.0

        vwBtnDateBase.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        vwBtnDateBase.layer.borderWidth = 1.0
        
        app_delegate.showLoader(message: "Fetching cities...")
        let layer = ServiceLayer()
        layer.getAllCities(successMessage: { (response) in
            DispatchQueue.main.async {
                app_delegate.removeloder()
                self.arrCities.append(contentsOf: response as! [CityBO])
                if self.travelBO.travelId != ""
                {
                    self.txtVwDesc.text = self.travelBO.Description
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = dateFormatter.date(from: self.travelBO.uploadedDate)
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let strDate = dateFormatter.string(from: date!)
                    self.btnDate.setTitle(strDate, for: .normal)
                    
                    var strFrom = ""
                    var strTo = ""
                    let arrFromFilter = self.arrCities.filter({ (trav) -> Bool in
                        if trav.cityCode.lowercased().contains(self.travelBO.from.lowercased())
                        {
                            return true
                        }
                        return false
                    })
                    
                    let arrToFilter = self.arrCities.filter({ (trav) -> Bool in
                        if trav.cityCode.lowercased().contains(self.travelBO.to.lowercased())
                        {
                            return true
                        }
                        return false
                    })
                    
                    
                    if arrFromFilter.count > 0
                    {
                        strFrom = arrFromFilter[0].cityName
                    }
                    if arrToFilter.count > 0
                    {
                        strTo = arrToFilter[0].cityName
                    }
                    self.txtFldFrom.text = strFrom
                    self.txtFldTo.text = strTo
                    
                }

            }
        }) { (failure) in
            DispatchQueue.main.async {
                app_delegate.removeloder()
                if EXP_TOKEN_ERR == failure as! String
                {
                    self.logout()
                }
                else
                {
                    let alert = UIAlertController(title: "Alert!", message: "Failed to get cities", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func btnDateClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        datePicker.frame = CGRect(x: 0, y: ScreenHeight-250, width: self.view.frame.width, height: 250)
        datePicker.backgroundColor = UIColor.white
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.datePickerMode = .date
//        let tmpDate = Calendar.current.date(byAdding: .year, value: -500, to: Date())
//        datePicker.minimumDate = tmpDate
//        datePicker.maximumDate = Date()
        self.view.addSubview(datePicker)
        
        let btnDone = UIButton(type: .custom)
        btnDone.frame = CGRect(x: 0, y: ScreenHeight-280, width: ScreenWidth, height: 30)
        btnDone.backgroundColor = UIColor.white
        btnDone.setTitleColor(.black, for: .normal)
        btnDone.contentVerticalAlignment = .center
        btnDone.contentHorizontalAlignment = .left
        btnDone.titleLabel?.font = UIFont(name: "Roboto", size: 14.0)
        btnDone.setTitle("  Done", for: .normal)
        btnDone.addTarget(self, action: #selector(self.btnCatPickerDoneClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnDone)
        
        vwSep = UIView(frame: CGRect(x: 0, y: ScreenHeight-251, width: ScreenWidth, height: 1))
        vwSep.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.view.addSubview(vwSep)
        
    }
    @objc func btnCatPickerDoneClicked(sender:UIButton)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: datePicker.date)
        btnDate.setTitle(strDate, for: .normal)

        datePicker.removeFromSuperview()
        sender.removeFromSuperview()
        vwSep.removeFromSuperview()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: datePicker.date)
        btnDate.setTitle(strDate, for: .normal)
    }

    @IBAction func btnSubmitClicked(_ sender: UIButton) {
        self.view.endEditing(true)

        if txtFldFrom.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please select Source.")
        }
        else if txtVwDesc.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please enter Description.")
        }
        else if txtFldTo.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please select Destination.")
        }
        else
        {
            var strFrom = ""
            var strTo = ""
            let arrFromFilter = arrCities.filter({ (trav) -> Bool in
                if trav.cityName.lowercased().contains(txtFldFrom.text!.lowercased())
                {
                    return true
                }
                return false
            })
            
            let arrToFilter = arrCities.filter({ (trav) -> Bool in
                if trav.cityName.lowercased().contains(txtFldTo.text!.lowercased())
                {
                    return true
                }
                return false
            })
            
            if self.travelBO.travelId != ""
            {
                
                if arrFromFilter.count > 0
                {
                    strFrom = arrFromFilter[0].cityCode
                    if arrFromFilter[0].cityCode != travelBO.from
                    {
                        isEdited = true
                    }
                    
                }
                if arrToFilter.count > 0
                {
                    strTo = arrToFilter[0].cityCode
                    if arrToFilter[0].cityCode != travelBO.to
                    {
                        isEdited = true
                    }
                    
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: self.travelBO.uploadedDate)
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let strDate = dateFormatter.string(from: date!)
                if self.btnDate.titleLabel?.text != strDate
                {
                    isEdited = true
                }
                if txtVwDesc.text != travelBO.Description
                {
                    isEdited = true
                }
            }
            else
            {
                if arrFromFilter.count > 0
                {
                    strFrom = arrFromFilter[0].cityCode
                }
                if arrToFilter.count > 0
                {
                    strTo = arrToFilter[0].cityCode
                }

                isEdited = true
            }
            if isEdited == true
            {
                app_delegate.showLoader(message: "Uploading...")
                let layer = ServiceLayer()
                layer.createOrUpdateTravelWith(strId :travelBO.travelId ,strFrom: strFrom, strTo: strTo, strJourneyDate: (btnDate.titleLabel?.text)!, strDesc: txtVwDesc.text, successMessage: { (response) in
                    DispatchQueue.main.async
                        {
                            app_delegate.removeloder()
                            let alert = UIAlertController(title: "Success!", message: "Travel Uploaded Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                    }
                }, failureMessage: { (failure) in
                    DispatchQueue.main.async
                        {
                            if EXP_TOKEN_ERR == failure as! String
                            {
                                self.logout()
                            }
                            else
                            {
                                app_delegate.removeloder()
                                let alert = UIAlertController(title: "Failure!", message: "Travel uploading failed.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                    }
                })
            }
            else
            {
                self.showAlertWith(title: "Alert!", message: "Please edit before updating")
            }
        }
        
    }


}
extension CreateTravelViewController : UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if txtFldTo == textField
        {
            selTxtFld = txtFldTo
            self.showPicker()
            return false
        }
        else if txtFldFrom == textField
        {
            selTxtFld = txtFldFrom
            self.showPicker()
            return false
        }
        return true
    }
    func showPicker() {
        picker.backgroundColor = UIColor.white
        picker.delegate = self
        picker.frame = CGRect(x: 0, y: ScreenHeight - 250, width: ScreenWidth, height: 250)
        self.view.addSubview(picker)
        
        let btnDone = UIButton(type: .custom)
        btnDone.frame = CGRect(x: 0, y: picker.frame.origin.y - 31, width: ScreenWidth, height: 30)
        btnDone.backgroundColor = UIColor.white
        btnDone.setTitleColor(.black, for: .normal)
        btnDone.contentVerticalAlignment = .center
        btnDone.contentHorizontalAlignment = .left
        btnDone.titleLabel?.font = UIFont(name: "Roboto", size: 14.0)
        btnDone.setTitle("  Done", for: .normal)
        btnDone.addTarget(self, action: #selector(self.btnPickerDoneClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnDone)
        
        vwSep = UIView(frame: CGRect(x: 0, y: picker.frame.origin.y - 1, width: ScreenWidth, height: 1))
        vwSep.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.view.addSubview(vwSep)
        
    }
    @objc func btnPickerDoneClicked(sender:UIButton)
    {
        if txtFldFrom == selTxtFld
        {
            txtFldFrom.text = arrCities[selectedPickerRow].cityName
            txtFldTo.text = ""
        }
        else
        {
            if txtFldFrom.text != arrCities[selectedPickerRow].cityName
            {
                txtFldTo.text = arrCities[selectedPickerRow].cityName
            }
            else
            {
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Alert!", message: "Source and Destination cannot be same.")
                }
            }
        }
        picker.removeFromSuperview()
        vwSep.removeFromSuperview()
        sender.removeFromSuperview()
    }

}

extension CreateTravelViewController : UITextViewDelegate
{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let strText = textView.text + text
        if (strText.count) <= TXTVW_MAX_COUNT
        {
            lblCharCount.text = "\(strText.count - range.length)/\(TXTVW_MAX_COUNT)"
            return true
        }
        else
        {
            return false
        }
    }
    
    
}
extension CreateTravelViewController : UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return arrCities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(arrCities[row].cityName) \(arrCities[row].cityCode)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedPickerRow = row
    }
}
