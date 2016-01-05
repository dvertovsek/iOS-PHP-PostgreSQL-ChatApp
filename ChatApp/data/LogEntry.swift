//
//  LogEntry.swift
//  ChatApp
//
//  Created by MTLab on 05/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

public class LogEntry {
    

    public var imgUrl: String
    
    public var username: String
    public var description: String
    
    public var log_time: String
    
    public init(imgUrl: String, username: String, description: String, log_time: String)
    {
        self.imgUrl = imgUrl
        
        self.username = username
        self.description = description
        self.log_time = log_time
    }
    
}