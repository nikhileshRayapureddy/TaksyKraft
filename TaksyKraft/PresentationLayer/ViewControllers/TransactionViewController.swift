//
//  TransactionViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 27/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class TransactionViewController: BaseViewController {
    @IBOutlet weak var btnOnline: UIButton!
    @IBOutlet weak var btnCheque: UIButton!
    @IBOutlet weak var vwOnline: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarWithTitleAndBack(title: "Transactions", showBack: true, isRefresh: false)
        if TaksyKraftUserDefaults.getUser().role == "hr"
        {
            self.vwOnline.isHidden = true
        }
        
    }

    @IBAction func btnOnlineClicked(_ sender: UIButton) {
        let VC = UIStoryboard (name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OnlineViewController") as! OnlineViewController
        self.navigationController?.pushViewController(VC, animated: true)

    }
    @IBAction func btnChequeClicked(_ sender: UIButton) {
        let VC = UIStoryboard (name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChequeViewController") as! ChequeViewController
        self.navigationController?.pushViewController(VC, animated: true)

    }
}
