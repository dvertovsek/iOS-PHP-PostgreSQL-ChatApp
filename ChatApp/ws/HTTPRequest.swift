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
    
    public func uploadImg(image: UIImage, parameters: [String:String])
    {
        // add addtionial parameters
        //        parameters["userId"] = "1234"
        
        // example image data
        let imageData = UIImagePNGRepresentation(image)
        
        
        
        // CREATE AND SEND REQUEST ----------
        
        let urlRequest = urlRequestWithComponents("https://chat-dare1234.rhcloud.com/uploadImg", parameters: parameters, imageData: imageData!)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { response in
                self.delegate?.getResult(response.result.value!)
        }
    }
    
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    private func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }

}
