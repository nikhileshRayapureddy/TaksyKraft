//
//  DashboardViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 22/01/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class DashboardViewController: BaseViewController {

    @IBOutlet weak var btnExpenses: UIButton!
    @IBOutlet weak var btnTravel: UIButton!
    @IBOutlet weak var btnTransaction: UIButton!
    @IBOutlet weak var vwTransacctions: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.designNavBarForDashBoard()
        if TaksyKraftUserDefaults.getUser().role == "employee"
        {
            vwTransacctions.isHidden = true
        }
    }

    @IBAction func btnExpensesClicked(_ sender: UIButton) {
        let VC = UIStoryboard (name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ExpensesViewController") as! ExpensesViewController
        self.navigationController?.pushViewController(VC, animated: true)

    }
    
    @IBAction func btnTravelClciked(_ sender: UIButton) {
        let VC = UIStoryboard (name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TravelViewController") as! TravelViewController
        self.navigationController?.pushViewController(VC, animated: true)

    }
    @IBAction func btnTransactionClicked(_ sender: UIButton) {
        let VC = UIStoryboard (name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
