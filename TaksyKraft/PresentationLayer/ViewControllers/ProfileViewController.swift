//
//  ProfileViewController.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 20/02/18.
//  Copyright © 2018 TaksyKraft. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var btnProfile: UIButton!
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
        btnProfile.layer.cornerRadius = btnProfile.frame.size.width/2
        btnProfile.kf.setImage(with: URL(string: IMAGE_BASE_URL +
         profileBO.profile_image), for: .normal, placeholder: #imageLiteral(resourceName: "Profile_Default"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
        }, completionHandler: { image, error, cacheType, imageURL in
        })
        lblEmpID.text = profileBO.empId
        lblEmpName.text = profileBO.name
        lblMobileNo.text = profileBO.mobile
        lblDesignation.text = profileBO.designation
        lblBloodGroup.text = profileBO.bloodGroup
        
        btnProfile.layer.borderColor = UIColor.white.cgColor
        btnProfile.layer.borderWidth = 2.0
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func btnProfileClicked(_ sender: UIButton) {
        
    }
    @IBAction func btnLogoutClicked(_ sender: UIButton) {
        TaksyKraftUserDefaults.setLoginStatus(object: false)
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        app_delegate.navCtrl.isNavigationBarHidden = true
        app_delegate.navCtrl = UINavigationController(rootViewController: vc)
        app_delegate.window?.rootViewController = app_delegate.navCtrl
        app_delegate.window?.backgroundColor = Color_NavBarTint
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
