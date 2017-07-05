//
//  ExpensesViewController.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class ExpensesViewController: BaseViewController {

    var isMyExpense = false
    @IBOutlet weak var tblExpenses: UITableView!
    var arrLsit = NSArray()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tblExpenses.register(UINib(nibName: "MyExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "MyExpensesTableViewCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let serviceLayer = ServiceLayer()
        serviceLayer.getBillDetailsWith(mobileNo: TaksyKraftUserDefaults.getUserMobile(), successMessage: { (response) in
            
        }) { (failure) in
            self.showAlertWith(title: "Alert!", message: failure as! String)
        }
    }
}
extension ExpensesViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MyExpensesTableViewCell", for: indexPath)  as! MyExpensesTableViewCell
        if isMyExpense
        {
            cell.constLblNameHeight.constant = 20
            cell.lblStatus.isHidden = true
            cell.lblStatusText.isHidden = true
            cell.btnReject.isHidden = false
            cell.btnApprove.isHidden = false
            
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
        return 150
    }
}
