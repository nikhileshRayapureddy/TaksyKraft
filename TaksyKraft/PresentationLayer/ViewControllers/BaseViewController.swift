//
//  BaseViewController.swift
//  TaksyKraft
//
//  Created by NIKHILESH on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
let Color_NavBarTint = UIColor(red: 84.0/255.0, green: 130.0/255.0, blue: 153.0/255.0, alpha: 1.0)
let ScreenWidth  =  UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func designNavBarWithTitleAndBack(title:String,showBack : Bool,isMenu : Bool)
    {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = Color_NavBarTint

        let leftBarButtonItems = UIView()
        leftBarButtonItems.frame = CGRect(x:0,y: 0,width: ScreenWidth-30,height: 44)
        let backButton = UIButton(type: UIButtonType.custom)
        let titleLbl = UILabel()
        if showBack
        {
            backButton.frame = CGRect(x: 0, y: -2  , width: 50 , height: 44)
            backButton.imageEdgeInsets = UIEdgeInsetsMake(10, 2,2,10)
            backButton.setImage(UIImage(named: "back"), for: UIControlState.normal)
            backButton.addTarget(self, action: #selector(backClicked(sender:)), for: .touchUpInside)
            leftBarButtonItems.addSubview(backButton)
        }
        if title != ""
        {
            if showBack
            {
                titleLbl.frame = CGRect(x: backButton.frame.width+1,y:8,width: ScreenWidth-55,height: 30)
            }
            else
            {
                titleLbl.frame = CGRect(x: 10,y:8,width: ScreenWidth-55,height: 30)
            }
            titleLbl.font = UIFont(name: "Helvetica-Bold", size: 16)
            titleLbl.text = title
            titleLbl.textAlignment = .left
            titleLbl.textColor = UIColor.white
            leftBarButtonItems.addSubview(titleLbl)
        }
        let bItem = UIBarButtonItem(customView:leftBarButtonItems)
        let negativeSpacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        negativeSpacer.width = -15;
        self.navigationItem.leftBarButtonItems = [ negativeSpacer, bItem]
        
        if isMenu
        {
            let rightBarButtonItems = UIView()
            rightBarButtonItems.frame = CGRect(x:0,y: 0,width: 50,height: 44)
            let btnMenu = UIButton(type: UIButtonType.custom)
            btnMenu.frame = CGRect(x: 0, y: 0  , width: 50 , height: 44)
            btnMenu.setImage(#imageLiteral(resourceName: "menu"), for: UIControlState.normal)
            btnMenu.addTarget(self, action: #selector(btnMenuClicked(sender:)), for: .touchUpInside)
            rightBarButtonItems.addSubview(btnMenu)
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView:rightBarButtonItems)]
        }
    }
    func btnMenuClicked( sender:UIButton)
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
