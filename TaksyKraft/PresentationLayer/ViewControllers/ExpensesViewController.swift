//
//  ExpensesViewController.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
import Charts

let IMAGE_BASE_URL = "https://taksykraft.s3.ap-southeast-1.amazonaws.com/tk-exp-new/"
protocol ExpensesViewControllerDelegate
{
    func uploadSuccess()
}

class ExpensesViewController: BaseViewController, UIPopoverPresentationControllerDelegate {

    let Tag_Reupload = 1000
    let Tag_Delete = 2000
    let Tag_Approve = 3000
    let Tag_Verify = 4000
    let Tag_Reject = 5000
    let Tag_PayNow = 6000
    var isMyExpense = false
    var callback : ExpensesViewControllerDelegate!

    @IBOutlet weak var vwChartBase: UIView!
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var tblChart: UITableView!
    
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
    let arrStatus = ["Pending","Paid","Verified","Approved","Rejected"]
    var arrValues = [Double]()
    let arrColors = [UIColor(red: 139.0/255.0, green: 87.0/255.0, blue: 42.00/255.0, alpha: 1.0),UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 1.0),UIColor(red: 245.0/255.0, green: 166.0/255.0, blue: 35.0/255.0, alpha: 1.0),UIColor(red: 126.0/255.0, green: 211.0/255.0, blue: 33.0/255.0, alpha: 1.0),UIColor(red: 208.0/255.0, green: 2.0/255.0, blue: 27.0/255.0, alpha: 1.0)]
    var isFromNotification = false
    var json : AnyObject!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tblExpenses.register(UINib(nibName: "ExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "ExpensesTableViewCell")
        self.isMyExpense = true
        self.btnSwitch.selectedSegmentIndex = 0

        if TaksyKraftUserDefaults.getUser().role == "hr" || TaksyKraftUserDefaults.getUser().role == "employee"
        {
            constBtnSwitchHeight.constant = 0
            btnSwitch.isHidden = true
            if isFromNotification
            {
                self.isMyExpense = true
                self.btnSwitch.selectedSegmentIndex = 0

            }

        }
        else
        {
            constBtnSwitchHeight.constant = 30
            btnSwitch.isHidden = false
            if isFromNotification
            {
                self.isMyExpense = false
                self.btnSwitch.selectedSegmentIndex = 1

            }

        }
        self.callForData()
        txtFldSearch.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: txtFldSearch.frame.size.width/2 - 20, y: 0, width: 40, height: 20))
        imageView.image = #imageLiteral(resourceName: "Search")
        imageView.contentMode = .scaleAspectFit
        txtFldSearch.leftView = imageView
        NotificationCenter.default.addObserver(self, selector: #selector(self.uploadSuccess(not:)), name: Notification.Name("reloadExpense"), object: nil)

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Expenses", showBack: true, isRefresh: true)


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
                self.loadChartView()
            }
            else
            {
                self.callForData()
            }
            self.vwChartBase.isHidden = false
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
            self.vwChartBase.isHidden = true
        }
    }
    @IBAction func btnAddClicked(_ sender: UIButton) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExpenseViewController") as! CreateExpenseViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func uploadSuccess(not : NSNotification)
    {
        self.callForData()
        let serviceLayer = ServiceLayer()
        if isMyExpense
        {
            serviceLayer.getAllExpenses(successMessage: { (response) in
                self.arrAllList.removeAll()
                self.arrAllList = response as! [ReceiptBO]

            }, failureMessage: { (failure) in
                
            })
        }
        else
        {
            
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
                        //Manipulate data to show chart
                        let arrPending = self.arrMyList.filter({ (exp) -> Bool in
                            if exp.status.lowercased() == "pending"
                            {
                                return true
                            }
                            return false
                        })
                        let arrPaid = self.arrMyList.filter({ (exp) -> Bool in
                            if exp.status.lowercased() == "paid"
                            {
                                return true
                            }
                            return false
                        })
                        let arrVerified = self.arrMyList.filter({ (exp) -> Bool in
                            if exp.status.lowercased() == "verified"
                            {
                                return true
                            }
                            return false
                        })
                        let arrApproved = self.arrMyList.filter({ (exp) -> Bool in
                            if exp.status.lowercased() == "approved"
                            {
                                return true
                            }
                            return false
                        })
                        let arrRejected = self.arrMyList.filter({ (exp) -> Bool in
                            if exp.status.lowercased() == "rejected"
                            {
                                return true
                            }
                            return false
                        })
                        
                        var val = 0.0
                        for exp in arrPending
                        {
                            val = val + Double(exp.amount)!
                        }
                        self.arrValues.append(val)
                        val = 0.0
                        
                        for exp in arrPaid
                        {
                            val = val + Double(exp.amount)!
                        }
                        self.arrValues.append(val)
                        val = 0.0
                        
                        for exp in arrVerified
                        {
                            val = val + Double(exp.amount)!
                        }
                        self.arrValues.append(val)
                        val = 0.0
                        
                        for exp in arrApproved
                        {
                            val = val + Double(exp.amount)!
                        }
                        self.arrValues.append(val)
                        val = 0.0
                        
                        for exp in arrRejected
                        {
                            val = val + Double(exp.amount)!
                        }
                        self.arrValues.append(val)
                        self.loadChartView()
                        self.lblNoDataFound.isHidden = true
                    }
                    else
                    {
                        //                    self.tblExpenses.isHidden = true
                        self.lblNoDataFound.isHidden = false
                    }
                }
            }) { (failure) in
                
            }
        }
        
        
    }
    func reloadVCForNotification()
    {
        self.isMyExpense = true
        self.btnSwitch.selectedSegmentIndex = 0
        
        if TaksyKraftUserDefaults.getUser().role == "hr" || TaksyKraftUserDefaults.getUser().role == "employee"
        {
            constBtnSwitchHeight.constant = 0
            btnSwitch.isHidden = true
            if isFromNotification
            {
                self.isMyExpense = true
                self.btnSwitch.selectedSegmentIndex = 0
                
            }
            
        }
        else
        {
            constBtnSwitchHeight.constant = 30
            btnSwitch.isHidden = false
            if isFromNotification
            {
                self.isMyExpense = false
                self.btnSwitch.selectedSegmentIndex = 1
                
            }
            
        }

        self.callForData()
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
                            let arrTemp = self.arrAllList.filter({ (exp) -> Bool in
                                if exp.expenseId.lowercased().contains(str.lowercased())
                                {
                                    return true
                                }
                                return false
                            })
                            let arrTemp1 = self.arrAllList.filter({ (exp) -> Bool in
                                if exp.empName.lowercased().contains(str.lowercased())
                                {
                                    return true
                                }
                                return false
                            })
                            self.arrFilter.append(contentsOf: arrTemp)
                            self.arrFilter.append(contentsOf: arrTemp1)

                        }
                    }
                    else
                    {
                        self.arrFilter.append(contentsOf: self.arrAllList)
                    }


                    self.tblExpenses.reloadData()
                    self.lblNoDataFound.isHidden = true
                    self.tblExpenses.isHidden = false
                    if self.isFromNotification
                    {
                        let rec = self.arrFilter.filter({ (receipt) -> Bool in
                            return receipt.expenseId == self.json["expensesId"] as! String
                        })
                        if rec.count > 0
                        {
                            let index = self.arrFilter.index(of: rec[0])
                            self.tblExpenses.scrollToRow(at: IndexPath(row: index!, section: 0), at: .top, animated: false)
                        }
                        self.isFromNotification = false                                                
                        self.btnSwitchClicked(self.btnSwitch)
                    }

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
                    //Manipulate data to show chart
                    let arrPending = self.arrMyList.filter({ (exp) -> Bool in
                        if exp.status.lowercased() == "pending"
                        {
                            return true
                        }
                        return false
                    })
                    let arrPaid = self.arrMyList.filter({ (exp) -> Bool in
                        if exp.status.lowercased() == "paid"
                        {
                            return true
                        }
                        return false
                    })
                    let arrVerified = self.arrMyList.filter({ (exp) -> Bool in
                        if exp.status.lowercased() == "verified"
                        {
                            return true
                        }
                        return false
                    })
                    let arrApproved = self.arrMyList.filter({ (exp) -> Bool in
                        if exp.status.lowercased() == "approved"
                        {
                            return true
                        }
                        return false
                    })
                    let arrRejected = self.arrMyList.filter({ (exp) -> Bool in
                        if exp.status.lowercased() == "rejected"
                        {
                            return true
                        }
                        return false
                    })
                    self.arrValues.removeAll()
                    var val = 0.0
                    for exp in arrPending
                    {
                        val = val + Double(exp.amount)!
                    }
                    self.arrValues.append(val)
                    val = 0.0
                    
                    for exp in arrPaid
                    {
                        val = val + Double(exp.amount)!
                    }
                    self.arrValues.append(val)
                    val = 0.0
                    
                    for exp in arrVerified
                    {
                        val = val + Double(exp.amount)!
                    }
                    self.arrValues.append(val)
                    val = 0.0
                    
                    for exp in arrApproved
                    {
                        val = val + Double(exp.amount)!
                    }
                    self.arrValues.append(val)
                    val = 0.0
                    
                    for exp in arrRejected
                    {
                        val = val + Double(exp.amount)!
                    }
                    self.arrValues.append(val)
                    self.loadChartView()
                    self.lblNoDataFound.isHidden = true
                }
                else
                {
//                    self.tblExpenses.isHidden = true
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
    func loadChartView()
    {
        var dataEntries: [PieChartDataEntry] = []
        
        for i in 0..<arrStatus.count {
            let dataEntry = PieChartDataEntry(value: Double(arrValues[i]), label: arrStatus[i])
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        pieChartDataSet.drawValuesEnabled = false
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        chartView.data = pieChartData
        chartView.drawEntryLabelsEnabled = false
        chartView.delegate = self
        
        pieChartDataSet.colors = arrColors
        pieChartDataSet.sliceSpace = 1.0
        chartView.animate(xAxisDuration: 1, easingOption: .easeOutBack)
        
        chartView.drawSlicesUnderHoleEnabled = false;
        chartView.holeRadiusPercent = 0.7;
        chartView.transparentCircleRadiusPercent = 0
        chartView.chartDescription?.enabled = false
        chartView.setExtraOffsets(left: 5.0, top: 10.0, right: 5.0, bottom: 5.0)
        chartView.drawCenterTextEnabled = true
        chartView.legend.enabled = false
        
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        var total = 0.0
        
        for val in arrValues
        {
            total = total + val
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: total))

        let centerText = NSMutableAttributedString(string: "Total\n₹ \(formattedNumber ?? "")")
        centerText.setAttributes([NSFontAttributeName : UIFont(name: "Roboto-Light", size: 15)!,
                                  NSParagraphStyleAttributeName : paragraphStyle], range: NSRange(location: 0, length: 5))
        centerText.addAttributes([NSFontAttributeName : UIFont(name: "Roboto-Medium", size: 17)!,
                                  NSForegroundColorAttributeName : UIColor.black], range: NSRange(location: 6, length: centerText.length - 6))
        centerText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: centerText.length))
        chartView.centerAttributedText = centerText;
        tblChart.reloadData()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}

