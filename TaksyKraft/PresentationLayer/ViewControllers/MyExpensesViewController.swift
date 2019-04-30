//
//  MyExpensesViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 07/06/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit

class MyExpensesViewController: BaseViewController {
    let Tag_Reupload = 1000
    let Tag_Delete = 2000

    @IBOutlet weak var tblExpenses: UITableView!
    @IBOutlet weak var txtFldSearch: UITextField!
    var arrMyList = [ReceiptBO]()
    var arrFilter = [ReceiptBO]()
    
    var rejectPopup : RejectPopup!
    var rejExpenseID = ""
    var strTitle = ""
   @IBOutlet weak var lblNoDataFound: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callForData()
        txtFldSearch.leftViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: txtFldSearch.frame.size.width/2 - 20, y: 0, width: 40, height: 20))
        imageView.image = #imageLiteral(resourceName: "Search")
        imageView.contentMode = .scaleAspectFit
        txtFldSearch.leftView = imageView
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadSuccess(not:)), name: Notification.Name("reloadExpense"), object: nil)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: strTitle, showBack: true, isRefresh: true)
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
    @IBAction func btnAddClicked(_ sender: UIButton) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExpenseViewController") as! CreateExpenseViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @objc func uploadSuccess(not : NSNotification)
    {
        self.callForData()
        let serviceLayer = ServiceLayer()
        serviceLayer.getMyExpenses(successMessage: { (response) in
            self.arrMyList.removeAll()
            self.arrMyList = response as! [ReceiptBO]
            
        }) { (failure) in
            
        }
        
        
    }
    func callForData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        let serviceLayer = ServiceLayer()
        serviceLayer.getMyExpenses(successMessage: { (response) in
            app_delegate.removeloder()
            
            let arrResponse = response as! [ReceiptBO]
            
            let arrPending = arrResponse.filter({ (exp) -> Bool in
                if exp.status.lowercased() == "pending"
                {
                    return true
                }
                return false
            })
            let arrPaid = arrResponse.filter({ (exp) -> Bool in
                if exp.status.lowercased() == "paid"
                {
                    return true
                }
                return false
            })
            let arrVerified = arrResponse.filter({ (exp) -> Bool in
                if exp.status.lowercased() == "verified"
                {
                    return true
                }
                return false
            })
            let arrApproved = arrResponse.filter({ (exp) -> Bool in
                if exp.status.lowercased() == "approved"
                {
                    return true
                }
                return false
            })
            let arrRejected = arrResponse.filter({ (exp) -> Bool in
                if exp.status.lowercased() == "rejected"
                {
                    return true
                }
                return false
            })

            self.arrMyList.removeAll()

            if self.strTitle.lowercased() == "pending"
            {
                self.arrMyList.append(contentsOf: arrPending)
            }
            else if self.strTitle.lowercased() == "paid"
            {
                self.arrMyList.append(contentsOf: arrPaid)
            }
            else if self.strTitle.lowercased() == "verified"
            {
                self.arrMyList.append(contentsOf: arrVerified)
            }
            else if self.strTitle.lowercased() == "approved"
            {
                self.arrMyList.append(contentsOf: arrApproved)
            }
            else if self.strTitle.lowercased() == "rejected"
            {
                self.arrMyList.append(contentsOf: arrRejected)
            }

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
                    self.showAlertWith(title: "Alert!", message: failure as! String)
                }
            }
        }
    }

    override func btnRefreshClicked( sender:UIButton)
    {
        self.callForData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension MyExpensesViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "MyExpensesTableViewCell", for: indexPath)  as! MyExpensesTableViewCell
                let expense = arrFilter[indexPath.row]
                cell.lblExpenseID.text = expense.expenseId
                cell.lblAmount.text = "₹" + expense.amount
                cell.lblDescription.text = expense.Description
                if expense.uploadedDate != ""
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = formatter.date(from: expense.uploadedDate)
                    formatter.dateFormat = "dd MMM, yyyy"
                    let strDate = formatter.string(from: date!)
                    
                    cell.lblUploadedDate.text = strDate
                }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
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
//                    let url = URL(string: "https://s3-ap-southeast-1.amazonaws.com/taksykraft/approved/content/RQTMnHuLYxvPczyCXao2PMHXLultSF7IehMfXh2dia4BI1kHeQ7NlycFxAX5.mp4")
                    cell.imgVwExpense.kf.indicatorType = .activity
                    cell.imgVwExpense.kf.setImage(
                        with: url,
                        placeholder: UIImage(named: "Loading"),
                        options: [.transition(.fade(1))])
                    {
                        result in
                        switch result {
                        case .success(let value):
                            print("Task done for: \(value.source.url?.absoluteString ?? "")")
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                        }
                    }
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
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 13))
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
                }
                else if expense.status == "paid"
                {
                    cell.btnReupload.isHidden = true
                    cell.btnDelete.isHidden = true
                    cell.vwBtnBase.isHidden = true
                    cell.constVwBtnBaseHeight.constant = 0
                }
                else if expense.status == "verified"
                {
                    cell.btnReupload.isHidden = true
                    cell.btnDelete.isHidden = true
                    cell.vwBtnBase.isHidden = true
                    cell.constVwBtnBaseHeight.constant = 0
                }
                else if expense.status == "approved"
                {
                    cell.btnReupload.isHidden = true
                    cell.btnDelete.isHidden = true
                    cell.vwBtnBase.isHidden = true
                    cell.constVwBtnBaseHeight.constant = 0
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
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 8))
                    cell.lblReason.attributedText = attributedString
                    
                    cell.lblReason.text = "Reason :\n" + expense.comment
                    
                    cell.lblReason.isHidden = false
                }
                else
                {
                    cell.btnReupload.isHidden = true
                    cell.btnDelete.isHidden = true
                    cell.vwBtnBase.isHidden = true
                    cell.constVwBtnBaseHeight.constant = 0
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func updateStatusWith(strStatus : String,expenseID : String,cell:AllExpensesTableViewCell)
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
                let alert = UIAlertController(title: "Success!", message: "Expense Updated Successfully.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
                        //                        self.callForData()
                        self.arrMyList.remove(at: (self.tblExpenses.indexPath(for: cell)?.row)!)
                        self.arrFilter.remove(at: (self.tblExpenses.indexPath(for: cell)?.row)!)
                        self.tblExpenses.reloadData()
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
extension MyExpensesViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text! + string)
        
        var strSearch = textField.text! + string
        
        if range.location == 0 && range.length == 1
        {
            strSearch = ""
            arrFilter.removeAll()
            arrFilter.append(contentsOf: self.arrMyList)
        }
        else
        {
            arrFilter = arrMyList.filter({ (exp) -> Bool in
                if exp.expenseId.lowercased().contains(strSearch.lowercased())
                {
                    return true
                }
                return false
            })
        }
        tblExpenses.reloadData()
        return true
    }
}
extension MyExpensesViewController : MyExpensesTableViewCellDelegate
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
        let alert = UIAlertController(title: "Alert!", message: "Do you want to delete this expense?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                app_delegate.showLoader(message: "Deleting Expense...")
                let layer = ServiceLayer()
                layer.deleteExpenseWith(strID: expenseId, successMessage: { (response) in
                    DispatchQueue.main.async {
                        app_delegate.removeloder()
                        let alert = UIAlertController(title: "Success!", message: "Expense deleted Successfully.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            DispatchQueue.main.async {
                                //                                self.callForData()
                                self.arrMyList.remove(at: (self.tblExpenses.indexPath(for: cell)?.row)!)
                                self.arrFilter.remove(at: (self.tblExpenses.indexPath(for: cell)?.row)!)
                                layer.getMyExpenses(successMessage: { (response1) in
                                    
                                    self.arrMyList.removeAll()
                                    self.arrMyList = response1 as! [ReceiptBO]
                                    
                                }, failureMessage: { (failures) in
                                    
                                })
                                self.tblExpenses.reloadData()
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }) { (error) in
                    app_delegate.removeloder()
                    if error as! String == "This Expense Is Rejected, You Can\"t Delete It."
                    {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Alert!", message: error as? String, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { (action) in
                                DispatchQueue.main.async {
                                    self.callForData()
                                    layer.getAllExpenses(successMessage: { (response1) in
                                        
                                        self.arrMyList.removeAll()
                                        self.arrMyList = response1 as! [ReceiptBO]
                                        
                                    }, failureMessage: { (failures) in
                                        
                                    })
                                    
                                }
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        
                    }
                    else
                    {
                        self.showAlertWith(title: "Alert!", message: error as! String)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
