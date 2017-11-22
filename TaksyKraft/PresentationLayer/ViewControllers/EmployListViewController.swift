//
//  EmployListViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 22/11/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

class EmployListViewController: BaseViewController {

    @IBOutlet weak var tblEmployee: UITableView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var vwBase: UIView!
    @IBOutlet weak var txtFldSearch: UITextField!
    var arrEmployes = [EmployeBO]()
    var arrSearch = [EmployeBO]()
    var isSearch : Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        app_delegate.showLoader(message: "Fetching data...")
        let layer = ServiceLayer()
        layer.getEmployeeList(successMessage: { (arrData) in
            self.arrEmployes = arrData as! [EmployeBO]
            self.arrSearch = arrData as! [EmployeBO]

            DispatchQueue.main.async {
                app_delegate.removeloder()
                if self.arrEmployes.count > 0
                {
                    self.vwBase.isHidden = false
                    self.lblNoDataFound.isHidden = true
                    self.tblEmployee.reloadData()
                }
                else
                {
                    self.vwBase.isHidden = true
                    self.lblNoDataFound.isHidden = false
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                app_delegate.removeloder()
                let alert = UIAlertController(title: "Alert!", message: (error as! String), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)

            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension EmployListViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCustomCell") as! EmployeeCustomCell
        let bo = arrSearch[indexPath.row]
        cell.lblName.text = bo.Name == "" ? "N/A" : bo.Name
        cell.lblMobileNo.text = bo.Mobile == "" ? "N/A" : bo.Mobile
        cell.lblLocation.text = bo.Location == "" ? "N/A" : bo.Location
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bo = arrSearch[indexPath.row]
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SendMoneyViewController") as! SendMoneyViewController
        vc.employBO = bo
        self.navigationController?.pushViewController(vc, animated: true)

    }
}
extension EmployListViewController : UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isSearch = false
        arrSearch.removeAll()
        arrSearch.append(contentsOf: arrEmployes)
        tblEmployee.reloadData()

        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var searchText  = textField.text! + string
        
        if string  == "" {
            searchText = (searchText as String).substring(to: searchText.index(before: searchText.endIndex))
        }
        
        if searchText == "" {
            isSearch = false
            arrSearch.removeAll()
            arrSearch.append(contentsOf: arrEmployes)
            tblEmployee.reloadData()
        }
        else{
            getSearchArrayContains(searchText)
        }
        
        return true
    }
    func getSearchArrayContains(_ text : String) {
        arrSearch = arrEmployes.filter() {
            if let type = ($0 as EmployeBO).Name as? String {
                return type.lowercased().contains(text)
            } else {
                return false
            }
        }
        isSearch = true
        tblEmployee.reloadData()
    }

}
