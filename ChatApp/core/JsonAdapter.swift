//
//  JsonAdapter.swift
//  ChatApp
//
//  Created by MTLab on 01/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import SwiftyJSON

public class JsonAdapter
{
    public static func getLoginInfo(json: AnyObject) -> [String:String]
    {
        let json = JSON(json)
        
        let statusCode = String(json["errNo"])
        
        return ["errNo":statusCode]
    }
    
    

}