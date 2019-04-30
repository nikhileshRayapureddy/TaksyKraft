//
//  ProfileViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 20/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblEmpName: UILabel!
    @IBOutlet weak var lblEmpID: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var lblDesignation: UILabel!
    @IBOutlet weak var lblBloodGroup: UILabel!
    var profileBO = UserBO(Id: 0, strname: "", strempId: "", strmobile: "", strdesignation: "", strbloodGroup: "", strrole: "", strprofile_image: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        profileBO = TaksyKraftUserDefaults.getUser()
        
        let url = URL(string: IMAGE_BASE_URL +
            profileBO.profile_image)
        
        self.imgProfile.kf.indicatorType = .activity
        self.imgProfile.kf.setImage(
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

        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width/2
        self.imgProfile.layer.masksToBounds = true
        lblEmpID.text = profileBO.empId
        lblEmpName.text = profileBO.name
        lblMobileNo.text = profileBO.mobile
        lblDesignation.text = profileBO.designation
        lblBloodGroup.text = profileBO.bloodGroup
        
        self.imgProfile.layer.borderColor = UIColor.white.cgColor
        self.imgProfile.layer.borderWidth = 2.0
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func btnLogoutClicked(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Alert!", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                app_delegate.showLoader(message: "")
                let layer = ServiceLayer()
                layer.logout(successMessage: { (reponse) in
                    DispatchQueue.main.async {
                        app_delegate.removeloder()
                        TaksyKraftUserDefaults.setLoginStatus(object: false)
                        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                        app_delegate.navCtrl.isNavigationBarHidden = true
                        app_delegate.navCtrl = UINavigationController(rootViewController: vc)
                        app_delegate.window?.rootViewController = app_delegate.navCtrl
                        app_delegate.window?.backgroundColor = Color_NavBarTint

                    }
                }, failureMessage: { (error) in
                    DispatchQueue.main.async {
                        app_delegate.removeloder()
                        let alert = UIAlertController(title: "Alert!", message: "Failed to logout.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)

                    }
                })

            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
