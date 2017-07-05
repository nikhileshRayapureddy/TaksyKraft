//
//  CapillaryUserDefaults.swift
//  CapillaryFramework
//
//  Created by Nikhilesh on 05/05/17.
//  Copyright © 2017 Capillary Technologies. All rights reserved.
//

import UIKit
let UserNameKey = "Username"
let UserEmail = "Email"
let UserMobile = "Mobile"
let StoreId  = "storeId"
let StorePin = "storePin"
let StoreAddress  = "StoreAddress"
let StoreArea = "StoreArea"
let StoreCity  = "StoreCity"
let StoreCountry = "StoreCountry"
let StoreDeliverymode = "StoreDeliverymode"
let StoreState  = "StoreState"
let StoreName = "StoreName"
let AccessToken = "AccessToken"
let CRMAccessToken = "CRMAccessToken"
let UserId = "UserId"
let issued_at = "issued_at"
let UserInfo_Id = "UserInfo_Id"
let countryCode = "countrycode"
let stateCode = "statecode"
let cityId = "cityid"
let AddressMultiCheck = "AddressMultiCheck"
let Configurations = "Configuration"
let AreaID = "AreaID"
let DeleviryDate = "DeleviryDate"
let storesRespArray = "storesRespArray"
let shopOnline = "shopOnline"
let OTPToken = "OTPToken"
let APISessionRequired = "APISessionRequired"
let PasswordLength = "PasswordLength"
let MobileNoLength = "MobileNoLength"
let MobileNoStart = "MobileNoStart"
let AboutUs = "AboutUs"
let UserProfile = "UserProfile"
let LoginDate = "LoginDate"
let TimeSlotDate = "TimeSlotDate"
let DeliverySlots = "DeliverySlot"
let FirstName = "FirstName"
let DeliverySlotId = "DeliverySlotId"
let isLastOrderAvailable = "LastOrderAvailable"
let saveLastOrderId = "saveLastOrderId"

public class TaksyKraftUserDefaults: NSObject {
    
    public class func getLoginStatus() -> Bool{
        return UserDefaults.standard.bool(forKey: "isAlreadyLogin")
    }
    public class func setLoginStatus (object:Bool)
    {
        UserDefaults.standard.set(object, forKey: "isAlreadyLogin")
        UserDefaults.standard.synchronize()
        
    }
    public class func getIsLastOrderAvailable() -> Bool{
        return UserDefaults.standard.bool(forKey: "LastOrderAvailable")
    }
    public class func setIsLastOrderAvailable(object:Bool)
    {
        UserDefaults.standard.set(object, forKey: "LastOrderAvailable")
        UserDefaults.standard.synchronize()
        
    }

    public class func getIsShopOnline() -> Bool
    {
        return UserDefaults.standard.bool(forKey: shopOnline)
        
        
    }
    
    public class func setIsShopOnline(object:Bool)
    {
        UserDefaults.standard.set(object, forKey: shopOnline)
        UserDefaults.standard.synchronize()
        
    }
    
    
    
    public class func setUserName (object : String)
    {
        UserDefaults.standard.set(object, forKey: UserNameKey)
        UserDefaults.standard.synchronize()
    }
    
    public class func getUserName () -> String
    {
        return UserDefaults.standard.object(forKey: UserNameKey) as! String
    }
    public class func setCountryCode(object : String)
    {
        UserDefaults.standard.set(object, forKey:"CountryCode")
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getCountryCode () -> String
    {
        return UserDefaults.standard.object(forKey: "CountryCode") as! String
    }
    
    public class func setStoreName(object : String)
    {
        UserDefaults.standard.set(object, forKey:StoreName)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getStoreName () -> String
    {
        return UserDefaults.standard.object(forKey: StoreName) as! String
    }
    public class func setCurrency(object : String)
    {
        UserDefaults.standard.set(object, forKey:"Currency")
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getAccessToken() -> String
    {
        return UserDefaults.standard.object(forKey: AccessToken) as! String
    }
    public class func getOTPToken() -> String
    {
        if let token = UserDefaults.standard.object(forKey: OTPToken) as? String
        {
            return token
        }
        else
        {
            return ""
        }
    }
    public class func setOTPToken(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:OTPToken)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getCurrency () -> String
    {
        
