//
//  CapillaryUserDefaults.swift
//  CapillaryFramework
//
//  Created by Nikhilesh on 05/05/17.
//  Copyright © 2017 Capillary Technologies. All rights reserved.
//

import UIKit

let UserMobile = "Mobile"
let UserRole = "UserRole"
let LoginStatus = "LoginStatus"
let isMyExpense = "isMyExpense"
let isFromExpenses = "isFromExpenses"

public class TaksyKraftUserDefaults: NSObject {
    
    public class func getLoginStatus() -> Bool{
        return UserDefaults.standard.bool(forKey: LoginStatus)
    }
    public class func setLoginStatus (object:Bool)
    {
        UserDefaults.standard.set(object, forKey: LoginStatus)
        UserDefaults.standard.synchronize()
        
    }
    public class func getIsMyExpense() -> Bool{
        return UserDefaults.standard.bool(forKey: isMyExpense)
    }
    public class func setIsMyExpense (object:Bool)
    {
        UserDefaults.standard.set(object, forKey: isMyExpense)
        UserDefaults.standard.synchronize()
        
    }
    public class func getIsFromExpenses() -> Bool{
        return UserDefaults.standard.bool(forKey: isFromExpenses)
    }
    public class func setIsFromExpenses (object:Bool)
    {
        UserDefaults.standard.set(object, forKey: isFromExpenses)
        UserDefaults.standard.synchronize()
        
    }
    
    public class func getUserMobile() -> String
    {
        let str = UserDefaults.standard.object(forKey: UserMobile) as? String ?? ""
        
        return str
    }
    
    public class func setUserMobile(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:UserMobile)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getUserRole() -> String{
        return UserDefaults.standard.object(forKey: UserRole) as! String
    }
    public class func setUserRole (object:String)
    {
        UserDefaults.standard.set(object, forKey: UserRole)
        UserDefaults.standard.synchronize()
        
    }
    
    
}
