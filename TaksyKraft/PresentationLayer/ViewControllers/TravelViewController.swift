//
//  TravelViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 21/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class TravelViewController: BaseViewController , UIPopoverPresentationControllerDelegate {
    
    let Tag_Reupload = 1000
    let Tag_Delete = 2000
    let Tag_Approve = 3000
    let Tag_Verify = 4000
    let Tag_Reject = 5000
    let Tag_PayNow = 6000
    var isMyTravel = false
    @IBOutlet weak var tblTravels: UITableView!
    @IBOutlet weak var constBtnSwitchHeight: NSLayoutConstraint!
    
    @IBOutlet var txtFldSearch: UITextField!
    var arrMyList = [TravelBO]()
    var arrAllList = [TravelBO]()
    
    var arrFilter = [TravelBO]()
    var rejectPopup : RejectPopup!
    var rejTravelID = ""
    @IBOutlet weak var btnSwitch: UISegmentedControl!
    @IBOutlet weak var lblNoDataFound: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblTravels.register(UINib(nibName: "ExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "ExpensesTableViewCell")
        if TaksyKraftUserDefaults.getUser().role == "employee"
        {
            constBtnSwitchHeight.constant = 0
            btnSwitch.isHidden = true
        }
        else
        {
            constBtnSwitchHeight.constant = 30
            btnSwitch.isHidden = false
        }
        self.isMyTravel = true
        self.callForData()
        txtFldSearch.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: txtFldSearch.frame.size.width/2 - 20, y: 0, width: 40, height: 20))
        imageView.image = #imageLiteral(resourceName: "Search")
        imageView.contentMode = .scaleAspectFit
        txtFldSearch.leftView = imageView

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Travel", showBack: true, isRefresh: true)

    }
    override func btnRefreshClicked( sender:UIButton)
    {
        self.callForData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnSwitchClicked(_ sender: UISegmentedControl) {
        txtFldSearch.text = ""
        arrFilter.removeAll()
        if sender.selectedSegmentIndex == 0
        {
            isMyTravel = true
            if arrMyList.count > 0
            {
                tblTravels.isHidden = false
                lblNoDataFound.isHidden = true
                arrFilter.append(contentsOf: arrMyList)
                tblTravels.reloadData()
            }
            else
            {
                self.callForData()
            }
        }
        else
        {
            isMyTravel = false
            if arrAllList.count > 0
            {
                tblTravels.isHidden = false
                lblNoDataFound.isHidden = true
                arrFilter.append(contentsOf: arrAllList)
                tblTravels.reloadData()
            }
            else
            {
                self.callForData()
            }
            
        }
    }
    @IBAction func btnAddClicked(_ sender: UIButton) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateTravelViewController") as! CreateTravelViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func callForData()
    {
        if isMyTravel
        {
            self.callForMyTravelsData()
        }
        else
        {
            self.callForAllTravelsData()
        }
    }
    func callForAllTravelsData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        let serviceLayer = ServiceLayer()
        serviceLayer.getAllTravels(successMessage: { (response) in
            app_delegate.removeloder()
            self.arrAllList.removeAll()
            self.arrAllList = response as! [TravelBO]
            DispatchQueue.main.async {
                if self.arrAllList.count > 0
                {
                    self.arrFilter.removeAll()
                    if self.txtFldSearch.text != ""
                    {
                        if let str = self.txtFldSearch.text
                        {
                            self.arrFilter = self.arrAllList.filter({ (trv) -> Bool in
                                if trv.travelId.lowercased().contains(str.lowercased())
                                {
                                    return true
                                }
                                return false
                            })
                        }
                    }
                    else
                    {
                        self.arrFilter.append(contentsOf: self.arrAllList)
                    }
                    self.tblTravels.reloadData()
                    self.lblNoDataFound.isHidden = true
                    self.tblTravels.isHidden = false
                }
                else
                {
                    self.tblTravels.isHidden = true
                    self.lblNoDataFound.isHidden = false
                }
            }
        }) { (failure) in
            app_delegate.removeloder()
            if EXP_TOKEN_ERR == failure as! String
            {
                self.logout()
            }
            else
            {
                self.isMyTravel = true
                self.btnSwitch.selectedSegmentIndex = 0
                self.showAlertWith(title: "Alert!", message: failure as! String)
            }
        }
    }
    func callForMyTravelsData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        let serviceLayer = ServiceLayer()
        serviceLayer.getMyTravels(successMessage: { (response) in
            app_delegate.removeloder()
            self.arrMyList.removeAll()
            self.arrMyList = response as! [TravelBO]
            DispatchQueue.main.async {
                if self.arrMyList.count > 0
                {
                    self.arrFilter.removeAll()
                    if self.txtFldSearch.text != ""
                    {
                        if let str = self.txtFldSearch.text
                        {
                            self.arrFilter = self.arrMyList.filter({ (trv) -> Bool in
                                if trv.travelId.lowercased().contains(str.lowercased())
                                {
                                    return true
                                }
                                return false
                            })
                        }
                    }
                    else
                    {
                        self.arrFilter.append(contentsOf: self.arrMyList)
                    }

                    self.tblTravels.reloadData()
                    self.lblNoDataFound.isHidden = true
                    self.tblTravels.isHidden = false
                }
                else
                {
                    self.tblTravels.isHidden = true
                    self.lblNoDataFound.isHidden = false
                }
            }
        }) { (failure) in
            app_delegate.removeloder()
            DispatchQueue.main.async {
                if EXP_TOKEN_ERR == failure as! String
                {
                    self.logout()
                }
                else
                {
                    self.isMyTravel = false
                    self.btnSwitch.selectedSegmentIndex = 1
                    self.showAlertWith(title: "Alert!", message: failure as! String)
                }
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
}

extension TravelViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isMyTravel
        {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "MyTravelTableViewCell", for: indexPath)  as! MyTravelTableViewCell
            let travel = arrFilter[indexPath.row]
            cell.lblTravelID.text = travel.travelId
            cell.lblSrcAndDest.text = "\(travel.from.prefix(3).uppercased())\nto\n\(travel.to.prefix(3).uppercased())"
            cell.lblSrcAndDest.layer.cornerRadius = cell.lblSrcAndDest.frame.size.width/2
            cell.lblSrcAndDest.layer.masksToBounds = true
            cell.lblSrcAndDest.layer.borderColor = UIColor.lightGray.cgColor
            cell.lblSrcAndDest.layer.borderWidth = 1.0

            let str = "Description :\n" + travel.Description
            
            let attributedString = NSMutableAttributedString(string: str)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 13))
            cell.lblDescription.attributedText = attributedString

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.date(from: travel.uploadedDate)
            formatter.dateFormat = "dd MMM, yyyy"
            let strDate = formatter.string(from: date!)
            
            cell.lblUploadedDate.text = strDate
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.lblStatus.text = travel.status.capitalized
            cell.vwBase.layer.cornerRadius = 5
            cell.vwBase.layer.masksToBounds = true
            cell.btnReUpload.layer.cornerRadius = 5
            cell.btnReUpload.layer.masksToBounds = true
            cell.btnDelete.layer.cornerRadius = 5
            cell.btnDelete.layer.masksToBounds = true
            cell.callBack = self
            cell.travel = travel
            
            cell.btnDelete.layer.borderColor = UIColor(red: 183.0/255.0, green: 205.0/255.0, blue: 85.00/255.0, alpha: 1.0).cgColor
            cell.btnDelete.layer.borderWidth = 1.0
            cell.btnReUpload.tag = Tag_Reupload + indexPath.row
            cell.btnDelete.tag = Tag_Delete + indexPath.row
            cell.constLblReasonHeight.constant = 0
            cell.lblReason.text = ""
            cell.lblReason.isHidden = true
            var descHeight = ("Description :\n" + travel.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
            if travel.Description == ""
            {
                descHeight = 0
            }
            else
            {
                descHeight = descHeight + 10
            }
            
            cell.constLblDescriptionHeight.constant = descHeight
            if travel.status == "pending"
            {
                cell.btnReUpload.isHidden = false
                cell.btnDelete.isHidden = false
                cell.vwBtnBase.isHidden = false
                cell.constVwBtnBaseHeight.constant = 30
                cell.lblStatus.textColor = UIColor(red: 139.0/255.0, green: 87.0/255.0, blue: 42.00/255.0, alpha: 1.0)
            }
            else if travel.status == "paid"
            {
                cell.btnReUpload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0
                cell.lblStatus.textColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 1.0)
            }
            else if travel.status == "booked"
            {
                cell.btnReUpload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0
                cell.lblStatus.textColor = UIColor(red: 245.0/255.0, green: 166.0/255.0, blue: 35.0/255.0, alpha: 1.0)
            }
            else if travel.status == "approved"
            {
                cell.btnReUpload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0
                cell.lblStatus.textColor = UIColor(red: 126.0/255.0, green: 211.0/255.0, blue: 33.0/255.0, alpha: 1.0)
            }
            else if travel.status == "rejected"
            {
                cell.btnReUpload.isHidden = false
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = false
                var reasonHeight = ("Reason :\n" + travel.comment).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if travel.comment == ""
                {
                    reasonHeight = 0
                }
                else
                {
                    reasonHeight = reasonHeight + 10
                }
                
                cell.constLblReasonHeight.constant = reasonHeight
                cell.constVwBtnBaseHeight.constant = 30
                let str = "Reason :\n" + travel.comment
                
                let attributedString = NSMutableAttributedString(string: str)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 8))
                cell.lblReason.attributedText = attributedString

                cell.lblReason.text = "Reason :\n" + travel.comment
                cell.lblReason.isHidden = false
                cell.lblStatus.textColor = UIColor(red: 208.0/255.0, green: 2.0/255.0, blue: 27.0/255.0, alpha: 1.0)
            }
            else
            {
                cell.btnReUpload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.lblStatus.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0
            }
            return cell
        }
        else
        {
            if TaksyKraftUserDefaults.getUser().role == "admin"
            {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "AllTravelTableViewCell", for: indexPath)  as! AllTravelTableViewCell
                let travel = arrFilter[indexPath.row]
                cell.lblEmployeeName.text = travel.empName
                cell.lblEmpID.text = travel.empId
                cell.lblTravelID.text = travel.travelId
                
                let str = "Description :\n" + travel.Description
                
                let attributedString = NSMutableAttributedString(string: str)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 13))
                cell.lblDescription.attributedText = attributedString
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.lblSrcAndDest.text = "\(travel.from.prefix(3).uppercased())\nto\n\(travel.to.prefix(3).uppercased())"
                cell.lblSrcAndDest.layer.cornerRadius = cell.lblSrcAndDest.frame.size.width/2
                cell.lblSrcAndDest.layer.masksToBounds = true
                cell.lblSrcAndDest.layer.borderColor = UIColor.lightGray.cgColor
                cell.lblSrcAndDest.layer.borderWidth = 1.0

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = formatter.date(from: travel.uploadedDate)
                formatter.dateFormat = "dd MMM, yyyy"
                let strDate = formatter.string(from: date!)
                
                cell.lblUploadedDate.text = strDate
                var descHeight = ("Description :\n" + travel.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if travel.Description == ""
                {
                    descHeight = 0
                }
                else
                {
                    descHeight = descHeight + 10
                }
                
                cell.constLblDescriptionHeight.constant = descHeight
                
                cell.vwBase.layer.cornerRadius = 5
                cell.vwBase.layer.masksToBounds = true
                cell.btnBookNow.layer.cornerRadius = 5
                cell.btnBookNow.layer.masksToBounds = true
                cell.btnApprove.layer.cornerRadius = 5
                cell.btnApprove.layer.masksToBounds = true
                cell.btnReject.layer.cornerRadius = 5
                cell.btnReject.layer.masksToBounds = true
                cell.btnReject.layer.borderColor = UIColor(red: 183.0/255.0, green: 205.0/255.0, blue: 85.00/255.0, alpha: 1.0).cgColor
                cell.btnReject.layer.borderWidth = 1.0
                
                
                cell.btnReject.tag = Tag_Reject + indexPath.row
                cell.btnBookNow.tag = Tag_PayNow + indexPath.row
                cell.btnApprove.tag = Tag_Approve + indexPath.row
                cell.callback  = self
                cell.travel = travel
                if travel.status == "pending"
                {
                    cell.btnApprove.isHidden = false
                    cell.btnReject.isHidden = false
                }
                else
                {
                    cell.btnApprove.isHidden = true
                    cell.btnReject.isHidden = true
                }
                cell.btnBookNow.isHidden = true

                return cell
            }
            else if TaksyKraftUserDefaults.getUser().role == "finance"
            {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "MyTravelTableViewCell", for: indexPath)  as! MyTravelTableViewCell
                let travel = arrFilter[indexPath.row]
                cell.lblTravelID.text = travel.travelId
                cell.lblSrcAndDest.text = "\(travel.from.prefix(3).uppercased())\nto\n\(travel.to.prefix(3).uppercased())"
                cell.lblSrcAndDest.layer.cornerRadius = cell.lblSrcAndDest.frame.size.width/2
                cell.lblSrcAndDest.layer.masksToBounds = true
                cell.lblSrcAndDest.layer.borderColor = UIColor.lightGray.cgColor
                cell.lblSrcAndDest.layer.borderWidth = 1.0

                let str = "Description :\n" + travel.Description
                
                let attributedString = NSMutableAttributedString(string: str)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 13))
                cell.lblDescription.attributedText = attributedString
                if travel.uploadedDate != ""
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = formatter.date(from: travel.uploadedDate)
                    formatter.dateFormat = "dd MMM, yyyy"
                    let strDate = formatter.string(from: date!)
                    
                    cell.lblUploadedDate.text = strDate
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                cell.lblStatus.text = travel.status.capitalized
                cell.vwBase.layer.cornerRadius = 5
                cell.vwBase.layer.masksToBounds = true
                cell.btnReUpload.layer.cornerRadius = 5
                cell.btnReUpload.layer.masksToBounds = true
                cell.btnDelete.layer.cornerRadius = 5
                cell.btnDelete.layer.masksToBounds = true
                cell.callBack = self
                cell.travel = travel
                
                cell.btnDelete.layer.borderColor = UIColor(red: 183.0/255.0, green: 205.0/255.0, blue: 85.00/255.0, alpha: 1.0).cgColor
                cell.btnDelete.layer.borderWidth = 1.0
                cell.btnReUpload.tag = Tag_Reupload + indexPath.row
                cell.btnDelete.tag = Tag_Delete + indexPath.row
                cell.constLblReasonHeight.constant = 0
                cell.lblReason.text = ""
                cell.lblReason.isHidden = true
                var descHeight = ("Description :\n" + travel.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if travel.Description == ""
                {
                    descHeight = 0
                }
                else
                {
                    descHeight = descHeight + 10
                }
                
                cell.constLblDescriptionHeight.constant = descHeight
                cell.btnReUpload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0

                if travel.status == "pending"
                {
                    cell.lblStatus.textColor = UIColor(red: 139.0/255.0, green: 87.0/255.0, blue: 42.00/255.0, alpha: 1.0)
                }
                else if travel.status == "booked"
                {
                    cell.lblStatus.textColor = UIColor(red: 245.0/255.0, green: 166.0/255.0, blue: 35.0/255.0, alpha: 1.0)
                }
                else if travel.status == "approved"
                {
                    cell.lblStatus.textColor = UIColor(red: 126.0/255.0, green: 211.0/255.0, blue: 33.0/255.0, alpha: 1.0)
                }
                else if travel.status == "rejected"
                {
                    var reasonHeight = ("Reason :\n" + travel.comment).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                    if travel.comment == ""
                    {
                        reasonHeight = 0
                    }
                    else
                    {
                        reasonHeight = reasonHeight + 10
                    }
                    
                    cell.constLblReasonHeight.constant = reasonHeight
                    let str = "Reason :\n" + travel.comment
                    
                    let attributedString = NSMutableAttributedString(string: str)
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 8))
                    cell.lblReason.attributedText = attributedString
                    
                    cell.lblReason.text = "Reason :\n" + travel.comment
                    cell.lblReason.isHidden = false
                    cell.lblStatus.textColor = UIColor(red: 208.0/255.0, green: 2.0/255.0, blue: 27.0/255.0, alpha: 1.0)
                }
                else
                {
                    cell.lblStatus.isHidden = true
                }
                return cell
            }
            else if TaksyKraftUserDefaults.getUser().role == "hr"
            {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "AllTravelTableViewCell", for: indexPath)  as! AllTravelTableViewCell
                let travel = arrFilter[indexPath.row]
                cell.lblEmployeeName.text = travel.empName
                cell.lblEmpID.text = travel.empId
                cell.lblTravelID.text = travel.travelId
                
                let str = "Description :\n" + travel.Description
                
                let attributedString = NSMutableAttributedString(string: str)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 13))
                cell.lblDescription.attributedText = attributedString
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.lblSrcAndDest.text = "\(travel.from.prefix(3).uppercased())\nto\n\(travel.to.prefix(3).uppercased())"
                cell.lblSrcAndDest.layer.cornerRadius = cell.lblSrcAndDest.frame.size.width/2
                cell.lblSrcAndDest.layer.masksToBounds = true
                cell.lblSrcAndDest.layer.borderColor = UIColor.lightGray.cgColor
                cell.lblSrcAndDest.layer.borderWidth = 1.0

                if travel.uploadedDate != ""
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = formatter.date(from: travel.uploadedDate)
                    formatter.dateFormat = "dd MMM, yyyy"
                    let strDate = formatter.string(from: date!)
                    
                    cell.lblUploadedDate.text = strDate
                }
                var descHeight = ("Description :\n" + travel.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if travel.Description == ""
                {
                    descHeight = 0
                }
                else
                {
                    descHeight = descHeight + 10
                }
                
                cell.constLblDescriptionHeight.constant = descHeight
                
                cell.vwBase.layer.cornerRadius = 5
                cell.vwBase.layer.masksToBounds = true
                cell.btnBookNow.layer.cornerRadius = 5
                cell.btnBookNow.layer.masksToBounds = true
                cell.btnApprove.layer.cornerRadius = 5
                cell.btnApprove.layer.masksToBounds = true
                cell.btnReject.layer.cornerRadius = 5
                cell.btnReject.layer.masksToBounds = true
                cell.btnReject.layer.borderColor = UIColor(red: 183.0/255.0, green: 205.0/255.0, blue: 85.00/255.0, alpha: 1.0).cgColor
                cell.btnReject.layer.borderWidth = 1.0
                
                
                cell.btnReject.tag = Tag_Reject + indexPath.row
                cell.btnBookNow.tag = Tag_PayNow + indexPath.row
                cell.btnApprove.tag = Tag_Approve + indexPath.row
                cell.callback  = self
                cell.travel = travel
                if travel.status == "approved"
                {
                    cell.btnBookNow.isHidden = false
                }
                else
                {
                    cell.btnBookNow.isHidden = true

                }
                cell.btnApprove.isHidden = true
                cell.btnReject.isHidden = true

                
                return cell
            }
            else
            {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "AllTravelTableViewCell", for: indexPath)  as! AllTravelTableViewCell
                let travel = arrFilter[indexPath.row]
                cell.lblEmployeeName.text = travel.empName
                cell.lblEmpID.text = travel.empId
                cell.lblTravelID.text = travel.travelId
                
                let str = "Description :\n" + travel.Description
                
                let attributedString = NSMutableAttributedString(string: str)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 13))
                cell.lblDescription.attributedText = attributedString
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.lblSrcAndDest.text = "\(travel.from.prefix(3).uppercased())\nto\n\(travel.to.prefix(3).uppercased())"
                cell.lblSrcAndDest.layer.cornerRadius = cell.lblSrcAndDest.frame.size.width/2
                cell.lblSrcAndDest.layer.masksToBounds = true
                cell.lblSrcAndDest.layer.borderColor = UIColor.lightGray.cgColor
                cell.lblSrcAndDest.layer.borderWidth = 1.0

                if travel.uploadedDate != ""
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = formatter.date(from: travel.uploadedDate)
                    formatter.dateFormat = "dd MMM, yyyy"
                    let strDate = formatter.string(from: date!)
                    
                    cell.lblUploadedDate.text = strDate
                }
                var descHeight = ("Description :\n" + travel.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if travel.Description == ""
                {
                    descHeight = 0
                }
                else
                {
                    descHeight = descHeight + 10
                }
                
                cell.constLblDescriptionHeight.constant = descHeight
                
                cell.vwBase.layer.cornerRadius = 5
                cell.vwBase.layer.masksToBounds = true
                cell.btnBookNow.layer.cornerRadius = 5
                cell.btnBookNow.layer.masksToBounds = true
                cell.btnApprove.layer.cornerRadius = 5
                cell.btnApprove.layer.masksToBounds = true
                cell.btnReject.layer.cornerRadius = 5
                cell.btnReject.layer.masksToBounds = true
                cell.btnReject.layer.borderColor = UIColor(red: 183.0/255.0, green: 205.0/255.0, blue: 85.00/255.0, alpha: 1.0).cgColor
                cell.btnReject.layer.borderWidth = 1.0
                
                
                cell.btnReject.tag = Tag_Reject + indexPath.row
                cell.btnBookNow.tag = Tag_PayNow + indexPath.row
                cell.btnApprove.tag = Tag_Approve + indexPath.row
                cell.callback  = self
                cell.travel = travel
                cell.btnApprove.isHidden = true
                cell.btnReject.isHidden = true
                cell.btnBookNow.isHidden = false
                
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isMyTravel
        {
            let bo = arrFilter[indexPath.row]
            var descHeight = bo.Description.height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
            if bo.Description == ""
            {
                descHeight = 0
            }
            
            if bo.status == "rejected"
            {
                var resonHeight = bo.comment.height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if bo.comment == ""
                {
                    resonHeight = 0
                }
                return 140 + descHeight + resonHeight + 70
            }
            else
            {
                return 140 + descHeight  + 20
            }
        }
        else
        {
            
            if TaksyKraftUserDefaults.getUser().role == "admin"
            {
                let bo = arrFilter[indexPath.row]
                var descHeight = bo.Description.height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if bo.Description == ""
                {
                    descHeight = 0
                }
                return 140 + descHeight  + 40
            }
            else if TaksyKraftUserDefaults.getUser().role == "finance"
            {
                let bo = arrFilter[indexPath.row]
                var descHeight = bo.Description.height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if bo.Description == ""
                {
                    descHeight = 0
                }
                if bo.status == "rejected"
                {
                    var resonHeight = bo.comment.height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                    if bo.comment == ""
                    {
                        resonHeight = 0
                    }
                    return 130 + descHeight + resonHeight + 40
                }
                else
                {
                    return 130 + (descHeight < 30 ? 30 : descHeight)
                }
            }
            else
            {
                let bo = arrFilter[indexPath.row]
                var descHeight = bo.Description.height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if bo.Description == ""
                {
                    descHeight = 0
                }
                return 140 + descHeight  + 40
            }
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    func updateStatusWith(strStatus : String,expenseID : String)
    {
        app_delegate.showLoader(message: "Updating...")
        var comment = ""
        if strStatus == "rejected"
        {
            comment = rejectPopup.txtVwResaon.text!
        }
        let layer = ServiceLayer()
        layer.updateStatusOfTravelWith(strID: expenseID, strStatus: strStatus,strComment :comment,successMessage: { (response) in
            DispatchQueue.main.async {
                app_delegate.removeloder()
                if self.rejectPopup != nil
                {
                    self.rejectPopup.removeFromSuperview()
                }
                let alert = UIAlertController(title: "Success!", message: "Travel Updated Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                        self.callForData()
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                
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
                    self.showAlertWith(title: "Alert!", message: failure as! String)
                }
            }
        }
        
    }
    
}
extension TravelViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text! + string)
        
        var strSearch = textField.text! + string
        
        if range.location == 0 && range.length == 1
        {
            strSearch = ""
            arrFilter.removeAll()
            if isMyTravel
            {
                arrFilter.append(contentsOf: self.arrMyList)
            }
            else
            {
                arrFilter.append(contentsOf: self.arrAllList)
            }
            
        }
        else
        {
            if isMyTravel
            {
                arrFilter = arrMyList.filter({ (travel) -> Bool in
                    if travel.travelId.lowercased().contains(strSearch.lowercased())
                    {
                        return true
                    }
                    return false
                })
            }
            else
            {
                arrFilter = arrAllList.filter({ (travel) -> Bool in
                    if travel.travelId.lowercased().contains(strSearch.lowercased())
                    {
                        return true
                    }
                    return false
                })
            }
        }
        tblTravels.reloadData()
        return true
    }
}
extension TravelViewController : AllTravelTableViewCellDelegate
{
    func btnApproveClicked(travelId: String, cell: AllTravelTableViewCell) {
        self.updateStatusWith(strStatus: "approved", expenseID: travelId)

    }
    
