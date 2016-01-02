//
//  Message.swift
//  ChatApp
//
//  Created by MTLab on 02/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

public class Message
{
    public var username: String
    public var message_text: String
    public var time_sent: String
    
    public var profilePicUrl: String
    
    public init(username: String, message_text: String,time_sent: String, profilePicUrl: String)
    {
        self.username = username
        self.message_text = message_text
        self.time_sent = time_sent
        self.profilePicUrl = profilePicUrl
    }
}