        return "S$"
    }
    public class func setExtensionCode(object : String)
    {
        UserDefaults.standard.set(object, forKey:"ExtensionCode")
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getExtensionCode () -> String
    {
        return UserDefaults.standard.object(forKey: "ExtensionCode") as! String
    }
    
    public class func setLastOrderId(object : String)
    {
        UserDefaults.standard.set(object, forKey:saveLastOrderId)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getLastOrderId () -> String
    {
        let str = UserDefaults.standard.object(forKey: saveLastOrderId) as? String ?? ""

        return str
    }
    
    public class func setUserEMail(object : String)    {
        
        UserDefaults.standard.set(object, forKey:UserEmail)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func setUserPassword(object : String)    {
        
        UserDefaults.standard.set(object, forKey:"password")
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getUserPassword () -> String    {
        
        return UserDefaults.standard.object(forKey: "password") as! String
        
        
    }
    public class func getUserEMail() -> String
    {
        return UserDefaults.standard.object(forKey: UserEmail) as! String
    }
    public class func getStoreId() -> String?
    {
        let str = UserDefaults.standard.object(forKey: StoreId) as? String ?? ""
        print("UserDefaults.standard.object(forKey: StoreId) as? String")
        print(str)
        return UserDefaults.standard.object(forKey: StoreId) as? String
    }
    
    public class func setMinOrderAmount(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:"minOrderAmount")
        
        UserDefaults.standard.synchronize()
        
    }
    
    
    public class func getUserMobile() -> String
    {
        return UserDefaults.standard.object(forKey: UserMobile) as! String
    }
    
    public class func setUserMobile(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:UserMobile)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func setStoreId(object : String)
    {
        UserDefaults.standard.set(object, forKey:StoreId)
        UserDefaults.standard.synchronize()
    }
    
    
    
    public class func setStoreAddress(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:StoreAddress)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getStoreAddress() -> String
    {
        return UserDefaults.standard.object(forKey: StoreAddress) as! String
    }
    
    
    public class func setCityId(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:cityId)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getcityId() -> String
    {
        return UserDefaults.standard.object(forKey: cityId) as! String
    }
    
    public class func setStoreArea(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:StoreArea)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getStoreArea() -> String
    {
        return UserDefaults.standard.object(forKey: StoreArea) as! String
    }
    
    public class func setStoreDeliveryMode(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:StoreDeliverymode)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getStoreDeliveryMode() -> String
    {
        return UserDefaults.standard.object(forKey: StoreDeliverymode) as! String
    }
    public class func setUserId(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:UserId)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getUserId() -> String
    {
        
        return UserDefaults.standard.object(forKey: UserId) as! String
    }
    public class func setissued_at(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:issued_at)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getissued_at() -> String
    {
        
        return UserDefaults.standard.object(forKey: issued_at) as! String
    }
    public class func setAccessToken(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:AccessToken)
        
        UserDefaults.standard.synchronize()
        
    }
    
    public class func getImagePath() -> String
    {
        return UserDefaults.standard.object(forKey: "ImagePath") as! String  //++ need to change this
    }
    public class func setImagePath(object:String)
    {
        UserDefaults.standard.set(object, forKey:"ImagePath")
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getBannerImagePath() -> String
    {
        return UserDefaults.standard.object(forKey: "BannerImagePath") as! String  //++ need to change this
    }
    public class func setBannerImagePath(object:String)
    {
        UserDefaults.standard.set(object, forKey:"BannerImagePath")
        
        UserDefaults.standard.synchronize()
        
    }

    public class func setAboutUs(object:String)
    {
        UserDefaults.standard.set(object, forKey:AboutUs)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getAboutUs() -> String
    {
        return "About us dskafd flkdsf lkdfjd fs,dajf ksdljfadfjk;djflaj dklfjkdsafjk dafjkdfs"
        //return UserDefaults.standard.object(forKey: AboutUs) as! String
    }
    
