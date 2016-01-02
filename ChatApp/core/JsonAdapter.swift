//
//  JsonAdapter.swift
//  ChatApp
//
//  Created by MTLab on 01/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import SwiftyJSON

import data

public class JsonAdapter
{
    public static func getLoginInfo(json: AnyObject) -> [String:String]
    {
        let json = JSON(json)
        
        let statusCode = String(json["errNo"])
        
        return ["errNo":statusCode]
    }
    
    public static func getUsers(json: AnyObject) -> [User]
    {
        let json = JSON(json)
        
        var usersArray = [User]()
        
        let users = json["users"]
        
        for (key, value) in users {

            var u:User = User(
                user_id: value["user_id"].int!,
                imgUrl: value["imgUrl"].string!,
                username: value["username"].string!,
                first_name: value["first_name"].string!,
                last_name: value["last_name"].string!,
                location: value["location"].string!,
                online: value["on_line"].boolValue,
                user_status_id: value["user_status_id"].int!,
                user_type_id: value["user_type_id"].int!
            )
            
            usersArray.append(u)
        }
        return usersArray
    }

}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}