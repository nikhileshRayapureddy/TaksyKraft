//
//  ServiceLayer.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 29/06/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit
let EXP_TOKEN_ERR = "Your TaksyKraft Expenses App Access Token Is Invalid Or Has Expired"
public enum ParsingConstant : Int
{
    case GetOTP
    case VerifyOTP
    case Login
}
class ServiceLayer: NSObject {
    let SERVER_ERROR = "Server not responding.\nPlease try after some time."
    let BASE_URL = "http://139.59.14.2/api/v3/"
    public func getOtpWith(mobileNo:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["mobile"] = mobileNo as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.GetOTP.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)get-otp"
        obj.params = params
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                failureMessage(self.SERVER_ERROR)
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? Bool,let message = obj.parsedDataDict["message"] as? String
                {
                    if error == true
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
    public func verifyOTPWith(mobileNo:String,Otp : String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["mobile"] = mobileNo as AnyObject
        params["otp"] = Otp as AnyObject

        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.VerifyOTP.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)verify-otp"
        obj.params = params
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
                        if let data = obj.parsedDataDict["data"] as? [String:AnyObject],let message = obj.parsedDataDict["message"] as? String
                        {
                            if let accessToken = data["accessToken"] as? String
                            {
                                TaksyKraftUserDefaults.setAccessToken(object: "Bearer " + accessToken)
                                successMessage("Success")
                            }
                            else
                            {
                                failureMessage(message)
                            }
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
    public func getProfile(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)my-profile"
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
                        if let data = obj.parsedDataDict["data"] as? [String:AnyObject]
                        {
                            let userBO = UserBO(Id: 0, strname: "", strempId: "", strmobile: "", strdesignation: "", strbloodGroup: "", strrole: "", strprofile_image: "")
                            if let id = data["id"] as? Int
                            {
                                userBO.id = id
                            }
                            if let name = data["name"] as? String
                            {
                                userBO.name = name
                            }
                            if let empId = data["empId"] as? String
                            {
                                userBO.empId = empId
                            }
                            if let mobile = data["mobile"] as? String
                            {
                                userBO.mobile = mobile
                            }
                            if let designation = data["designation"] as? String
                            {
                                userBO.designation = designation
                            }
                            if let bloodGroup = data["bloodGroup"] as? String
                            {
                                userBO.bloodGroup = bloodGroup
                            }
                            if let role = data["role"] as? String
                            {
                                userBO.role = role
                            }
                            if let profile_image = data["profile_image"] as? String
                            {
                                userBO.profile_image = profile_image
                            }
                            TaksyKraftUserDefaults.setUser(object: userBO)
                            successMessage(userBO)
                            
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    //MARK: - Expenses
    public func getMyExpenses(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)expenses"
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [ReceiptBO]()
                            for receipt in data
                            {
                                let receipetBO = ReceiptBO()
                                if let expenseId = receipt["expenseId"] as? String
                                {
                                    receipetBO.expenseId = expenseId
                                }
                                if let image = receipt["image"] as? String
                                {
                                    receipetBO.image = image
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
                                if let uploadedDate = receipt["uploadedDate"] as? String
                                {
                                    receipetBO.uploadedDate = uploadedDate
                                }
                                if let empId = receipt["empId"] as? String
                                {
                                    receipetBO.empId = empId
                                }
                                if let empName = receipt["empName"] as? String
                                {
                                    receipetBO.empName = empName
                                }
                                if let comment = receipt["comment"] as? String
                                {
                                    receipetBO.comment = comment
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
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }

                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getAllExpenses(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)expenses/all"
        obj.params = [:]
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [ReceiptBO]()
                            for receipt in data
                            {
                                let receipetBO = ReceiptBO()
                                if let expenseId = receipt["expenseId"] as? String
                                {
                                    receipetBO.expenseId = expenseId
                                }
                                if let image = receipt["image"] as? String
                                {
                                    receipetBO.image = image
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
                                if let uploadedDate = receipt["uploadedDate"] as? String
                                {
                                    receipetBO.uploadedDate = uploadedDate
                                }
                                if let empId = receipt["empId"] as? String
                                {
                                    receipetBO.empId = empId
                                }
                                if let empName = receipt["empName"] as? String
                                {
                                    receipetBO.empName = empName
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
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func deleteExpenseWith(strID:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["expenseId"] = strID as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)expenses/delete"
        obj.params = params
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String
                {
                    if error == "true"
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }

                    }
                    else
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            successMessage(message)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }

                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    
    public func createOrUpdateExpenseWith(strID:String,strAmt:String,strDescription:String,strImage:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["amount"] = strAmt as AnyObject
        params["description"] = strDescription as AnyObject
        params["image"] = strImage as AnyObject
        params["expenseId"] = strID as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)expenses/create"
        obj.params = params
        obj.doGetSOAPResponse {(success : Bool) -> Void in
            if !success
            {
                if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
            }
            else
            {
                if let error = obj.parsedDataDict["error"] as? String,let message = obj.parsedDataDict["message"] as? String
                {
                    if error == "true"
                    {
                        failureMessage(message)
                    }
                    else
                    {
                        successMessage(message)
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func updateStatusOfExpenseWith(strID:String,strStatus:String,strComment : String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["status"] = strStatus as AnyObject
        params["expenseId"] = strID as AnyObject
        params["comment"] = strComment as AnyObject

        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)expenses/update-status"
        obj.params = params
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        successMessage(message)
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }

    //MARK: - Travel
    public func getMyTravels(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)travels"
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [TravelBO]()
                            for receipt in data
                            {
                                let travelBO = TravelBO()
                                if let travelId = receipt["travelId"] as? String
                                {
                                    travelBO.travelId = travelId
                                }
                                if let from = receipt["from"] as? String
                                {
                                    travelBO.from = from
                                }
                                if let to = receipt["to"] as? String
                                {
                                    travelBO.to = to
                                }
                                if let date_of_journey = receipt["date_of_journey"] as? String
                                {
                                    travelBO.date_of_journey = date_of_journey
                                }
                                if let Description = receipt["description"] as? String
                                {
                                    travelBO.Description = Description
                                }
                                if let status = receipt["status"] as? String
                                {
                                    travelBO.status = status
                                }
                                if let uploadedDate = receipt["uploadedDate"] as? String
                                {
                                    travelBO.uploadedDate = uploadedDate
                                }
                                if let empId = receipt["empId"] as? String
                                {
                                    travelBO.empId = empId
                                }
                                if let empName = receipt["empName"] as? String
                                {
                                    travelBO.empName = empName
                                }
                                if let comment = receipt["comment"] as? String
                                {
                                    travelBO.comment = comment
                                }
                                arrData.append(travelBO)
                            }
                            successMessage(arrData)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                    
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getAllTravels(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)travels/all"
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [TravelBO]()
                            for receipt in data
                            {
                                let travelBO = TravelBO()
                                if let travelId = receipt["travelId"] as? String
                                {
                                    travelBO.travelId = travelId
                                }
                                if let from = receipt["from"] as? String
                                {
                                    travelBO.from = from
                                }
                                if let to = receipt["to"] as? String
                                {
                                    travelBO.to = to
                                }
                                if let date_of_journey = receipt["date_of_journey"] as? String
                                {
                                    travelBO.date_of_journey = date_of_journey
                                }
                                if let Description = receipt["description"] as? String
                                {
                                    travelBO.Description = Description
                                }
                                if let status = receipt["status"] as? String
                                {
                                    travelBO.status = status
                                }
                                if let uploadedDate = receipt["uploadedDate"] as? String
                                {
                                    travelBO.uploadedDate = uploadedDate
                                }
                                if let empId = receipt["empId"] as? String
                                {
                                    travelBO.empId = empId
                                }
                                if let empName = receipt["empName"] as? String
                                {
                                    travelBO.empName = empName
                                }
                                if let comment = receipt["comment"] as? String
                                {
                                    travelBO.comment = comment
                                }
                                arrData.append(travelBO)
                            }
                            successMessage(arrData)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                    
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func deleteTravelWith(strID:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["travelId"] = strID as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)travels/delete"
        obj.params = params
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            successMessage(message)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                    
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    
    public func createOrUpdateTravelWith(strId:String,strFrom:String,strTo:String,strJourneyDate:String,strDesc:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["from"] = strFrom as AnyObject
        params["to"] = strTo as AnyObject
        params["date_of_journey"] = strJourneyDate as AnyObject
        params["description"] = strDesc as AnyObject
        params["travelId"] = strId as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)travels/create"
        obj.params = params
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        successMessage(message)
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func updateStatusOfTravelWith(strID:String,strStatus:String,strComment : String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["status"] = strStatus as AnyObject
        params["travelId"] = strID as AnyObject
        params["comment"] = strComment as AnyObject
        
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)travels/update-status"
        obj.params = params
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
                        failureMessage(message)
                    }
                    else
                    {
                        successMessage(message)
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    //MARK: - Cheques
    public func getMyCheques(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)cheques/all"
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [ChequeBO]()
                            for receipt in data
                            {
                                let chequeBO = ChequeBO()
                                if let chequeId = receipt["chequeId"] as? String
                                {
                                    chequeBO.chequeId = chequeId
                                }
                                if let chequeNo = receipt["chequeNo"] as? String
                                {
                                    chequeBO.chequeNo = chequeNo
                                }
                                if let amount = receipt["amount"] as? String
                                {
                                    chequeBO.amount = amount
                                }
                                if let description = receipt["description"] as? String
                                {
                                    chequeBO.Description = description
                                }
                                if let invoice_image = receipt["invoice_image"] as? [String]
                                {
                                    chequeBO.invoice_image = invoice_image
                                }
                                if let cheque_image = receipt["cheque_image"] as? String
                                {
                                    chequeBO.cheque_image = cheque_image
                                }
                                if let chequeClearanceDate = receipt["chequeClearanceDate"] as? String
                                {
                                    chequeBO.chequeClearanceDate = chequeClearanceDate
                                }
                                if let status = receipt["status"] as? String
                                {
                                    chequeBO.status = status
                                }
                                if let approvedDate = receipt["approvedDate"] as? String
                                {
                                    chequeBO.approvedDate = approvedDate
                                }
                                if let uploadedDate = receipt["uploadedDate"] as? String
                                {
                                    chequeBO.uploadedDate = uploadedDate
                                }
                                if let empId = receipt["empId"] as? String
                                {
                                    chequeBO.empId = empId
                                }
                                if let empName = receipt["empName"] as? String
                                {
                                    chequeBO.empName = empName
                                }
                                arrData.append(chequeBO)
                            }
                            successMessage(arrData)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                    
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func getAllCheques(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)cheques/all"
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
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
                                    var arrData = [ChequeBO]()
                                    for receipt in data
                                    {
                                        let chequeBO = ChequeBO()
                                        if let chequeId = receipt["chequeId"] as? String
                                        {
                                            chequeBO.chequeId = chequeId
                                        }
                                        if let chequeNo = receipt["chequeNo"] as? String
                                        {
                                            chequeBO.chequeNo = chequeNo
                                        }
                                        if let amount = receipt["amount"] as? String
                                        {
                                            chequeBO.amount = amount
                                        }
                                        if let description = receipt["description"] as? String
                                        {
                                            chequeBO.Description = description
                                        }
                                        if let comment = receipt["comment"] as? String
                                        {
                                            chequeBO.comment = comment
                                        }
                                        if let invoice_image = receipt["invoice_image"] as? [String]
                                        {
                                            chequeBO.invoice_image = invoice_image
                                        }
                                        if let cheque_image = receipt["cheque_image"] as? String
                                        {
                                            chequeBO.cheque_image = cheque_image
                                        }
                                        if let chequeClearanceDate = receipt["chequeClearanceDate"] as? String
                                        {
                                            chequeBO.chequeClearanceDate = chequeClearanceDate
                                        }
                                        if let status = receipt["status"] as? String
                                        {
                                            chequeBO.status = status
                                        }
                                        if let approvedDate = receipt["approvedDate"] as? String
                                        {
                                            chequeBO.approvedDate = approvedDate
                                        }
                                        if let uploadedDate = receipt["uploadedDate"] as? String
                                        {
                                            chequeBO.uploadedDate = uploadedDate
                                        }
                                        if let empId = receipt["empId"] as? String
                                        {
                                            chequeBO.empId = empId
                                        }
                                        if let empName = receipt["empName"] as? String
                                        {
                                            chequeBO.empName = empName
                                        }
                                        arrData.append(chequeBO)
                                    }
                                    successMessage(arrData)
                                }
                                else
                                {
                                    failureMessage("No Data Found")
                                }
                            }
                        }
                        else if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                            
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                        
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                    
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func createOrUpdateChequeWith(strId:String,strAmount:String,strChequeNo:String,strChequeClearanceDate:String,strDesc:String,strCheque_image : String,arrImages : [String],successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["chequeNo"] = strChequeNo as AnyObject
        params["amount"] = strAmount as AnyObject
        params["chequeClearanceDate"] = strChequeClearanceDate as AnyObject
        params["description"] = strDesc as AnyObject
        params["cheque_image"] = strCheque_image as AnyObject
        params["chequeId"] = strId as AnyObject
        var str = "["
        
        for img in arrImages
        {
            if img != ""
            {
                str = str + "\"\(img)\","
            }
        }
        str.removeLast()
        str.append("]")
        params["invoice_image"] = str as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)cheques/create"
        obj.params = params
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        successMessage(message)
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func updateStatusOfChequeWith(strID:String,strStatus:String,strComment : String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["status"] = strStatus as AnyObject
        params["chequeId"] = strID as AnyObject
        params["comment"] = strComment as AnyObject
        
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)cheques/update-status"
        obj.params = params
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        successMessage(message)
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }

    //MARK: - Cities
    public func getAllOnlineTransactions(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)online-transactions/all"
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [TransactionBO]()
                            for onlineTrx in data
                            {
                                let onlineTrxBO = TransactionBO()
                                if let transId = onlineTrx["transId"] as? String
                                {
                                    onlineTrxBO.transId = transId
                                }
                                if let amount = onlineTrx["amount"] as? String
                                {
                                    onlineTrxBO.amount = amount
                                }
                                if let notes = onlineTrx["notes"] as? String
                                {
                                    onlineTrxBO.notes = notes
                                }
                                if let onlineTransactionId = onlineTrx["onlineTransactionId"] as? String
                                {
                                    onlineTrxBO.onlineTransactionId = onlineTransactionId
                                }
                                if let transactionDate = onlineTrx["transactionDate"] as? String
                                {
                                    onlineTrxBO.transactionDate = transactionDate
                                }
                                if let transactionImage = onlineTrx["transactionImage"] as? String
                                {
                                    onlineTrxBO.transactionImage = transactionImage
                                }
                                if let invoice = onlineTrx["invoice"] as? [String]
                                {
                                    onlineTrxBO.invoice = invoice
                                }
                                if let usedOtp = onlineTrx["usedOtp"] as? String
                                {
                                    onlineTrxBO.usedOtp = usedOtp
                                }
                                if let uploadedDate = onlineTrx["uploadedDate"] as? String
                                {
                                    onlineTrxBO.uploadedDate = uploadedDate
                                }
                                if let empId = onlineTrx["empId"] as? String
                                {
                                    onlineTrxBO.empId = empId
                                }
                                if let empName = onlineTrx["empName"] as? String
                                {
                                    onlineTrxBO.empName = empName
                                }

                                arrData.append(onlineTrxBO)
                            }
                            successMessage(arrData)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                    
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    public func createOrUpdateOnlineTransactionWith(strId:String,strAmount:String,strOnlineTransactionId:String,strTransactionDate:String,strNotes:String,strTransactionImage : String,arrImages : [String],strUsedOtp:String,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        var params = [String:AnyObject]()
        params["amount"] = strAmount as AnyObject
        params["onlineTransactionId"] = strOnlineTransactionId as AnyObject
        params["transactionDate"] = strTransactionDate as AnyObject
        params["notes"] = strNotes as AnyObject
        params["transactionImage"] = strTransactionImage as AnyObject
        
        var str = "["
        
        for img in arrImages
        {
            if img != ""
            {
                str = str + "\"\(img)\","
            }
        }
        str.removeLast()
        str.append("]")
        params["invoice"] = str as AnyObject
        params["usedOtp"] = strUsedOtp as AnyObject
        params["transId"] = strId as AnyObject
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "POST"
        obj._serviceURL = "\(BASE_URL)online-transactions/create"
        obj.params = params
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        successMessage(message)
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }
    //MARK: - Cities
    public func getAllCities(successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        let obj : HttpRequest = HttpRequest()
        obj.tag = ParsingConstant.Login.rawValue
        obj.MethodNamee = "GET"
        obj._serviceURL = "\(BASE_URL)city"
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
                        if let message = obj.parsedDataDict["message"] as? String
                        {
                            failureMessage(message)
                        }
                        else
                        {
                            failureMessage(self.SERVER_ERROR)
                        }
                    }
                    else
                    {
                        if let data = obj.parsedDataDict["data"] as? [[String:AnyObject]]
                        {
                            var arrData = [CityBO]()
                            for receipt in data
                            {
                                let cityBO = CityBO()
                                if let countryName = receipt["countryName"] as? String
                                {
                                    cityBO.countryName = countryName
                                }
                                if let countryCode = receipt["countryCode"] as? String
                                {
                                    cityBO.countryCode = countryCode
                                }
                                if let cityName = receipt["cityName"] as? String
                                {
                                    cityBO.cityName = cityName
                                }
                                if let cityCode = receipt["cityCode"] as? String
                                {
                                    cityBO.cityCode = cityCode
                                }
                                arrData.append(cityBO)
                            }
                            successMessage(arrData)
                        }
                        else
                        {
                            failureMessage("No Data Found")
                        }
                    }
                }
                else if let message = obj.parsedDataDict["message"] as? String
                {
                    failureMessage(message)
                }
                    
                else
                {
                    failureMessage(self.SERVER_ERROR)
                }
                
            }
        }
    }

    //MARK:- Image Uploading
    func uploadWith(imageData : Data,successMessage: @escaping (Any) -> Void , failureMessage : @escaping(Any) ->Void)
    {
        
        let strUrl = "\(BASE_URL)upload-image"
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
        request.addValue(TaksyKraftUserDefaults.getAccessToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body as Data?
        
        request.url = URL(string: webStringURL)!
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 120.0
        config.timeoutIntervalForResource = 120.0
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
                                    if let data = parsedDataDict["data"] as? String
                                    {
                                        successMessage(data)
                                    }
                                    else
                                    {
                                        failureMessage(self.SERVER_ERROR)
                                    }
                                }
                                else
                                {
                                    if let message = parsedDataDict["message"] as? String
                                    {
                                        failureMessage(message)
                                    }
                                    else
                                    {
                                        failureMessage(self.SERVER_ERROR)
                                    }
                                }
                            }
                            else if let message = parsedDataDict["message"] as? String
                            {
                                failureMessage(message)
                            }
                            else
                            {
                                failureMessage(self.SERVER_ERROR)
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
