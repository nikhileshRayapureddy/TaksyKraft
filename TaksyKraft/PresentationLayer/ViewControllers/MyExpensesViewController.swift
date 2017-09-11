//
//  MyExpensesViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 11/09/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class MyExpensesViewController: BaseViewController {

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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
        cell.lblComment.text = bo.comment
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 181
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
}
