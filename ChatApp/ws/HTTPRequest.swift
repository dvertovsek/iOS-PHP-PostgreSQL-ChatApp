//
//  HTTPRequest.swift
//  ChatApp
//
//  Created by MTLab on 01/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import Alamofire

public protocol WebServiceResultDelegate
{
    func getResult(result: AnyObject)
}

public class HTTPRequest
{
    private var delegate: WebServiceResultDelegate?
    
    public init(delegate: WebServiceResultDelegate)
    {
        self.delegate = delegate
    }
    
    public func httprequest(url: String, params: [String:String])
    {
        Alamofire.request(.POST, url, parameters: params)
            .responseJSON { response in
                if let json = response.result.value{
                    
                    self.delegate?.getResult(json)
                    
                }
        }
    }
}