    public class func setPasswordLength(object:Int)
    {
        UserDefaults.standard.set(object, forKey:PasswordLength)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getPasswordLength() -> Int
    {
        return UserDefaults.standard.object(forKey: PasswordLength) as! Int
        
    }
    public class func setMobileNoLength(object:Int)
    {
        UserDefaults.standard.set(object, forKey:MobileNoLength)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getMobileNoLength() -> Int
    {
        return UserDefaults.standard.object(forKey: MobileNoLength) as! Int
        
    }
    public class func setMobileNoStart(object:String)
    {
        UserDefaults.standard.set(object, forKey:MobileNoStart)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getMobileNoStart() -> String
    {
        return UserDefaults.standard.object(forKey: MobileNoStart) as! String
        
    }
    
    
    //save the appversion
    
    
    public class func setuserFirstName(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:FirstName)
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getuserFirstName() -> String?
    {
        return UserDefaults.standard.object(forKey: FirstName) as? String
    }
    public class func setuserLastName(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:"LastName")
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getuserLastName() -> String
    {
        return UserDefaults.standard.object(forKey: "LastName") as! String
    }

    
    public class func setShippngMode(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:"ShippingMode")
        
        UserDefaults.standard.synchronize()
        
    }
    public class func GetShippngMode() -> String
    {
        return UserDefaults.standard.object(forKey: "ShippingMode") as! String
    }
    
    public class func setDeliverySlotID(object : String?)
    {
        
        UserDefaults.standard.set(object, forKey:"DeliverySlotId")
        
        UserDefaults.standard.synchronize()
        
    }
    public class func getDeliverySlotID() -> String
    {
        return UserDefaults.standard.object(forKey: "DeliverySlotId") as! String
    }
    public class func setConfigValue(value : Any,key : String)
    {
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
        
    }
    public class func getConfigValue(key : String) -> Any
    {
        return UserDefaults.standard.object(forKey: key) ?? ""
    }

    
    
    //MARK:- UserProfile
    
    public class func removeUseProfile()
    {
        UserDefaults.standard.removeObject(forKey: UserProfile)
        UserDefaults.standard.synchronize()
    }
//    public class func setUserProfile(objProfile : UserProfileBO)
//    {
//        
//        
//        let encodedData = NSKeyedArchiver.archivedData(withRootObject: objProfile)
//        UserDefaults.standard.set(encodedData, forKey: UserProfile)
//        UserDefaults.standard.synchronize()
//    }
//    
//    public class func getUserProfile() -> UserProfileBO?
//    {
//        let decoded  = UserDefaults.standard.object(forKey: UserProfile) as! NSData
//        if decoded.length != 0
//        {
//            return NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as?  UserProfileBO
//        }
//        return nil
//        
//    }
    public class func setLoginDate(_ object : NSDate)
    {
        
        Foundation.UserDefaults.standard.set(object, forKey:LoginDate)
        
        Foundation.UserDefaults.standard.synchronize()
        
    }
    public class func getLoginDate() -> NSDate
    {
        return Foundation.UserDefaults.standard.object(forKey: LoginDate) as! NSDate
    }
    public class func setTimeSlotDate(_ object : NSDate)
    {
        
        Foundation.UserDefaults.standard.set(object, forKey:TimeSlotDate)
        
        Foundation.UserDefaults.standard.synchronize()
        
    }
    public class func getTimeSlotDate() -> NSDate
    {
        return Foundation.UserDefaults.standard.object(forKey: TimeSlotDate) as! NSDate
    }
    
    
    public class func setDeliverySlot(objDeliverySlot : [String:String]?)
    {
        
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: objDeliverySlot ?? "")
        UserDefaults.standard.set(encodedData, forKey: DeliverySlots)
        UserDefaults.standard.synchronize()
    }
    
    public class func getDeliverySlot() -> [String:String]?
    {
        if let decoded  = UserDefaults.standard.object(forKey: DeliverySlots) as? NSData
        {
            if decoded.length != 0
            {
                return NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as?  [String:String]
            }
        }
        return nil
        
    }
    public class func getCRMAccessToken() -> String
    {
        return UserDefaults.standard.object(forKey: CRMAccessToken) as! String
    }
    public class func setCRMAccessToken(object : String)
    {
        
        UserDefaults.standard.set(object, forKey:CRMAccessToken)
        
        UserDefaults.standard.synchronize()
        
    }

    
}
