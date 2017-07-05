//
//  ServiceLayer.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 29/06/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
public enum ParsingConstant : Int
{
    case Login
}
class ServiceLayer: NSObject {
    let SERVER_ERROR = "Server not responding.\nPlease try after some time."
    let BASE_URL = "http://188.166.218.149/api/v1/"
    public func loginWithEmailId(mobileNo:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {

        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)login/mn=\(mobileNo)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                failureMessage(self.SERVER_ERROR)
            }
            else
            {
                CapillaryUserDefaults.setLoginDate(NSDate())
                if let error = obj.parsedDataDict["error"] as? String,let message = obj.parsedDataDict["message"] as? String
                {
                    if error == "true"
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        failureMessage(x)
                    }
                    else
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        successMessage(x)
                    }
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func checkLoginWith(mobileNo:String,Otp : String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)checklogin/mn=\(mobileNo)/otp=\(Otp)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                failureMessage(self.SERVER_ERROR)
            }
            else
            {
                CapillaryUserDefaults.setLoginDate(NSDate())
                if let error = obj.parsedDataDict["error"] as? String,let message = obj.parsedDataDict["message"] as? String
                {
                    if error == "true"
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        failureMessage(x)
                    }
                    else
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        successMessage(x)
                    }
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getBillDetailsWith(mobileNo:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var dictBody = [String:AnyObject]()
        dictBody["mobileno"] = "mobileNo" as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)billdetails"
        obj.params = dictBody
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                failureMessage(self.SERVER_ERROR)
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String,let message = obj.parsedDataDict["message"] as? String
                {
                    if error == "true"
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        failureMessage(x)
                    }
                    else
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        successMessage(x)
                    }
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }

    //MARK:- Utility Methods
    public func convertDictionaryToString(dict: [String:String]) -> String? {
        var strReturn = ""
        for (key,val) in dict
        {
            strReturn = strReturn.appending("\(key)=\(val)&")
        }
        strReturn = String(strReturn.characters.dropLast())
        
        return strReturn
    }
    
    
    
    public func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    public func encodeSpecialCharactersManually(_ strParam : String)-> String
    {
        
        var strParams = strParam.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
        strParams = strParams!.replacingOccurrences(of: "&", with:"%26")
        return strParams!
    }
    
    public func convertSpecialCharactersFromStringForAddress(_ strParam : String)-> String
    {
        
        var strParams = strParam.replacingOccurrences(of: "&", with:"&amp;")
        strParams = strParams.replacingOccurrences(of: ">", with: "&gt;")
        strParams = strParams.replacingOccurrences(of: "<", with: "&lt;")
        strParams = strParams.replacingOccurrences(of: "\"", with: "&quot;")
        strParams = strParams.replacingOccurrences(of: "'", with: "&apos;")
        return strParams
    }
    public func convertStringFromSpecialCharacters(strParam : String)-> String
    {
        
        var strParams = strParam.replacingOccurrences(of:"%26", with:"&")
        strParams = strParams.replacingOccurrences(of:"&amp;", with:"&")
        strParams = strParams.replacingOccurrences(of:"%3E", with: ">")
        strParams = strParams.replacingOccurrences(of:"%3C" , with: "<")
        strParams = strParams.replacingOccurrences(of:"&quot;", with: "\"")
        strParams = strParams.replacingOccurrences(of:"&apos;" , with: "'")
        
        return strParams
    }

}
