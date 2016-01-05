//
//  LoginViewController.swift
//  ChatApp
//
//  Created by MTLab on 01/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit
import ws
import core

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var httpReq: HTTPRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        httpReq = HTTPRequest(delegate: self)
    }
    
    
    @IBAction func onSignInButtonPressed(sender: UIButton) {
        
        if usernameTextField.text != "" && passTextField.text != ""
        {
                let username = usernameTextField.text!
                let pass = passTextField.text!
            
                let loginParams = ["method" : "logIn", "username" : username, "password": pass]

                httpReq?.httprequest("https://chat-dare1234.rhcloud.com/login", params: loginParams)
                
                activityIndicator.startAnimating()
        }
        
    }
    
}

extension LoginViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        
        activityIndicator.stopAnimating()
        
        var loginResultInfo = JsonAdapter.getLoginInfo(result)
        
        if(loginResultInfo["errNo"] != "200")
        {
            let title = "Login error"
            let message = loginResultInfo["errNo"]
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
            
            usernameTextField.text = ""
            passTextField.text = ""
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn")
            NSUserDefaults.standardUserDefaults().setValue(loginResultInfo["user_id"], forKey: "user_id")
            NSUserDefaults.standardUserDefaults().setValue(usernameTextField.text, forKey: "username")
            NSUserDefaults.standardUserDefaults().setValue(loginResultInfo["imgUrl"], forKey: "imgUrl")
            NSUserDefaults.standardUserDefaults().setValue(loginResultInfo["user_type_id"], forKey: "user_type_id")
            NSUserDefaults.standardUserDefaults().setValue(loginResultInfo["user_status_id"], forKey: "user_status_id")
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}