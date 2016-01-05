//
//  User.swift
//  ChatApp
//
//  Created by MTLab on 02/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

public class User {
    
    public var user_id: Int
    
    public var imgUrl: String
    
    public var username: String
    public var first_name: String
    public var last_name: String
    public var location: String
    
    public var online: Bool
    public var user_status_id: Int
    public var user_type_id: Int
    
    public init(user_id: Int, imgUrl: String, username: String, first_name: String, last_name: String, location: String, online: Bool, user_status_id: Int, user_type_id: Int)
    {
        self.user_id = user_id
        
        self.imgUrl = imgUrl
        
        self.username = username
        self.first_name = first_name
        self.last_name = last_name
        self.location = location
        
        self.online = online
        self.user_status_id = user_status_id
        self.user_type_id = user_type_id
    }
    
}
