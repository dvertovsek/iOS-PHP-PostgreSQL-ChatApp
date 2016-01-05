//
//  SettingsViewController.swift
//  ChatApp
//
//  Created by MTLab on 04/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

import ws
import core

class SettingsViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var httpReq: HTTPRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        
        usernameTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("username")!
        profileImageView.kf_setImageWithURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("imgUrl")!)!)
        
        httpReq = HTTPRequest(delegate: self)
    }
    
    @IBAction func onChangeUsernameButtonPressed() {
        
        let params = [
            "method" : "changeUsername",
            "new_username" : usernameTextField.text!,
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!
        ]
        
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/users", params: params)
    }
    
    @IBAction func OnSelectPictureButtonPressed() {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //        myPickerController.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(myPickerController, animated: true, completion: nil)

        
    }
    
    @IBAction func onChangePictureButtonPressed() {
        
        let parameters = [
            "sender_user_id": NSUserDefaults.standardUserDefaults().stringForKey("user_id")!
        ]
        
        httpReq?.uploadImg(profileImageView.image!, parameters: parameters)
        
    }
    
}

extension SettingsViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        
        let resultDict = JsonAdapter.getErrorInfo(result)
        
        if let statusCode = resultDict["errNo"]
        {
            var message = ""
            if statusCode == "200"
            {
                NSUserDefaults.standardUserDefaults().setValue(usernameTextField.text!, forKey: "username")
                message = "Username changed!"
            }
            else if statusCode == "300"
            {
                NSUserDefaults.standardUserDefaults().setValue(resultDict["imgUrl"], forKey: "imgUrl")
                message = "Image changed!"
            }
            else if statusCode != "200" && statusCode != "300"
            {
                message = statusCode
                usernameTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("username")
            }
            let title = "Notice"
                
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    
    {
        profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
