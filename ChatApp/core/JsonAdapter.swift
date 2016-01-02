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
        let us_id = String(json["user_id"])
        let imgUrl = String(json["imgUrl"])
        
        return ["errNo":statusCode, "user_id":us_id, "imgUrl":imgUrl]
    }
    
    public static func getUsers(json: AnyObject) -> [User]
    {
        let json = JSON(json)
        
        var usersArray = [User]()
        
        let users = json["users"]
        for (_, value) in users {

            let u:User = User(
                user_id: value["user_id"].int!,
                imgUrl: value["imgUrl"].string!,
                username: value["username"].string!,
                first_name: value["first_name"].string!,
                last_name: value["last_name"].string!,
                location: value["location"].string!,
                email: value["email"].string!,
                bdate: value["birthdate"].string!,
                online: value["on_line"].boolValue,
                user_status_id: value["user_status_id"].int!,
                user_type_id: value["user_type_id"].int!
            )
            
            usersArray.append(u)
        }
        return usersArray
    }

    public static func getMessages(json: AnyObject) -> [Message]
    {
        let json = JSON(json)
        
        var messArray = [Message]()
        
        let messages = json["messages"]
        
        if(String(json["errNo"]) == "200")
        {
            for(_, value) in messages
            {
                let m = Message(
                    username: value["username_from"].string!,
                    message_text: value["message_text"].string!,
                    time_sent: value["time_sent"].string!,
                    profilePicUrl: value["imgUrl"].string!
                )
                
                messArray.append(m)
            }
        }
        
        return messArray
    }
    
    public static func getErrorInfo(json: AnyObject) -> [String:String]
    {
        let json = JSON(json)
        
        let statusCode = String(json["errNo"])
        
        return ["errNo":statusCode]
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