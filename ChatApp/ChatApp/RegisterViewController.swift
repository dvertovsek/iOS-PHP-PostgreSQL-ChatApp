//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by MTLab on 01/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

import ws
import core

class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var passTxtField: UITextField!
    
    var httpReq: HTTPRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        httpReq = HTTPRequest(delegate: self)
    }
    
    @IBAction func signUpButtonPressed() {
        
        let params = [
            "method" : "registerUser",
            "username" : usernameTxtField.text!,
            "first_name" : firstNameTxtField.text!,
            "last_name" : lastNameTxtField.text!,
            "location" : locationTextField.text!,
            "password" : passTxtField.text!
        ]
        
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/users", params: params)
    }
    
    @IBAction func loginButtonPressed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension RegisterViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        if let statusCode = JsonAdapter.getErrorInfo(result)["errNo"]
        {
            if statusCode == "200"
            {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else
            {
                let title = "Register error"
                
                let alert = UIAlertController(title: title, message: statusCode, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}
