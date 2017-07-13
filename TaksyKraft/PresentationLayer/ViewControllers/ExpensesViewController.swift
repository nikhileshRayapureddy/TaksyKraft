//
//  ExpensesViewController.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
let IMAGE_BASE_URL = "https://s3-ap-southeast-1.amazonaws.com/taksykraft/bills/"
class ExpensesViewController: BaseViewController, UIPopoverPresentationControllerDelegate {

    var isMyExpense = false
    var isFromExpenses = false
    @IBOutlet weak var tblExpenses: UITableView!
    @IBOutlet weak var vwHeader: UIView!
    var arrList = [ReceiptBO]()
    var arrTitles = [String]()
    var imgBg = UIImageView()
    var fortVw : ImageDetailPopUp!
    var rejectPopup : RejectPopup!

    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var constVwHeaderHeight: NSLayoutConstraint!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tblExpenses.register(UINib(nibName: "MyExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "MyExpensesTableViewCell")
        if isMyExpense
        {
            arrTitles = ["Upload New Expenses","My Expenses","Logout"]
        }
        else
        {
            arrTitles = ["Upload New Expenses","Logout"]
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callForData()
    }
    func callForData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        if isFromExpenses
        {
            constVwHeaderHeight.constant = 0
            vwHeader.isHidden = true
            self.designNavBarWithTitleAndBack(title: "My Expenses",showBack: true)
            let serviceLayer = ServiceLayer()
            serviceLayer.getBillHistoryWith(mobileNo: TaksyKraftUserDefaults.getUserMobile(), successMessage: { (response) in
                app_delegate.removeloder()
                self.arrList = response as! [ReceiptBO]
                DispatchQueue.main.async {
                    self.tblExpenses.reloadData()
                    self.tblExpenses.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
            }) { (failure) in
                app_delegate.removeloder()
                self.showAlertWith(title: "Alert!", message: failure as! String)
            }
        }
        else
        {
            constVwHeaderHeight.constant = 50
            vwHeader.isHidden = false
            self.navigationController?.isNavigationBarHidden = true
            let serviceLayer = ServiceLayer()
            if isMyExpense == false
            {
                serviceLayer.getBillHistoryWith(mobileNo: TaksyKraftUserDefaults.getUserMobile(), successMessage: { (response) in
                    app_delegate.removeloder()
                    self.arrList = response as! [ReceiptBO]
                    DispatchQueue.main.async {
                        self.tblExpenses.reloadData()
                        self.tblExpenses.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    }
                }) { (failure) in
                    app_delegate.removeloder()
                    self.showAlertWith(title: "Alert!", message: failure as! String)
                }

            }
            else
            {
                serviceLayer.getBillDetailsWith(mobileNo: TaksyKraftUserDefaults.getUserMobile(), successMessage: { (response) in
                    app_delegate.removeloder()
                    self.arrList = response as! [ReceiptBO]
                    DispatchQueue.main.async {
                        self.tblExpenses.reloadData()
                    }
                }) { (failure) in
                    app_delegate.removeloder()
                    self.showAlertWith(title: "Alert!", message: failure as! String)
                }

            }
        }

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func btnMenuClicked(_ sender: UIButton) {
        self.showPopOver(arrTitles: arrTitles, sender: sender ,tag:500)

    }
    func showPopOver(arrTitles : [String] ,sender : UIView ,tag : Int)  {
        imgBg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        imgBg.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(imgBg)
        
        let popoverVC = CustomPopOver()
        popoverVC.tag = tag
        popoverVC.modalPresentationStyle = .popover
        popoverVC.titles = arrTitles
        popoverVC.preferredContentSize = CGSize (width: 150, height: CGFloat(popoverVC.titles.count) * 45.0)
        popoverVC.delegate = self
        
        if let popoverController = popoverVC.popoverPresentationController
        {
            popoverController.sourceView = sender
            let bound = sender.bounds
            popoverController.sourceRect = bound
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
        }
        
        self.present(popoverVC, animated: true, completion: nil)
        
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController)
    {
        imgBg.removeFromSuperview()
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .none
    }

}
extension ExpensesViewController : popoverGeneralDelegate {
    func selectedText(selectedText: String, popoverselected: Int, tag: Int) {
        if selectedText == "Logout"
        {
            imgBg.removeFromSuperview()
            TaksyKraftUserDefaults.setLoginStatus(object: false)
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            app_delegate.navCtrl = UINavigationController(rootViewController: vc)
            app_delegate.navCtrl.isNavigationBarHidden = true
            app_delegate.window?.rootViewController = app_delegate.navCtrl

        }
        else if selectedText == "Upload New Expenses"
        {
            imgBg.removeFromSuperview()
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExpenseViewController") as! CreateExpenseViewController
            self.navigationController?.pushViewController(vc, animated: true)

        }
        else
        {
            imgBg.removeFromSuperview()
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
            vc.isFromExpenses = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ExpensesViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MyExpensesTableViewCell", for: indexPath)  as! MyExpensesTableViewCell
        let bo = arrList[indexPath.row]
        
        cell.lblName.text = bo.name
        cell.lblDesc.text = bo.Description
        cell.lblTktNo .text = bo.receiptId
        cell.lblPrice.text = bo.amount
        let df  = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(identifier: "UTC")
        let date = df.date(from: bo.created_at)
        df.dateFormat = "dd-MM-yyyy"
        cell.lblDate.text = df.string(from: date!)
        cell.imgVwItem.layer.borderWidth = 1
        cell.imgVwItem.layer.borderColor = UIColor.lightGray.cgColor
        let url = URL(string:IMAGE_BASE_URL + bo.image)
        cell.imgVwItem.kf.indicatorType = .activity
        cell.imgVwItem.kf.setImage(with: url ,
                                   placeholder: nil,
                                   options: [.transition(ImageTransition.fade(1))],
                                   progressBlock: { receivedSize, totalSize in
        },
                                   completionHandler: { image, error, cacheType, imageURL in
        })
        
        cell.lblStatus.text = bo.status_message
        cell.lblStatus.textColor = UIColor(red: 250.0/255.0, green: 186.0/255.0, blue: 51.0/255.0, alpha: 1)
    
        
        if isFromExpenses == false
        {
            if isMyExpense
            {
                cell.constLblNameHeight.constant = 20
                cell.lblStatus.isHidden = true
                cell.lblStatusText.isHidden = true
                cell.btnReject.isHidden = false
                cell.btnApprove.isHidden = false
                cell.btnReject.tag = 1500 + indexPath.row
                cell.btnApprove.tag = 2500 + indexPath.row
                cell.btnReject.isHidden = false

                if TaksyKraftUserDefaults.getUserRole() == "1"
                {
                    if bo.status == "1"
                    {
                        cell.btnReject.setTitle("REJECT", for: .normal)
                        cell.btnReject.setTitle("REJECT", for: .selected)
                        cell.btnReject.setTitle("REJECT", for: .highlighted)
                        cell.btnReject.addTarget(self, action: #selector(self.btnRejectClicked(sender:)), for: .touchUpInside)
                        
                        cell.btnApprove.setTitle("APPROVE", for: .normal)
                        cell.btnApprove.setTitle("APPROVE", for: .selected)
                        cell.btnApprove.setTitle("APPROVE", for: .highlighted)
                        cell.btnApprove.addTarget(self, action: #selector(self.btnApproveClicked(sender:)), for: .touchUpInside)
                    }
                }
                else if TaksyKraftUserDefaults.getUserRole() == "2"
                {
                    if bo.status == "0"
                    {
                        cell.btnReject.setTitle("REJECT", for: .normal)
                        cell.btnReject.setTitle("REJECT", for: .selected)
                        cell.btnReject.setTitle("REJECT", for: .highlighted)
                        cell.btnReject.addTarget(self, action: #selector(self.btnRejectClicked(sender:)), for: .touchUpInside)
                        
                        cell.btnApprove.setTitle("VALIDATE", for: .normal)
                        cell.btnApprove.setTitle("VALIDATE", for: .selected)
                        cell.btnApprove.setTitle("VALIDATE", for: .highlighted)
                        cell.btnApprove.addTarget(self, action: #selector(self.btnValidateClicked(sender:)), for: .touchUpInside)
                    }
                    else if bo.status == "4"
                    {
                        cell.btnReject.isHidden = true
                        
                        cell.btnApprove.setTitle("PAY NOW", for: .normal)
                        cell.btnApprove.setTitle("PAY NOW", for: .selected)
                        cell.btnApprove.setTitle("PAY NOW", for: .highlighted)
                        cell.btnApprove.addTarget(self, action: #selector(self.btnPayNowClicked(sender:)), for: .touchUpInside)
                    }


                }
            }
            else
            {
                cell.constLblNameHeight.constant = 0
                cell.lblStatus.isHidden = false
                cell.lblStatusText.isHidden = false
                cell.btnReject.isHidden = true
                cell.btnApprove.isHidden = true

            }
        }
        else
        {
            cell.constLblNameHeight.constant = 0
            cell.lblStatus.isHidden = false
            cell.lblStatusText.isHidden = false
            cell.btnReject.isHidden = true
            cell.btnApprove.isHidden = true
        }
        return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bo = arrList[indexPath.row]

        fortVw   =   (Bundle.main.loadNibNamed("ImageDetailPopUp", owner: nil, options: nil)![0] as? ImageDetailPopUp)!
        fortVw.lblRecipetID.text = bo.receiptId
        
        var strImage = IMAGE_BASE_URL + bo.image
        strImage = strImage.replacingOccurrences(of: "\r", with: " ")
        strImage = strImage.replacingOccurrences(of: "\n", with: " ")
        let safeURL = strImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string:safeURL!)
        
        fortVw.imgReceipt.kf.indicatorType = .activity
        fortVw.imgReceipt.kf.setImage(with: url ,
                                      placeholder: nil,
                                      options: [.transition(ImageTransition.fade(1))],
                                      progressBlock: { receivedSize, totalSize in
        },
                                      completionHandler: { image, error, cacheType, imageURL in
        })
        
        
        fortVw?.frame = CGRect(x:0,y: 0,width: ScreenWidth, height:ScreenHeight)
        fortVw.btnClose.addTarget(self, action: #selector(btnCloseClicked(sender:)), for: .touchUpInside)
        self.view.window?.addSubview(fortVw!)
        
        
    }
    func btnRejectClicked(sender:UIButton)
    {
        
        rejectPopup   =   (Bundle.main.loadNibNamed("RejectPopup", owner: nil, options: nil)![0] as? RejectPopup)!
        rejectPopup?.frame = CGRect(x:0,y: 0,width: ScreenWidth, height:ScreenHeight)
        rejectPopup.txtVwResaon.layer.borderWidth = 1
        rejectPopup.txtVwResaon.layer.borderColor = UIColor.lightGray.cgColor

        rejectPopup.btnCancel.addTarget(self, action: #selector(btnCancelClicked(sender:)), for: .touchUpInside)
        rejectPopup.btnReject.tag = sender.tag
        rejectPopup.btnReject.addTarget(self, action: #selector(btnRejectConfirmClicked(sender:)), for: .touchUpInside)
        self.view.window?.addSubview(rejectPopup!)

        
        
    }
    func btnValidateClicked(sender:UIButton)
    {
        let alert = UIAlertController(title: "Alert!", message: "Are you sure, You want to Validate?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            let bo = self.arrList[sender.tag - 2500]
            let serviceLayer = ServiceLayer()
            serviceLayer.updateBillWith(billNo: String(bo.id), status: "1", comment: "0", successMessage: { (SR) in
                self.callForData()
            }) { (FR) in
                self.showAlertWith(title: "Alert!", message: FR as! String)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    func btnApproveClicked(sender:UIButton)
    {
        let alert = UIAlertController(title: "Alert!", message: "Are you sure, You want to Approve?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                let bo = self.arrList[sender.tag - 2500]
                let serviceLayer = ServiceLayer()
                serviceLayer.updateBillWith(billNo: String(bo.id), status: "4", comment: "0", successMessage: { (SR) in
                    self.callForData()
                    
                }) { (FR) in
                    self.showAlertWith(title: "Alert!", message: FR as! String)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    func btnPayNowClicked(sender:UIButton)
    {
        let alert = UIAlertController(title: "Alert!", message: "Are you sure, You want to Pay Now?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                let bo = self.arrList[sender.tag - 2500]
                let serviceLayer = ServiceLayer()
                serviceLayer.updateBillWith(billNo: String(bo.id), status: "5", comment: "0", successMessage: { (SR) in
                    self.callForData()
                    
                }) { (FR) in
                    self.showAlertWith(title: "Alert!", message: FR as! String)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    func btnCloseClicked(sender : UIButton)
    {
        fortVw.removeFromSuperview()
    }
    func btnRejectConfirmClicked(sender : UIButton)
    {
        if rejectPopup.txtVwResaon.text != ""
        {
        let bo = self.arrList[sender.tag - 1500]
        let serviceLayer = ServiceLayer()
        if TaksyKraftUserDefaults.getUserRole() == "1"
        {
            serviceLayer.updateBillWith(billNo: String(bo.id), status: "3", comment: rejectPopup.txtVwResaon.text, successMessage: { (SR) in
                self.callForData()
                DispatchQueue.main.async {
                    self.rejectPopup.removeFromSuperview()
                }

            }) { (FR) in
                self.showAlertWith(title: "Alert!", message: FR as! String)
            }
        }
        else
        {
            serviceLayer.updateBillWith(billNo: String(bo.id), status: "2", comment: rejectPopup.txtVwResaon.text, successMessage: { (SR) in
                self.callForData()
                DispatchQueue.main.async {
                    self.rejectPopup.removeFromSuperview()
                }

            }) { (FR) in
                self.showAlertWith(title: "Alert!", message: FR as! String)
            }
        }
        }
        else
        {
            self.showAlertWith(title: "Alert!", message: "Please enter reason to Reject.")
        }

    }

    func btnCancelClicked(sender : UIButton)
    {
        rejectPopup.removeFromSuperview()
    }
}
