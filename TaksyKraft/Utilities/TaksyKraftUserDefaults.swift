//
//  CapillaryUserDefaults.swift
//  CapillaryFramework
//
//  Created by Nikhilesh on 05/05/17.
//  Copyright © 2017 Capillary Technologies. All rights reserved.
//

import UIKit

let UserMobile = "Mobile"
let UserName = "Name"
let User = "User"
let LoginStatus = "LoginStatus"
let isMyExpense = "isMyExpense"
let isFromExpenses = "isFromExpenses"
let Wallet = "Wallet"
let accessToken = "accessToken"
let FCMToken = "FCMToken"

public class TaksyKraftUserDefaults: NSObject {
    
    public class func getLoginStatus() -> Bool{
        return UserDefaults.standard.bool(forKey: LoginStatus)
    }
    public class func setLoginStatus (object:Bool)
    {
        UserDefaults.standard.set(object, forKey: LoginStatus)
        UserDefaults.standard.synchronize()
        
    }
    public class func getAccessToken() -> String{
        let str = UserDefaults.standard.object(forKey: accessToken) as? String ?? ""
        
        return str
    }
    public class func setFCMToken (object:String)
    {
        UserDefaults.standard.set(object, forKey:FCMToken)
        
        UserDefaults.standard.synchronize()

    }
    public class func getFCMToken() -> String{
        let str = UserDefaults.standard.object(forKey: FCMToken) as? String ?? ""
        
        return str
    }
    public class func setAccessToken (object:String)
    {
        UserDefaults.standard.set(object, forKey:accessToken)
        
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
    public class func getUserName() -> String
    {
        let str = UserDefaults.standard.object(forKey: UserName) as? String ?? ""
        return str
    }
    
    public class func setUserName(object : String)
    {
        UserDefaults.standard.set(object, forKey:UserName)
        UserDefaults.standard.synchronize()
    }
    public class func getWalletAmount() -> String
    {
        let str = UserDefaults.standard.object(forKey: Wallet) as? String ?? ""
        
        return str
    }
    public class func getUser() -> UserBO
    {
        let data = UserDefaults.standard.data(forKey: User)
        return (NSKeyedUnarchiver.unarchiveObject(with: data!) as? UserBO)!
    }
    public class func setUser(object : UserBO)
    {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(encodedData, forKey:User)
        UserDefaults.standard.synchronize()
    }

    public class func setWalletAmount(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:Wallet)
        
        UserDefaults.standard.synchronize()
        
    }

    
}
