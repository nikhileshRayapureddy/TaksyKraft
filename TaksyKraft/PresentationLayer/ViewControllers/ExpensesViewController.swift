//
//  ExpensesViewController.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
let IMAGE_BASE_URL = "https://taksykraft.s3.ap-southeast-1.amazonaws.com/tk-exp-new/"
class ExpensesViewController: BaseViewController, UIPopoverPresentationControllerDelegate {

    let Tag_Reupload = 1000
    let Tag_Delete = 2000
    let Tag_Approve = 3000
    let Tag_Verify = 4000
    let Tag_Reject = 5000
    let Tag_PayNow = 6000
    var isMyExpense = false
    @IBOutlet weak var tblExpenses: UITableView!
    @IBOutlet weak var constBtnSwitchHeight: NSLayoutConstraint!
    
    @IBOutlet weak var txtFldSearch: UITextField!
    var arrMyList = [ReceiptBO]()
    var arrAllList = [ReceiptBO]()

    var arrFilter = [ReceiptBO]()
    var rejectPopup : RejectPopup!
    var rejExpenseID = ""
    @IBOutlet weak var btnSwitch: UISegmentedControl!
    @IBOutlet weak var lblNoDataFound: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tblExpenses.register(UINib(nibName: "ExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "ExpensesTableViewCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Expenses", showBack: true, isRefresh: true)
        if TaksyKraftUserDefaults.getUser().role == "hr" || TaksyKraftUserDefaults.getUser().role == "employee"
        {
            constBtnSwitchHeight.constant = 0
            btnSwitch.isHidden = true
        }
        else
        {
            constBtnSwitchHeight.constant = 30
            btnSwitch.isHidden = false
        }
        self.isMyExpense = true
        self.btnSwitch.selectedSegmentIndex = 0
        self.callForData()
        txtFldSearch.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: txtFldSearch.frame.size.width/2 - 20, y: 0, width: 40, height: 20))
        imageView.image = #imageLiteral(resourceName: "Search")
        imageView.contentMode = .scaleAspectFit
        txtFldSearch.leftView = imageView


    }
    override func btnRefreshClicked( sender:UIButton)
    {
        self.callForData()
    }
    @IBAction func btnSwitchClicked(_ sender: UISegmentedControl) {
        arrFilter.removeAll()
        if sender.selectedSegmentIndex == 0
        {
            isMyExpense = true
            if arrMyList.count > 0
            {
                self.tblExpenses.isHidden = false
                self.lblNoDataFound.isHidden = true
                arrFilter.append(contentsOf: arrMyList)
                tblExpenses.reloadData()
            }
            else
            {
                self.callForData()
            }
        }
        else
        {
            isMyExpense = false
            if arrAllList.count > 0
            {
                self.tblExpenses.isHidden = false
                self.lblNoDataFound.isHidden = true
                arrFilter.append(contentsOf: arrAllList)
                tblExpenses.reloadData()
            }
            else
            {
                self.callForData()
            }

        }
    }
    @IBAction func btnAddClicked(_ sender: UIButton) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExpenseViewController") as! CreateExpenseViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func callForData()
    {
        if isMyExpense
        {
            self.callForMyExpensesData()
        }
        else
        {
            self.callForAllExpensesData()
        }
    }
    func callForAllExpensesData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        let serviceLayer = ServiceLayer()
        serviceLayer.getAllExpenses(successMessage: { (response) in
            app_delegate.removeloder()
            self.arrAllList.removeAll()
            self.arrAllList = response as! [ReceiptBO]
            DispatchQueue.main.async {
                if self.arrAllList.count > 0
                {
                    self.arrFilter.removeAll()
                    if self.txtFldSearch.text != ""
                    {
                        if let str = self.txtFldSearch.text
                        {
                            self.arrFilter = self.arrAllList.filter({ (exp) -> Bool in
                                if exp.expenseId.lowercased().contains(str.lowercased())
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

                    self.tblExpenses.reloadData()
                    self.lblNoDataFound.isHidden = true
                    self.tblExpenses.isHidden = false

                }
                else
                {
                    self.tblExpenses.isHidden = true
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
                self.isMyExpense = true
                self.btnSwitch.selectedSegmentIndex = 0
                self.showAlertWith(title: "Alert!", message: failure as! String)
            }
        }
    }
    func callForMyExpensesData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        let serviceLayer = ServiceLayer()
        serviceLayer.getMyExpenses(successMessage: { (response) in
            app_delegate.removeloder()
            self.arrMyList.removeAll()
            self.arrMyList = response as! [ReceiptBO]
            DispatchQueue.main.async {
                if self.arrMyList.count > 0
                {
                    self.arrFilter.removeAll()
                    if self.txtFldSearch.text != ""
                    {
                        if let str = self.txtFldSearch.text
                        {
                            self.arrFilter = self.arrMyList.filter({ (exp) -> Bool in
                                if exp.expenseId.lowercased().contains(str.lowercased())
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
                    

                    self.tblExpenses.reloadData()
                    self.lblNoDataFound.isHidden = true
                }
                else
                {
                    self.tblExpenses.isHidden = true
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
                    self.isMyExpense = false
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

extension ExpensesViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isMyExpense
        {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "MyExpensesTableViewCell", for: indexPath)  as! MyExpensesTableViewCell
            let expense = arrFilter[indexPath.row]
            cell.lblExpenseID.text = expense.expenseId
            cell.lblAmount.text = "₹" + expense.amount
            cell.lblDescription.text = expense.Description
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.date(from: expense.uploadedDate)
            formatter.dateFormat = "dd MMM, yyyy"
            let strDate = formatter.string(from: date!)
            
            cell.lblUploadedDate.text = strDate
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            cell.lblStatus.text = expense.status.capitalized
            cell.vwBase.layer.cornerRadius = 5
            cell.vwBase.layer.masksToBounds = true
            cell.btnReupload.layer.cornerRadius = 5
            cell.btnReupload.layer.masksToBounds = true
            cell.btnDelete.layer.cornerRadius = 5
            cell.btnDelete.layer.masksToBounds = true
            cell.imgVwExpense.layer.cornerRadius = cell.imgVwExpense.frame.size.width/2
            cell.imgVwExpense.layer.masksToBounds = true
            cell.callBack = self
            cell.expense = expense
            if expense.image == "pzrUPuD8zqdWKaxD7cAfLjptKhNjag5XUckkk3ho.png"
            {
               cell.imgVwExpense.image = #imageLiteral(resourceName: "NoReceipt")
            }
            else
            {
                let url = URL(string: IMAGE_BASE_URL + expense.image)
//                cell.imgVwExpense.kf.indicatorType = .activity
                cell.imgVwExpense.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "Loading"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })
            }
            cell.btnDelete.layer.borderColor = UIColor(red: 60.0/255.0, green: 130.0/255.0, blue: 184.00/255.0, alpha: 1.0).cgColor
            cell.btnDelete.layer.borderWidth = 1.0
            cell.btnReupload.tag = Tag_Reupload + indexPath.row
            cell.btnDelete.tag = Tag_Delete + indexPath.row
            cell.constLblReasonHeight.constant = 0
            cell.lblReason.text = ""
            cell.lblReason.isHidden = true
            let str = "Description :\n" + expense.Description
            
            let attributedString = NSMutableAttributedString(string: str)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 13))
            cell.lblDescription.attributedText = attributedString
            
            var descHeight = ("Description :\n" + expense.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
            if expense.Description == ""
            {
                descHeight = 0
            }
            else
            {
                descHeight = descHeight + 10
            }
            
            cell.constLblDescriptionHeight.constant = descHeight

            if expense.status == "pending"
            {
                cell.btnReupload.isHidden = false
                cell.btnDelete.isHidden = false
                cell.vwBtnBase.isHidden = false
                cell.constVwBtnBaseHeight.constant = 30
                cell.lblStatus.textColor = UIColor(red: 139.0/255.0, green: 87.0/255.0, blue: 42.00/255.0, alpha: 1.0)
            }
            else if expense.status == "paid"
            {
                cell.btnReupload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0
                cell.lblStatus.textColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 1.0)
            }
            else if expense.status == "verified"
            {
                cell.btnReupload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0
                cell.lblStatus.textColor = UIColor(red: 245.0/255.0, green: 166.0/255.0, blue: 35.0/255.0, alpha: 1.0)
            }
            else if expense.status == "approved"
            {
                cell.btnReupload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0
                cell.lblStatus.textColor = UIColor(red: 126.0/255.0, green: 211.0/255.0, blue: 33.0/255.0, alpha: 1.0)
            }
            else if expense.status == "rejected"
            {
                cell.btnReupload.isHidden = false
                cell.btnDelete.isHidden = true
                cell.vwBtnBase.isHidden = false
                cell.constVwBtnBaseHeight.constant = 30
                var reasonHeight = ("Reason :\n" + expense.comment).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if expense.comment == ""
                {
                    reasonHeight = 0
                }
                else
                {
                    reasonHeight = reasonHeight + 10
                }
                
                cell.constLblReasonHeight.constant = reasonHeight
                let str = "Reason :\n" + expense.comment
                
                let attributedString = NSMutableAttributedString(string: str)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 8))
                cell.lblReason.attributedText = attributedString
                
                cell.lblReason.text = "Reason :\n" + expense.comment

                cell.lblReason.isHidden = false
                cell.lblStatus.textColor = UIColor(red: 208.0/255.0, green: 2.0/255.0, blue: 27.0/255.0, alpha: 1.0)
            }
            else
            {
                cell.btnReupload.isHidden = true
                cell.btnDelete.isHidden = true
                cell.lblStatus.isHidden = true
                cell.vwBtnBase.isHidden = true
                cell.constVwBtnBaseHeight.constant = 0
            }
            return cell
        }
        else
        {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "AllExpensesTableViewCell", for: indexPath)  as! AllExpensesTableViewCell
            let expense = arrFilter[indexPath.row]
            cell.lblEmployeeName.text = expense.empName
            cell.lblEmpID.text = expense.empId
            cell.lblExpenseID.text = expense.expenseId
            cell.lblAmount.text = "₹" + expense.amount
            cell.lblDescription.text = expense.Description
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.date(from: expense.uploadedDate)
            formatter.dateFormat = "dd MMM, yyyy"
            let strDate = formatter.string(from: date!)

            cell.lblUploadedDate.text = strDate
            
            cell.vwBase.layer.cornerRadius = 5
            cell.vwBase.layer.masksToBounds = true
            cell.btnVerify.layer.cornerRadius = 5
            cell.btnVerify.layer.masksToBounds = true
            cell.btnApprove.layer.cornerRadius = 5
            cell.btnApprove.layer.masksToBounds = true
            cell.btnPayNow.layer.cornerRadius = 5
            cell.btnPayNow.layer.masksToBounds = true
            cell.btnReject.layer.cornerRadius = 5
            cell.btnReject.layer.masksToBounds = true
            cell.btnReject.layer.borderColor = UIColor(red: 60.0/255.0, green: 130.0/255.0, blue: 184.00/255.0, alpha: 1.0).cgColor
            cell.btnReject.layer.borderWidth = 1.0

            
            cell.btnReject.tag = Tag_Reject + indexPath.row
            cell.btnPayNow.tag = Tag_PayNow + indexPath.row
            cell.btnApprove.tag = Tag_Approve + indexPath.row
            cell.btnVerify.tag = Tag_Verify + indexPath.row
            cell.imgVwExpense.layer.cornerRadius = cell.imgVwExpense.frame.size.width/2
            cell.imgVwExpense.layer.masksToBounds = true
            
            if expense.image == "pzrUPuD8zqdWKaxD7cAfLjptKhNjag5XUckkk3ho.png"
            {
                cell.imgVwExpense.image = #imageLiteral(resourceName: "NoReceipt")
            }
            else
            {
                let url = URL(string: IMAGE_BASE_URL + expense.image)
//                cell.imgVwExpense.kf.indicatorType = .activity
                cell.imgVwExpense.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "Loading"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })
            }
            cell.callback  = self
            cell.expense = expense
            if expense.status == "pending"
            {
                cell.btnVerify.isHidden = false
                cell.btnApprove.isHidden = true
                cell.btnReject.isHidden = false
                cell.btnPayNow.isHidden = true
            }
            else if expense.status == "paid"
            {
                cell.btnVerify.isHidden = true
                cell.btnApprove.isHidden = true
                cell.btnReject.isHidden = true
                cell.btnPayNow.isHidden = true
            }
            else if expense.status == "verified"
            {
                cell.btnVerify.isHidden = true
                cell.btnApprove.isHidden = false
                cell.btnReject.isHidden = false
                cell.btnPayNow.isHidden = true
            }
            else if expense.status == "approved"
            {
                cell.btnVerify.isHidden = true
                cell.btnApprove.isHidden = true
                cell.btnReject.isHidden = true
                cell.btnPayNow.isHidden = false

            }
            else if expense.status == "rejected"
            {
                cell.btnVerify.isHidden = true
                cell.btnApprove.isHidden = true
                cell.btnReject.isHidden = true
                cell.btnPayNow.isHidden = true
            }
            else
            {
                cell.btnVerify.isHidden = true
                cell.btnApprove.isHidden = true
                cell.btnReject.isHidden = true
                cell.btnPayNow.isHidden = true
            }

            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isMyExpense
        {
            let bo = arrFilter[indexPath.row]
            var descHeight = ("Description :\n" + bo.Description).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
            if bo.Description == ""
            {
                descHeight = 0
            }
            if bo.status == "rejected"
            {
                var resonHeight = ("Reason :\n" + bo.comment).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
                if bo.comment == ""
                {
                    resonHeight = 0
                }
                return 140 + descHeight + resonHeight + 20
            }
            else
            {
                return 140 + descHeight  + 10
            }
        }
        else
        {
            return 180
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
        layer.updateStatusOfExpenseWith(strID: expenseID, strStatus: strStatus,strComment :comment,successMessage: { (response) in
            DispatchQueue.main.async {
                app_delegate.removeloder()
                if self.rejectPopup != nil
                {
                    self.rejectPopup.removeFromSuperview()
                }
                let alert = UIAlertController(title: "Success!", message: "Expense Updated Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                        self.callForData()
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
        }) { (error) in
            DispatchQueue.main.async {
                app_delegate.removeloder()
                self.showAlertWith(title: "Alert!", message: error as! String)
            }
        }
        
    }
    
}
extension ExpensesViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text! + string)
        
        var strSearch = textField.text! + string
        
        if range.location == 0 && range.length == 1
        {
            strSearch = ""
            arrFilter.removeAll()
            if isMyExpense
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
            if isMyExpense
            {
                arrFilter = arrMyList.filter({ (exp) -> Bool in
                    if exp.expenseId.lowercased().contains(strSearch.lowercased())
                    {
                        return true
                    }
                    return false
                })
            }
            else
            {
                arrFilter = arrAllList.filter({ (exp) -> Bool in
                    if exp.expenseId.lowercased().contains(strSearch.lowercased())
                    {
                        return true
                    }
                    return false
                })
            }
        }
        tblExpenses.reloadData()
        return true
    }
}
extension ExpensesViewController : AllExpensesTableViewCellDelegate
{
    func imgVwClicked(expense: ReceiptBO, cell: AllExpensesTableViewCell) {
        if expense.image != "pzrUPuD8zqdWKaxD7cAfLjptKhNjag5XUckkk3ho.png"
        {
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
            vc.arrUrl = [expense.image]
            vc.isEdit = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func btnRejectClicked(expenseId : String,cell : AllExpensesTableViewCell)
    {
        if let popup = Bundle.main.loadNibNamed("RejectPopup", owner: nil, options: nil)![0] as? RejectPopup
        {
            self.rejExpenseID = expenseId
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
            self.updateStatusWith(strStatus: "rejected", expenseID: self.rejExpenseID)
        }
    }
    func btnApproveClicked(expenseId : String,cell : AllExpensesTableViewCell)
    {
        self.updateStatusWith(strStatus: "approved", expenseID: expenseId)
    }
    func btnVerifyClicked(expenseId : String,cell : AllExpensesTableViewCell)
    {
        self.updateStatusWith(strStatus: "verified", expenseID: expenseId)
    }
    func btnPayNowClicked(expenseId : String,cell : AllExpensesTableViewCell)
    {
        self.updateStatusWith(strStatus: "paid", expenseID: expenseId)
    }

}
extension ExpensesViewController : MyExpensesTableViewCellDelegate
{
    
    func myExpImgVwClicked(expense : ReceiptBO,cell : MyExpensesTableViewCell) {
        
        if expense.image != "pzrUPuD8zqdWKaxD7cAfLjptKhNjag5XUckkk3ho.png"
        {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        vc.arrUrl = [expense.image]
        vc.isEdit = false
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func btnReuploadClicked(expense : ReceiptBO,cell : MyExpensesTableViewCell)
    {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExpenseViewController") as! CreateExpenseViewController
        vc.expenseBO = expense
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func btnDeleteClicked(expenseId : String,cell : MyExpensesTableViewCell)
    {
        let alert = UIAlertController(title: "Alert!", message: "Do you want to delete this expense?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                app_delegate.showLoader(message: "Deleting Expense...")
                let layer = ServiceLayer()
                layer.deleteExpenseWith(strID: expenseId, successMessage: { (response) in
                    DispatchQueue.main.async {
                        app_delegate.removeloder()
                        let alert = UIAlertController(title: "Success!", message: "Expense deleted Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            DispatchQueue.main.async {
                                self.callForData()
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }) { (error) in
                    app_delegate.removeloder()
                    self.showAlertWith(title: "Alert!", message: error as! String)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }

}

