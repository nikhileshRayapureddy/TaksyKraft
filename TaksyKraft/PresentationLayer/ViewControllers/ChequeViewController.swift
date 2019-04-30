//
//  ChequeViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 27/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class ChequeViewController: BaseViewController {
    
    @IBOutlet weak var btnSwitch: UISegmentedControl!
    @IBOutlet weak var tblCheque: UITableView!
    @IBOutlet weak var txtFldSearch: UITextField!
    @IBOutlet weak var constBtnSwitchHeight: NSLayoutConstraint!
    @IBOutlet weak var lblNoDataFound: UILabel!
    var rejectPopup : RejectPopup!
    var rejChqID = ""

    var arrFilter = [ChequeBO]()
    var arrAllList = [ChequeBO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callForAllChequesData()
        txtFldSearch.leftViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: txtFldSearch.frame.size.width/2 - 20, y: 0, width: 40, height: 20))
        imageView.image = #imageLiteral(resourceName: "Search")
        imageView.contentMode = .scaleAspectFit
        txtFldSearch.leftView = imageView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Cheques", showBack: true, isRefresh: true)
    }
    override func btnRefreshClicked( sender:UIButton)
    {
        self.callForAllChequesData()
    }

    func callForAllChequesData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        let serviceLayer = ServiceLayer()
        serviceLayer.getAllCheques(successMessage: { (response) in
            app_delegate.removeloder()
            self.arrAllList.removeAll()
            self.arrAllList = response as! [ChequeBO]
            DispatchQueue.main.async {
                if self.arrAllList.count > 0
                {
                    self.arrFilter.removeAll()
                    if self.txtFldSearch.text != ""
                    {
                        if let str = self.txtFldSearch.text
                        {
                            self.arrFilter = self.arrAllList.filter({ (chq) -> Bool in
                                if chq.chequeId.lowercased().contains(str.lowercased())
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

                    self.tblCheque.reloadData()
                    self.lblNoDataFound.isHidden = true
                }
                else
                {
                    self.tblCheque.isHidden = true
                    self.lblNoDataFound.isHidden = false
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
                    self.showAlertWith(title: "Alert!", message: failure as! String)
                }
            }
        }
    }
    func callForMyChequesData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        let serviceLayer = ServiceLayer()
        serviceLayer.getMyCheques(successMessage: { (response) in
            app_delegate.removeloder()
            self.arrAllList.removeAll()
            self.arrAllList = response as! [ChequeBO]
            DispatchQueue.main.async {
                if self.arrAllList.count > 0
                {
                    self.arrFilter.removeAll()
                    if self.txtFldSearch.text != ""
                    {
                        if let str = self.txtFldSearch.text
                        {
                            self.arrFilter = self.arrAllList.filter({ (chq) -> Bool in
                                if chq.chequeId.lowercased().contains(str.lowercased())
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

                    self.arrFilter.append(contentsOf: self.arrAllList)
                    self.tblCheque.reloadData()
                    self.lblNoDataFound.isHidden = true
                }
                else
                {
                    self.tblCheque.isHidden = true
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
                    self.btnSwitch.selectedSegmentIndex = 1
                    self.showAlertWith(title: "Alert!", message: failure as! String)
                }
            }
        }
    }

    @IBAction func btnAddChequeClicked(_ sender: UIButton) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateChequeViewController") as! CreateChequeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension ChequeViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AllChequesTableViewCell", for: indexPath)  as! AllChequesTableViewCell
        let chqBo = arrFilter[indexPath.row]
        cell.lblID.text = chqBo.chequeId
        cell.lblAmt.text = "₹" + chqBo.amount
        cell.lblChequeNo.text = chqBo.chequeNo
        cell.lblAttachsCount.text = "\(chqBo.invoice_image.count + 1) Attachments"
        let url = URL(string: IMAGE_BASE_URL + chqBo.cheque_image)
        
        cell.imgCheque.kf.indicatorType = .activity
        cell.imgCheque.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Loading"),
            options: [.transition(.fade(1))])
        {
            result in
            switch result {
            case .success(let value):
                cell.imgCheque.contentMode = .scaleAspectFill
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        let formatter = DateFormatter()
        if chqBo.uploadedDate != ""
        {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.date(from: chqBo.uploadedDate)
            formatter.dateFormat = "dd MMM, yyyy"
            let strDate = formatter.string(from: date!)
            cell.lblUploadedDate.text = strDate
        }
        cell.chqBO = chqBo
        cell.callBack = self
        if chqBo.chequeClearanceDate != ""
        {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let clrDate = formatter.date(from: chqBo.chequeClearanceDate)
            formatter.dateFormat = "dd MMM, yyyy"
            let strClrDate = formatter.string(from: clrDate!)
            cell.lblClearanceDate.text = strClrDate
        }
        cell.lblEmpId.text = chqBo.empId
        cell.lblEmpName.text = chqBo.empName
        if TaksyKraftUserDefaults.getUser().role == "admin" && chqBo.status == "pending"
        {
            cell.vwBtnBase.isHidden = false
        }
        else
        {
            cell.vwBtnBase.isHidden = true
        }
        cell.constLblReasonHeight.constant = 0
        cell.lblReason.text = ""
        cell.lblReason.isHidden = true
        let str = "Description :\n" + chqBo.Description
        
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 13))
        cell.lblDesc.attributedText = attributedString

        var descHeight = ("Description :\n" + chqBo.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
        if chqBo.Description == ""
        {
            descHeight = 0
        }
        else
        {
            descHeight = descHeight + 10
        }
        
        cell.constLblDescriptionHeight.constant = descHeight
        cell.lblStatus.text = chqBo.status.capitalized
        cell.btnApprove.layer.cornerRadius = 5
        cell.btnApprove.layer.masksToBounds = true
        
        cell.btnReject.layer.cornerRadius = 5
        cell.btnReject.layer.masksToBounds = true
        cell.btnReject.layer.borderColor = UIColor(red: 112.0/255.0, green: 184.0/255.0, blue: 205.00/255.0, alpha: 1.0).cgColor
        cell.btnReject.layer.borderWidth = 1.0

        if chqBo.status == "pending"
        {
            
            cell.lblStatus.textColor = UIColor(red: 139.0/255.0, green: 87.0/255.0, blue: 42.00/255.0, alpha: 1.0)
        }
        else if chqBo.status == "approved"
        {
            cell.lblStatus.textColor = UIColor(red: 126.0/255.0, green: 211.0/255.0, blue: 33.0/255.0, alpha: 1.0)
        }
        else if chqBo.status == "rejected"
        {
            var reasonHeight = ("Reason :\n" + chqBo.comment).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
            if chqBo.comment == ""
            {
                reasonHeight = 0
            }
            else
            {
                reasonHeight = reasonHeight + 10
            }
            
            cell.constLblReasonHeight.constant = reasonHeight
            let str = "Reason :\n" + chqBo.comment
            
            let attributedString = NSMutableAttributedString(string: str)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 8))
            cell.lblReason.attributedText = attributedString
            
            cell.lblReason.text = "Reason :\n" + chqBo.comment
            cell.lblReason.isHidden = false
            cell.lblStatus.textColor = UIColor(red: 208.0/255.0, green: 2.0/255.0, blue: 27.0/255.0, alpha: 1.0)
        }
        else
        {
            cell.lblStatus.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let bo = arrFilter[indexPath.row]
        var descHeight = ("Description :\n" + bo.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
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
            return 160 + descHeight + resonHeight + 30
        }
        else if bo.status == "pending"
        {
            return 160 + descHeight + 20
        }
        else
        {
            return 160 + descHeight
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension ChequeViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text! + string)
        
        var strSearch = textField.text! + string
        
        if range.location == 0 && range.length == 1
        {
            strSearch = ""
            arrFilter.removeAll()
            arrFilter.append(contentsOf: arrAllList)
        }
        else
        {
            arrFilter = arrAllList.filter({ (chq) -> Bool in
                if chq.chequeId.lowercased().contains(strSearch.lowercased())
                {
                    return true
                }
                return false
            })
        }
        tblCheque.reloadData()
        return true
    }
}
extension ChequeViewController : AllChequesTableViewCellDelegate
{
    func btnRejectClicked(chqId : String,cell : AllChequesTableViewCell)
    {
        if let popup = Bundle.main.loadNibNamed("RejectPopup", owner: nil, options: nil)![0] as? RejectPopup
        {
            self.rejChqID = chqId
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
    @objc func btnCancelClicked(sender : UIButton)
    {
        rejectPopup.removeFromSuperview()
    }
    
    @objc func btnRejectConfirmClicked(sender : UIButton)
    {
        if rejectPopup.txtVwResaon.text == ""
        {
            rejectPopup.constLblReasonAlertHeight.constant = 20
        }
        else
        {
            rejectPopup.constLblReasonAlertHeight.constant = 0
            self.updateStatusWith(id: self.rejChqID, status: "rejected")
        }
    }
    func btnApproveClicked(chqId : String,cell : AllChequesTableViewCell)
    {
        self.updateStatusWith(id: chqId, status: "approved")
    }
    func btnImgClicked(chqBO : ChequeBO,cell : AllChequesTableViewCell)
    {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        vc.arrUrl = [chqBO.cheque_image]
        vc.arrUrl.append(contentsOf: chqBO.invoice_image)
        vc.isEdit = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func updateStatusWith(id : String,status:String)
    {
        app_delegate.showLoader(message: "updating....")
        var comment = ""
        if status == "rejected"
        {
            comment = rejectPopup.txtVwResaon.text!
        }
        let layer = ServiceLayer()
        layer.updateStatusOfChequeWith(strID: id, strStatus: status, strComment: comment, successMessage: { (response) in
            DispatchQueue.main.async {
                app_delegate.removeloder()
                if self.rejectPopup != nil
                {
                    self.rejectPopup.removeFromSuperview()
                }
                let alert = UIAlertController(title: "Success!", message: "Cheque Updated Successfully.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                        if TaksyKraftUserDefaults.getUser().role == "hr"
                        {
                            self.callForMyChequesData()
                            
                        }
                        else
                        {
                            self.callForAllChequesData()
                        }
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