extension ExpensesViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblChart
        {
            return arrValues.count
        }
        else
        {
            return arrFilter.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if isMyExpense
            {
                let cell  = tableView.dequeueReusableCell(withIdentifier: "ChartTableViewCell", for: indexPath)  as! ChartTableViewCell
                cell.lblStatus.text = arrStatus[indexPath.row]
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let formattedNumber = numberFormatter.string(from: NSNumber(value: arrValues[indexPath.row]))

                cell.lblValue.text = formattedNumber
                
                
                if arrValues[indexPath.row] == Double(0.0)
                {
                    cell.btnViewBills.layer.cornerRadius = 5.0
                    cell.btnViewBills.layer.masksToBounds = true
                    
                    cell.btnViewBills.layer.borderColor = UIColor.lightGray.cgColor
                    cell.btnViewBills.layer.borderWidth = 0.5
                    
                    cell.btnViewBills.setTitleColor(UIColor.lightGray, for: .normal)
                }
                else
                {
                    cell.btnViewBills.layer.cornerRadius = 5.0
                    cell.btnViewBills.layer.masksToBounds = true
                    
                    cell.btnViewBills.layer.borderColor = UIColor(red: 60.0/255.0, green: 130.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
                    cell.btnViewBills.layer.borderWidth = 0.5
                    
                    cell.btnViewBills.setTitleColor(UIColor(red: 60.0/255.0, green: 130.0/255.0, blue: 184.0/255.0, alpha: 1.0), for: .normal)
                    cell.btnViewBills.tag = 5000 + indexPath.row
                    cell.btnViewBills.addTarget(self, action: #selector(self.btnViewBillsClicked(_:)), for: .touchUpInside)
                }
                
                cell.imgStatusColor.backgroundColor = arrColors[indexPath.row]
                
                if indexPath.row%2 == 0
                {
                    cell.backgroundColor = UIColor.white
                }
                else
                {
                    cell.backgroundColor = UIColor.clear
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
                if expense.uploadedDate != ""
                {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = formatter.date(from: expense.uploadedDate)
                    formatter.dateFormat = "dd MMM, yyyy"
                    let strDate = formatter.string(from: date!)
                    cell.lblUploadedDate.text = strDate
                }
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
                return 54
            }
            else
            {
                return 180
            }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @objc func btnViewBillsClicked(_ sender: UIButton)
    {
        let index = sender.tag - 5000
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyExpensesViewController") as! MyExpensesViewController
        vc.strTitle = arrStatus[index]
        self.navigationController?.pushViewController(vc, animated: true)

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
                let alert = UIAlertController(title: "Success!", message: "Expense Updated Successfully.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    DispatchQueue.main.async {
//                        self.callForData()
                        self.arrAllList.remove(at: (self.tblExpenses.indexPath(for: cell)?.row)!)
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
extension ExpensesViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text! + string)
        
        let strSearch = textField.text! + string
        arrFilter.removeAll()
        if range.location == 0 && range.length == 1
        {
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
                tblChart.reloadData()
            }
            else
            {
                let arrTemp = arrAllList.filter({ (exp) -> Bool in
                    if exp.expenseId.lowercased().contains(strSearch.lowercased())
                    {
                        return true
                    }
                    return false
                })
                let arrTemp1 = arrAllList.filter({ (exp) -> Bool in
                    if exp.empName.lowercased().contains(strSearch.lowercased())
                    {
                        return true
                    }
                    return false
                })
                arrFilter.append(contentsOf: arrTemp)
                arrFilter.append(contentsOf: arrTemp1)
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
            rejectPopup.cell = cell
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
            self.updateStatusWith(strStatus: "rejected", expenseID: self.rejExpenseID, cell: rejectPopup.cell)
        }
    }
    func btnApproveClicked(expenseId : String,cell : AllExpensesTableViewCell)
    {
        self.updateStatusWith(strStatus: "approved", expenseID: expenseId, cell: cell)
    }
    func btnVerifyClicked(expenseId : String,cell : AllExpensesTableViewCell)
    {
        self.updateStatusWith(strStatus: "verified", expenseID: expenseId, cell: cell)
    }
    func btnPayNowClicked(expenseId : String,cell : AllExpensesTableViewCell)
    {
        self.updateStatusWith(strStatus: "paid", expenseID: expenseId, cell: cell)
    }

}
extension ExpensesViewController : ChartViewDelegate
{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                DispatchQueue.main.async {
                    chartView.highlightValue(nil)
                }
            }
        } else {
            // Fallback on earlier versions
        }
        let str =  (entry as! PieChartDataEntry).label ?? ""
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyExpensesViewController") as! MyExpensesViewController
        vc.strTitle = str
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
}

