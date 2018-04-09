//
//  OnlineViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 27/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class OnlineViewController: BaseViewController {
    @IBOutlet weak var tblOnline: UITableView!
    @IBOutlet weak var lblNoDataFound : UILabel!
    var arrOnline = [TransactionBO]()
    var arrFilter = [TransactionBO]()
    @IBOutlet var txtFldSearch: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getOnlineTransactions()
        txtFldSearch.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: txtFldSearch.frame.size.width/2 - 20, y: 0, width: 40, height: 20))
        imageView.image = #imageLiteral(resourceName: "Search")
        imageView.contentMode = .scaleAspectFit
        txtFldSearch.leftView = imageView

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Online", showBack: true, isRefresh: true)

    }
    override func btnRefreshClicked( sender:UIButton)
    {
        self.getOnlineTransactions()
    }

    @IBAction func btnAddOnlineClicked(_ sender: UIButton) {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateOnlineTransactionViewController") as! CreateOnlineTransactionViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getOnlineTransactions()
    {
        app_delegate.showLoader(message: "Loading Transactions....")
        let layer = ServiceLayer()
        layer.getAllOnlineTransactions(successMessage: { (response) in
            DispatchQueue.main.async {
            app_delegate.removeloder()
                self.arrOnline = response as! [TransactionBO]
                self.arrFilter.removeAll()
                if self.txtFldSearch.text != ""
                {
                    if let str = self.txtFldSearch.text
                    {
                        self.arrFilter = self.arrOnline.filter({ (trx) -> Bool in
                            if trx.transId.lowercased().contains(str.lowercased())
                            {
                                return true
                            }
                            return false
                        })
                    }
                }
                else
                {
                    self.arrFilter.append(contentsOf: self.arrOnline)
                }

                self.tblOnline.reloadData()
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
                    let alert = UIAlertController(title: "Alert!", message: "Unable to load Online transactions.", preferredStyle: .alert)
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

}
extension OnlineViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "OnlineTableViewCell", for: indexPath)  as! OnlineTableViewCell
        let trxBo = arrFilter[indexPath.row]
        cell.lblID.text = trxBo.transId
        cell.lblAmt.text = "₹" + trxBo.amount
        cell.lblEmpName.text = trxBo.empName
        cell.lblEmpId.text = trxBo.empId
        cell.lblOtp.text = trxBo.usedOtp
        cell.lblDesc.text = trxBo.notes
        let str = "Description :\n" + trxBo.notes
        
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: 13))
        cell.lblDesc.attributedText = attributedString
        
        var descHeight = ("Description :\n" + trxBo.notes).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
        if trxBo.notes == ""
        {
            descHeight = 0
        }
        else
        {
            descHeight = descHeight + 10
        }
        
        cell.constLblDescriptionHeight.constant = descHeight

        cell.trxBO = trxBo
        cell.callBack = self
        cell.lblAttachCount.text = "\(trxBo.invoice.count + 1) Attachments"
        if trxBo.transactionDate != ""
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.date(from: trxBo.transactionDate)
            dateFormatter.dateFormat = "dd MMM, yyyy"
            cell.lblDate.text = dateFormatter.string(from: date!)
        }
        cell.imgVwOnline.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        cell.imgVwOnline.layer.borderWidth = 1
        cell.imgVwOnline.kf.setImage(with: URL(string: IMAGE_BASE_URL + trxBo.transactionImage), placeholder: #imageLiteral(resourceName: "Loading"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
        }, completionHandler: { image, error, cacheType, imageURL in
        })

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bo = arrFilter[indexPath.row]
        var descHeight = ("Description :\n" + bo.notes).height(withConstrainedWidth: ScreenWidth - 138, font: UIFont(name: "Roboto-Light", size: 15)!)
        if bo.notes == ""
        {
            descHeight = 0
        }
        
        return 140 + descHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateOnlineTransactionViewController") as! CreateOnlineTransactionViewController
        vc.trxBO = arrFilter[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)

    }
}
extension OnlineViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.text! + string)
        
        var strSearch = textField.text! + string
        
        if range.location == 0 && range.length == 1
        {
            strSearch = ""
            arrFilter.removeAll()
            arrFilter.append(contentsOf: self.arrOnline)
        }
        else
        {
            arrFilter = arrOnline.filter({ (exp) -> Bool in
                if exp.transId.lowercased().contains(strSearch.lowercased())
                {
                    return true
                }
                return false
            })
        }
        tblOnline.reloadData()
        return true
    }
}
extension OnlineViewController : OnlineTableViewCellDelegate
{
    func btnImgAttachmentsClicked(trxBO : TransactionBO,cell : OnlineTableViewCell)
    {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        vc.arrUrl = [trxBO.transactionImage]
        vc.arrUrl.append(contentsOf: trxBO.invoice)
        vc.isEdit = false
        self.navigationController?.pushViewController(vc, animated: true)

    }
}
