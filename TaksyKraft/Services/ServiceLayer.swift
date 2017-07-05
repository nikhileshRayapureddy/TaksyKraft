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
                if let error = obj.parsedDataDict["error"] as? String,let message = obj.parsedDataDict["message"] as? String
                {
                    if error == "true"
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        failureMessage(x)
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            let user = data[0]
                            
                            let BO = UserBO()
                            if let id = user["id"] as? NSNumber
                            {
                                BO.id = Int(id)
                            }
                            if let name = user["name"] as? String
                            {
                                BO.name = name
                            }
                            if let mobile = user["mobile"] as? String
                            {
                                BO.mobile = mobile
                            }
                            if let otp = user["otp"] as? String
                            {
                                BO.otp = otp
                            }
                            if let role = user["role"] as? String
                            {
                                BO.role = role
                            }
                            if let created_at = user["created_at"] as? String
                            {
                                BO.created_at = created_at
                            }
                            if let updated_at = user["updated_at"] as? String
                            {
                                BO.updated_at = updated_at
                            }
                            successMessage(BO)
                        }
                        else
                        {
                            let x = message != "" ? message : self.SERVER_ERROR
                            failureMessage(x)
                        }
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
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)billdetails/\(mobileNo)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                failureMessage(self.SERVER_ERROR)
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        failureMessage(self.SERVER_ERROR)
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [ReceiptBO]()
                            for receipt in data
                            {
                                let receipetBO = ReceiptBO()
                                if let id = receipt["id"] as? NSNumber
                                {
                                    receipetBO.id = Int(id)
                                }
                                if let receiptId = receipt["receiptId"] as? String
                                {
                                    receipetBO.receiptId = receiptId
                                }
                                if let image = receipt["image"] as? String
                                {
                                    receipetBO.image = image
                                }
                                if let name = receipt["name"] as? String
                                {
                                    receipetBO.name = name
                                }
                                if let uploadedby = receipt["uploadedby"] as? String
                                {
                                    receipetBO.uploadedby = uploadedby
                                }
                                if let amount = receipt["amount"] as? String
                                {
                                    receipetBO.amount = amount
                                }
                                if let Description = receipt["description"] as? String
                                {
                                    receipetBO.Description = Description
                                }
                                if let validate = receipt["validate"] as? String
                                {
                                    receipetBO.validate = validate
                                }
                                if let approved = receipt["approved"] as? String
                                {
                                    receipetBO.approved = approved
                                }
                                if let status = receipt["status"] as? String
                                {
                                    receipetBO.status = status
                                }
                                if let created_at = receipt["created_at"] as? String
                                {
                                    receipetBO.created_at = created_at
                                }
                                if let updated_at = receipt["updated_at"] as? String
                                {
                                    receipetBO.updated_at = updated_at
                                }
                                arrData.append(receipetBO)
                            }
                            successMessage(arrData)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getBillHistoryWith(mobileNo:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)billhistory/\(mobileNo)"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                failureMessage(self.SERVER_ERROR)
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        failureMessage(self.SERVER_ERROR)
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [ReceiptBO]()
                            for receipt in data
                            {
                                let receipetBO = ReceiptBO()
                                if let id = receipt["id"] as? NSNumber
                                {
                                    receipetBO.id = Int(id)
                                }
                                if let receiptId = receipt["receiptId"] as? String
                                {
                                    receipetBO.receiptId = receiptId
                                }
                                if let image = receipt["image"] as? String
                                {
                                    receipetBO.image = image
                                }
                                if let name = receipt["name"] as? String
                                {
                                    receipetBO.name = name
                                }
                                if let uploadedby = receipt["uploadedby"] as? String
                                {
                                    receipetBO.uploadedby = uploadedby
                                }
                                if let amount = receipt["amount"] as? String
                                {
                                    receipetBO.amount = amount
                                }
                                if let Description = receipt["description"] as? String
                                {
                                    receipetBO.Description = Description
                                }
                                if let validate = receipt["validate"] as? String
                                {
                                    receipetBO.validate = validate
                                }
                                if let approved = receipt["approved"] as? String
                                {
                                    receipetBO.approved = approved
                                }
                                if let status = receipt["status"] as? String
                                {
                                    receipetBO.status = status
                                }
                                if let created_at = receipt["created_at"] as? String
                                {
                                    receipetBO.created_at = created_at
                                }
                                if let updated_at = receipt["updated_at"] as? String
                                {
                                    receipetBO.updated_at = updated_at
                                }
                                arrData.append(receipetBO)
                            }
                            successMessage(arrData)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func updateBillWith(billNo:String,ap:String,st:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        //http://188.166.218.149/api/v1/billupdate/no=1/ap=0/st=1
//        var dict = [String:AnyObject]()
//        dict["no"] = billNo
//        dict["ap"] = ap
//        dict["st"] = st
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)billupdate/no=\(billNo)/ap=\(ap)/st=\(st)"
        obj.params = [:]
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
                        successMessage(message)
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
