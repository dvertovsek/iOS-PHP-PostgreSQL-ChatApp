//
//  ViewController.swift
//  ChatApp
//
//  Created by MTLab on 30/12/15.
//  Copyright © 2015 tbp. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func uploadButtonTapped(sender: UIButton) {
        
//        myImageUploadRequest();
        
        var parameters = [
            "task": "task",
            "variable1": "var"
        ]
        
        // add addtionial parameters
//        parameters["userId"] = "1234"
        
        // example image data
        let image = myImageView.image
        let imageData = UIImagePNGRepresentation(image!)
        
        
        
        // CREATE AND SEND REQUEST ----------
        
        let urlRequest = urlRequestWithComponents("https://chat-dare1234.rhcloud.com/uploadImg", parameters: parameters, imageData: imageData!)
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { response in
                print(response)
        }
    }
    
    
    @IBAction func selectPicButtonTapped(sender: UIButton) {
        
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//        myPickerController.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
        
    }
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
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
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
        
    {
        myImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
//
//    func myImageUploadRequest()
//    {
//        
//        let myUrl = NSURL(string: "http://www.swiftdeveloperblog.com/http-post-example-script/");
//        //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
//        
//        let request = NSMutableURLRequest(URL:myUrl!);
//        request.HTTPMethod = "POST";
//        
//        let param = [
//            "firstName"  : "Darijan",
//            "lastName"    : "Dare",
//            "userId"    : "9"
//        ]
//        
//        let boundary = generateBoundaryString()
//        
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        
//        let imageData = UIImageJPEGRepresentation(myImageView.image!, 1)
//        
//        if(imageData==nil)  { return; }
//        
//        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
//        
//        
//        
//        myActivityIndicator.startAnimating();
//        
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
//            data, response, error in
//            
//            if error != nil {
//                print("error=\(error)")
//                return
//            }
//            
//            // You can print out response object
//            print("******* response = \(response)")
//            
//            // Print out reponse body
//            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("****** response data = \(responseString!)")
//            
//            var err: NSError?
//            var json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
//            
//            
//            
//            dispatch_async(dispatch_get_main_queue(),{
//                self.myActivityIndicator.stopAnimating()
//                self.myImageView.image = nil;
//            });
//            
//            /*
//            if let parseJSON = json {
//            var firstNameValue = parseJSON["firstName"] as? String
//            println("firstNameValue: \(firstNameValue)")
//            }
//            */
//            
//        }
//        
//        task.resume()
//        
//    }
//    
//    
//    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
//        var body = NSMutableData();
//        
//        if parameters != nil {
//            for (key, value) in parameters! {
//                body.appendString("--\(boundary)\r\n")
//                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//                body.appendString("\(value)\r\n")
//            }
//        }
//        
//        let filename = "user-profile.jpg"
//        
//        let mimetype = "image/jpg"
//        
//        body.appendString("--\(boundary)\r\n")
//        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
//        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
//        body.appendData(imageDataKey)
//        body.appendString("\r\n")
//        
//        
//        
//        body.appendString("--\(boundary)--\r\n")
//        
//        return body
//    }
//    
//    
//    
//    
//    func generateBoundaryString() -> String {
//        return "Boundary-\(NSUUID().UUIDString)"
//    }
    
    
    
}

//extension NSMutableData {
//    
//    func appendString(string: String) {
//        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
//        appendData(data!)
//    }
//}

