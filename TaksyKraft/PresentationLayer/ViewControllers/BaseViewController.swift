//
//  BaseViewController.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
let Color_NavBarTint = UIColor.white
let ScreenWidth  =  UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height
let app_delegate =  UIApplication.shared.delegate as! AppDelegate
let TXTVW_MAX_COUNT = 120
class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func designNavBarWithTitleAndBack(title:String,showBack : Bool,isRefresh : Bool)
    {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = Color_NavBarTint
        
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15;
        
        let leftBarButtonItems = UIView()
        leftBarButtonItems.frame = CGRect(x:0,y: 0,width: 50,height: 44)
        let backButton = UIButton(type: UIButtonType.custom)
        let titleLbl = UILabel()
        if showBack
        {
            backButton.frame = CGRect(x: 0, y: 0  , width: 40 , height: 44)
            backButton.imageEdgeInsets = UIEdgeInsetsMake(10, 2,2,10)
            backButton.backgroundColor = .clear
            backButton.setImage(#imageLiteral(resourceName: "Back_Blue"), for: UIControlState.normal)
            backButton.addTarget(self, action: #selector(backClicked(sender:)), for: .touchUpInside)
            leftBarButtonItems.addSubview(backButton)
            let bItem = UIBarButtonItem(customView:leftBarButtonItems)
            self.navigationItem.leftBarButtonItems = [ negativeSpacer, bItem]
            
        }
        if title != ""
        {
            let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 44))
            logoContainer.backgroundColor = UIColor.clear
            if showBack
            {
//                if isRefresh
//                {
                    logoContainer.frame = CGRect(x: 0,y:0,width: ScreenWidth-160,height: 44)
//                }
//                else
//                {
//                    logoContainer.frame = CGRect(x: 0,y:0,width: ScreenWidth-80,height: 44)
//                }
            }
            else
            {
                logoContainer.frame = CGRect(x: 0,y:0,width: ScreenWidth-15,height: 44)
            }
            titleLbl.frame = CGRect(x: 0, y: 0, width: logoContainer.frame.size.width, height: logoContainer.frame.size.height)
            titleLbl.font = UIFont(name: "Roboto-Regular", size: 16)
            titleLbl.text = title
            titleLbl.textAlignment = .center
            titleLbl.backgroundColor = UIColor.clear
            titleLbl.textColor = UIColor.black
            logoContainer.addSubview(titleLbl)
            self.navigationItem.titleView = logoContainer
        }
        
        let rightBarButtonItems = UIView()
        rightBarButtonItems.frame = CGRect(x:0,y: 0,width: 50,height: 44)
        let btnRefresh = UIButton(type: UIButtonType.custom)
        btnRefresh.frame = CGRect(x: 0, y: 0  , width: 50 , height: 44)
        btnRefresh.imageView?.contentMode = .scaleAspectFit
        btnRefresh.setImage(#imageLiteral(resourceName: "Refresh"), for: UIControlState.normal)

        if isRefresh
        {
            btnRefresh.isHidden = false
        }
        else
        {
            btnRefresh.isHidden = true
        }
        btnRefresh.backgroundColor = .clear
        btnRefresh.addTarget(self, action: #selector(btnRefreshClicked(sender:)), for: .touchUpInside)
        rightBarButtonItems.addSubview(btnRefresh)
        if #available(iOS 11.0, *)
        {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView:rightBarButtonItems)]
        }
        else
        {
            self.navigationItem.rightBarButtonItems = [negativeSpacer,UIBarButtonItem(customView:rightBarButtonItems)]
        }
        
    }
    func designNavBarForDashBoard()
    {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = Color_NavBarTint
        
        let leftBarButtonItems = UIView()
        leftBarButtonItems.frame = CGRect(x:0,y: 0,width: 50,height: 44)
        let btnProfile = UIButton(type: UIButtonType.custom)
        btnProfile.frame = CGRect(x: 0, y: 0  , width: 40 , height: 44)
        btnProfile.setImage(#imageLiteral(resourceName: "Profile"), for: UIControlState.normal)
        btnProfile.addTarget(self, action: #selector(btnProfileClicked(sender:)), for: .touchUpInside)
        leftBarButtonItems.addSubview(btnProfile)
        
        let bItem = UIBarButtonItem(customView:leftBarButtonItems)
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15;
        self.navigationItem.leftBarButtonItems = [ negativeSpacer, bItem]
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 44))

        let imgVw = UIImageView()
        imgVw.frame = CGRect(x: 0, y: 12, width: 160, height: 24)
        imgVw.backgroundColor = .clear
        imgVw.image = #imageLiteral(resourceName: "TaksyKraft_Logo")
        logoContainer.addSubview(imgVw)
        self.navigationItem.titleView = logoContainer
        
    }
    func logout()
    {
        TaksyKraftUserDefaults.setLoginStatus(object: false)
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        app_delegate.navCtrl.isNavigationBarHidden = true
        app_delegate.navCtrl = UINavigationController(rootViewController: vc)
        app_delegate.window?.rootViewController = app_delegate.navCtrl
        app_delegate.window?.backgroundColor = Color_NavBarTint

    }
    func btnProfileClicked( sender:UIButton)
    {
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func btnRefreshClicked( sender:UIButton)
    {

    }
    func backClicked( sender:UIButton)
    {
        let _ =    self.navigationController?.popViewController(animated: true)
    }
    
    func showAlertWith(title : String,message : String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