    func btnBookNowClicked(travelId: String, cell: AllTravelTableViewCell) {
        self.updateStatusWith(strStatus: "booked", expenseID: travelId)

    }
    
    func btnRejectClicked(travelId: String, cell: AllTravelTableViewCell) {
        if let popup = Bundle.main.loadNibNamed("RejectPopup", owner: nil, options: nil)![0] as? RejectPopup
        {
            self.rejTravelID = travelId
            rejectPopup = popup
            rejectPopup?.frame = CGRect(x:0,y: 0,width: ScreenWidth, height:ScreenHeight)
            rejectPopup.txtVwResaon.layer.borderWidth = 1
            rejectPopup.txtVwResaon.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
            rejectPopup.txtVwResaon.layer.masksToBounds = true
            rejectPopup.txtVwResaon.layer.cornerRadius = 5
            rejectPopup.btnCancel.addTarget(self, action: #selector(btnCancelClicked(sender:)), for: .touchUpInside)
            rejectPopup.btnReject.addTarget(self, action: #selector(btnRejectConfirmClicked(sender:)), for: .touchUpInside)
            self.view.addSubview(rejectPopup)
        }
    }
    func btnCancelClicked(sender : UIButton)
    {
        rejectPopup.removeFromSuperview()
    }
    
    func btnRejectConfirmClicked(sender : UIButton)
    {
        if rejectPopup.txtVwResaon.text == ""
        {
            rejectPopup.constLblReasonAlertHeight.constant = 20
        }
        else
        {
            rejectPopup.constLblReasonAlertHeight.constant = 0
            self.updateStatusWith(strStatus: "rejected", expenseID: self.rejTravelID)
        }
    }
    
}
extension TravelViewController : MyTravelTableViewCellDelegate
{
    func btnReuploadClicked(travel : TravelBO,cell : MyTravelTableViewCell)
    {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateTravelViewController") as! CreateTravelViewController
        vc.travelBO = travel
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func btnDeleteClicked(travelId : String,cell : MyTravelTableViewCell)
    {
        let alert = UIAlertController(title: "Alert!", message: "Do you want to delete this travel?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                app_delegate.showLoader(message: "Deleting Travel...")
                let layer = ServiceLayer()
                layer.deleteTravelWith(strID: travelId, successMessage: { (response) in
                    DispatchQueue.main.async {
                        app_delegate.removeloder()
                        let alert = UIAlertController(title: "Success!", message: "Travel deleted Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            DispatchQueue.main.async {
                                self.callForData()
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }) { (failure) in
                    app_delegate.removeloder()
                    if EXP_TOKEN_ERR == failure as! String
                    {
                        self.logout()
                    }
                    else
                    {
                        self.showAlertWith(title: "Alert!", message: failure as! String)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
