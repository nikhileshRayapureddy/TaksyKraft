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
    let BASE_URL_New = "http://188.166.218.149/api/v2/"
    public func loginWithEmailId(mobileNo:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {

        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL_New)login/mn=\(mobileNo)/fcm=12345"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                failureMessage(self.SERVER_ERROR)
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String,let message = obj.parsedDataDict["message"] as? String,let otp = obj.parsedDataDict["otp"] as? NSNumber
                {
                    if error == "true"
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        failureMessage(x)
                    }
                    else
                    {
                        let x = message != "" ? message : self.SERVER_ERROR
                        successMessage(x + String(describing: otp))
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
                                TaksyKraftUserDefaults.setUserName(object: name)
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
                                if let status = receipt["status"] as? String
                                {
                                    receipetBO.status = status
                                }

                                if let created_at = receipt["created_at"] as? [String:AnyObject]
                                {
                                    if let date = created_at["date"] as? String
                                    {
                                        receipetBO.created_at = date
                                    }
                                }
                                if let updated_at = receipt["updated_at"] as? [String:AnyObject]
                                {
                                    if let date = updated_at["date"] as? String
                                    {
                                        receipetBO.updated_at = date
                                    }
                                }
                                    arrData.append(receipetBO)
                            }
                            for i in 0..<arrData.count/2 {
                                (arrData[i],arrData[arrData.count - i - 1])  = (arrData[arrData.count - i - 1],arrData[i])
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
        obj._serviceURL = "\(BASE_URL)billhistorynew/\(mobileNo)"
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
                                if let wallet_amount = receipt["wallet_amount"] as? String
                                {
                                    receipetBO.wallet_amount = wallet_amount
                                }
                                if let total = receipt["total"] as? String
                                {
                                    receipetBO.total = total
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
                                if let status_message = receipt["status_message"] as? String
                                {
                                    receipetBO.status_message = status_message
                                }
                                if let created_at = receipt["created_at"] as? String
                                {
                                    receipetBO.created_at = created_at
                                }
                                if let updated_at = receipt["updated_at"] as? String
                                {
                                    receipetBO.updated_at = updated_at
                                }
                                if let comment = receipt["comment"] as? String
                                {
                                    receipetBO.comment = comment
                                }
                                if let user = receipt["user"] as? String
                                {
                                    receipetBO.user = user
                                }

                                    arrData.append(receipetBO)
                            }
                            for i in 0..<arrData.count/2 {
                                (arrData[i],arrData[arrData.count - i - 1])  = (arrData[arrData.count - i - 1],arrData[i])
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
    public func updateBillWith(billNo:String,status:String,comment:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        //188.166.218.149/api/v1/billupdatenew/no=124/status=4/{comment?}/{mobileno}
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)billupdatenew/no=\(billNo)/status=\(status)/\(comment)/\(TaksyKraftUserDefaults.getUserMobile())"
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
    func uploadWith(imageData : Data,desc : String,mobileNo:String,card:String,wallet:String,amount : String,fileName : String,contentType:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        
        let strUrl = BASE_URL + "upload"
        let webStringURL = strUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        var request  = URLRequest(url: URL(string:webStringURL)!)
        request.httpMethod = "POST"
        let boundary = "Orb"
        let body = NSMutableData()
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"mobileno\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(mobileNo)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"amount\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(amount)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(desc)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"card\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(card)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"wallet\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(wallet)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)

        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: contentType\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        let content:String = "multipart/form-data; boundary=\(boundary)"
        request.setValue(content, forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.length)", forHTTPHeaderField:"Content-Length")
        request.httpBody = body as Data?
        request.url = URL(string: webStringURL)!
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 40.0
        config.timeoutIntervalForResource = 40.0
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, err) in
            if data != nil
            {
                let dataString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                print("data string = ", dataString! as String)
                if dataString != ""
                {
                    
                    if self.convertStringToDictionary(dataString!) != nil
                    {
                        
                        let parsedDataDict = self.convertStringToDictionary(dataString!)! as [String:AnyObject]
                        if parsedDataDict.keys.count == 0
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                        else
                        {
                            if let error = parsedDataDict["error"] as? String
                            {
                                if Bool(error) == false
                                {
                                    if let message = parsedDataDict["message"] as? String
                                    {
                                        successMessage(message)
                                    }
                                    else
                                    {
                                        failureMessage(self.SERVER_ERROR)
                                    }
                                }
                                else
                                {
                                    failureMessage(self.SERVER_ERROR)
                                }
                            }
                        }
                        
                    }
                    else
                    {
                        failureMessage(self.SERVER_ERROR)
                    }
                    
                    
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
            else
            {
                failureMessage(self.SERVER_ERROR)
                
            }
            
            
        }
        
        task.resume()
        
    }

    func uploadEditedDetailsWith(imageData : Data,card:String,wallet:String,desc : String,mobileNo:String,amount : String,fileName : String,contentType:String,expenseID : String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        
        let strUrl = BASE_URL + "editchanges/expid=\(expenseID)"
        let webStringURL = strUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        var request  = URLRequest(url: URL(string:webStringURL)!)
        request.httpMethod = "POST"
        let boundary = "Orb"
        let body = NSMutableData()
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"mobileno\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(mobileNo)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"card\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(card)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"wallet\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(wallet)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"amount\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(amount)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(desc)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        
        if imageData.count > 0
        {
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: contentType\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
            body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        }
      
        
        let content:String = "multipart/form-data; boundary=\(boundary)"
        request.setValue(content, forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.length)", forHTTPHeaderField:"Content-Length")
        request.httpBody = body as Data?
        request.url = URL(string: webStringURL)!
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 40.0
        config.timeoutIntervalForResource = 40.0
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, err) in
            if data != nil
            {
                let dataString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                print("data string = ", dataString! as String)
                if dataString != ""
                {
                    
                    if self.convertStringToDictionary(dataString!) != nil
                    {
                        
                        let parsedDataDict = self.convertStringToDictionary(dataString!)! as [String:AnyObject]
                        if parsedDataDict.keys.count == 0
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                        else
                        {
                            if let error = parsedDataDict["error"] as? String
                            {
                                if Bool(error) == false
                                {
                                    if let message = parsedDataDict["message"] as? String
                                    {
                                        successMessage(message)
                                    }
                                    else
                                    {
                                        failureMessage(self.SERVER_ERROR)
                                    }
                                }
                                else
                                {
                                    failureMessage(self.SERVER_ERROR)
                                }
                            }
                        }
                        
                    }
                    else
                    {
                        failureMessage(self.SERVER_ERROR)
                    }
                    
                    
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
            else
            {
                failureMessage(self.SERVER_ERROR)
                
            }
            
            
        }
        
        task.resume()
        
    }
    public func getWalletAmount(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL_New)wallet/mobileno=\(TaksyKraftUserDefaults.getUserMobile())"///
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
                        let x = self.SERVER_ERROR
                        failureMessage(x)
                    }
                    else
                    {
                        if let balance = obj.parsedDataDict["balance"] as? String
                        {
                            successMessage(balance)
                        }
                        else
                        {
                            let x = self.SERVER_ERROR
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
    public func getEmployeeList(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL_New)usersList"
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
                            var arrData = [EmployeBO]()
                            for receipt in data
                            {
                                let employeBO = EmployeBO()
                                if let Name = receipt["Name"] as? String
                                {
                                    employeBO.Name = Name
                                }
                                if let Mobile = receipt["Mobile"] as? String
                                {
                                    employeBO.Mobile = Mobile
                                }
                                if let Location = receipt["Location"] as? String
                                {
                                    employeBO.Location = Location
                                }
                                
                                arrData.append(employeBO)
                            }
                            successMessage(arrData)
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
    func sendMoney(fromUser : String,toUser : String,amt : String,desc : String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var dict = [String:AnyObject]()
        dict["from_user"] = fromUser as AnyObject
        dict["to_user"] = toUser as AnyObject
        dict["amount"] = amt as AnyObject
        dict["Description"] = desc as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL_New)sendMoney"
        obj.params = dict
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
    
    func uploadWith(imageData : Data,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        
        let strUrl = "http://139.59.14.2/api/v3/upload-image"
        let webStringURL = strUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        var request  = URLRequest(url: URL(string:webStringURL)!)
        request.httpMethod = "POST"
        let boundary = "Orb"
        let body = NSMutableData()
        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\";filename=\"\test.png\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: contentType\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        let content:String = "multipart/form-data; boundary=\(boundary)"
        request.setValue(content, forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.length)", forHTTPHeaderField:"Content-Length")
        request.setValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImMwZjU3NzE4MDk2NmQxNWVkOTQ1YzVlY2ZlMjFhNmMwN2QxMWJjNWQwN2UxMDM3NGYzZDQ1MTkzN2I5NGQ1MDhmYjExZjY5MzQzODU4MmMxIn0.eyJhdWQiOiIxIiwianRpIjoiYzBmNTc3MTgwOTY2ZDE1ZWQ5NDVjNWVjZmUyMWE2YzA3ZDExYmM1ZDA3ZTEwMzc0ZjNkNDUxOTM3Yjk0ZDUwOGZiMTFmNjkzNDM4NTgyYzEiLCJpYXQiOjE1MTc5ODU4NTcsIm5iZiI6MTUxNzk4NTg1NywiZXhwIjoxNTQ5NTIxODU3LCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.2NN2DCB_SqX0dvKg-JRFq0BXxyWjUJAFcXBDioOSnk9ItWN3IYj4ZCJZZZE1AUU16iDFersCm_YrEHBu8BsUEGEu01WbI8p58KUKg2FP-vFGAvRmHrTpULWh2Anfm0d1jf203zYMeRSY_VUPfiWz2McFpkM41jOBSxxgmRDgGlcAqSO3oVaXdrf-TcrGfzzGGR3NgrtRiEIFvzsx_dfN5AR9wU3IMAG9yEcgyCv-I-G-g-6gN1Bkg8tlHF3bXqE1tkFtvQpEQ7LEtSCvJV6003BjqT3x3UTvrGjweokTkpTQRO8_nR3ExiRYed_6LYNbGmbJpKxAQTuRD_BiF-x46bbpdFnjZ_leVvW7x5DODlz3OyPfDvlQFOisr6wubREXfDx9UtQ6s3Nz2hyALEnhOJDwZDvrh5JzDOMX2Gtl6PxZ1AZ0aN29ObmUqQV5Y4F6RW0GTkVqbYq8bCuIW8m2gbV96MpFwWsIPS0epVHHoE7kFTfKtbkwy1lW6PGfKJKjtssUe12LdRAmTVJ1QwPe8S3xBhFCeFD6IGEx7hc_vO8wjLcazx8dnBPdQfy8bVDgnw7zwxd_A1hrcvaSZN4PFMkfMDhv6PyKgjPWDwEXyw2NtPfKpBGcQe1cLI_BTIBhHY-8RVDFuBp3pO94-1vcmVdaHLnH9l9GT7Z1rBHqcSI", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body as Data?
        
        request.url = URL(string: webStringURL)!
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 40.0
        config.timeoutIntervalForResource = 40.0
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, err) in
            if data != nil
            {
                let dataString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                print("data string = ", dataString! as String)
                if dataString != ""
                {
                    
                    if self.convertStringToDictionary(dataString!) != nil
                    {
                        return
                        let parsedDataDict = self.convertStringToDictionary(dataString!)! as [String:AnyObject]
                        if parsedDataDict.keys.count == 0
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                        else
                        {
                            if let error = parsedDataDict["error"] as? String
                            {
                                if Bool(error) == false
                                {
                                    if let message = parsedDataDict["message"] as? String
                                    {
                                        successMessage(message)
                                    }
                                    else
                                    {
                                        failureMessage(self.SERVER_ERROR)
                                    }
                                }
                                else
                                {
                                    failureMessage(self.SERVER_ERROR)
                                }
                            }
                        }
                        
                    }
                    else
                    {
                        failureMessage(self.SERVER_ERROR)
                    }
                    
                    
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
            else
            {
                failureMessage(self.SERVER_ERROR)
                
            }
            
            
        }
        
        task.resume()
        
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
