//
//  UserBO.swift
//  TaksyKraft
//
//  Created by Nikhilesh on 05/07/17.
//  Copyright © 2017 TaksyKraft. All rights reserved.
//

import UIKit

public class UserBO: NSObject, NSCoding {
    public var id = 0
    public var name = ""
    public var empId = ""
    public var mobile = ""
    public var designation = ""
    public var bloodGroup = ""
    public var role = ""
    public var profile_image = ""
    public init(Id: Int, strname: String, strempId: String, strmobile: String, strdesignation: String, strbloodGroup: String, strrole: String, strprofile_image: String) {
        self.id = Id
        self.name = strname
        self.empId = strempId
        self.mobile = strmobile
        self.designation = strdesignation
        self.bloodGroup = strbloodGroup
        self.role = strrole
        self.profile_image = strprofile_image
    }
    required public init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.id = decoder.decodeInteger(forKey: "id")
        self.empId = decoder.decodeObject(forKey: "empId") as? String ?? ""
        self.mobile = decoder.decodeObject(forKey: "mobile") as? String ?? ""
        self.designation = decoder.decodeObject(forKey: "designation") as? String ?? ""
        self.bloodGroup = decoder.decodeObject(forKey: "bloodGroup") as? String ?? ""
        self.role = decoder.decodeObject(forKey: "role") as? String ?? ""
        self.profile_image = decoder.decodeObject(forKey: "profile_image") as? String ?? ""

    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(id, forKey: "id")
        coder.encode(empId, forKey: "empId")
        coder.encode(mobile, forKey: "mobile")
        coder.encode(designation, forKey: "designation")
        coder.encode(bloodGroup, forKey: "bloodGroup")
        coder.encode(role, forKey: "role")
        coder.encode(profile_image, forKey: "profile_image")
    }

}
