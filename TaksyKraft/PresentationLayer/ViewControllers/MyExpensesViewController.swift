//
//  MyExpensesViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 11/09/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class MyExpensesViewController: BaseViewController,UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var tblMyExpenses: UITableView!
    var arrList = [ReceiptBO]()
    var fortVw : ImageDetailPopUp!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblMyExpenses.register(UINib(nibName: "MyExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "MyExpensesTableViewCell")

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callForData()
    }
    func callForData()
    {
        app_delegate.showLoader(message: "Fetching data..")
        self.designNavBarWithTitleAndBack(title: "My Expenses",showBack: true, isMenu: false)
        let serviceLayer = ServiceLayer()
        serviceLayer.getBillHistoryWith(mobileNo: TaksyKraftUserDefaults.getUserMobile(), successMessage: { (response) in
            app_delegate.removeloder()
            self.arrList = response as! [ReceiptBO]
            DispatchQueue.main.async {
                self.tblMyExpenses.reloadData()
                self.tblMyExpenses.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }) { (failure) in
            app_delegate.removeloder()
            self.showAlertWith(title: "Alert!", message: failure as! String)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}
extension MyExpensesViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MyExpensesTableViewCell", for: indexPath)  as! MyExpensesTableViewCell
        let bo = arrList[indexPath.row]
        
        cell.lblDesc.text = bo.Description
        cell.lblTktNo .text = bo.receiptId
        cell.lblPrice.text = "₹ " + bo.amount
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
        if bo.status_message == "Not verified"
        {
            cell.lblStatus.textColor = UIColor(red: 250.0/255.0, green: 186.0/255.0, blue: 51.0/255.0, alpha: 1)
        }
        else if bo.status_message == "Verified"
        {
            cell.lblStatus.textColor = UIColor(red: 0, green: 93.0/255.0, blue: 171.0/255.0, alpha: 1)
        }
        else if bo.status_message == "Approved"
        {
            cell.lblStatus.textColor = UIColor(red: 35.0/255.0, green: 95.0/255.0, blue: 123.0/255.0, alpha: 1)
        }
        else if bo.status_message == "Rejected"
        {
            cell.lblStatus.textColor = UIColor(red: 211.0/255.0, green: 40.0/255.0, blue: 9.0/255.0, alpha: 1)
        }
        else if bo.status_message == "Paid" || bo.status_message == "Paid with wallet" || bo.status_message == "Wallet + Card Payment"
        {
            cell.lblStatus.textColor = UIColor(red: 135.0/255.0, green: 205.0/255.0, blue: 115.0/255.0, alpha: 1)
        }
        else
        {
            cell.lblStatus.textColor = UIColor.black
        }
        cell.lblComment.text = bo.comment
        cell.lblNetAmt.text = "₹ " + bo.total
        cell.lblTotalAmt.text = "₹ " + bo.amount
        if bo.wallet_amount == "N/A"
        {
            cell.lblWalletAmt.text = bo.wallet_amount
        }
        else
        {
            cell.lblWalletAmt.text = "₹ " + bo.wallet_amount
        }
        if bo.status == "0"
        {
            cell.btnMore.isHidden = false
            cell.btnMore.tag = 670 + indexPath.row
            cell.btnMore.addTarget(self, action: #selector(btnMoreClicked(sender:)), for: .touchUpInside)
        }
        else
        {
            cell.btnMore.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 205
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
    func btnCloseClicked(sender : UIButton)
    {
        fortVw.removeFromSuperview()
    }

    func btnMoreClicked(sender:UIButton)
    {
        
        self.showPopOver(arrTitles: ["Edit","Delete"], sender: sender ,tag:sender.tag)
    }
    func showPopOver(arrTitles : [String] ,sender : UIView ,tag : Int)  {
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
    
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .none
    }

}
extension MyExpensesViewController : popoverGeneralDelegate {
    func selectedText(selectedText: String, popoverselected: Int, tag: Int) {
        if selectedText == "Edit"
        {
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateExpenseViewController") as! CreateExpenseViewController
            vc.isFromEdit = true
            vc.receiptBO = arrList[tag-670]
            self.navigationController?.pushViewController(vc, animated: true)

        }
        else if selectedText == "Delete"
        {
        }
        else
        {
            print("N/A")
        }
    }
}
