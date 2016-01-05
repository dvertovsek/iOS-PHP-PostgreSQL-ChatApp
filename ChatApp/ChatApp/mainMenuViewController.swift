//
//  mainMenuViewController.swift
//  ChatApp
//
//  Created by MTLab on 01/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

import ws
import core

class mainMenuViewController: UIViewController {
    
    var httpReq: HTTPRequest?
    var userDeactivated : Bool = false
    
    var findUsersButton : UIBarButtonItem?
    var requestsButton : UIBarButtonItem?
    var settingsButton : UIBarButtonItem?
    var blockButton : UIBarButtonItem?
    
    @IBOutlet weak var logAdminButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.toolbarHidden = false
        let logoutButton = UIBarButtonItem(image: UIImage(named: "log-out-32"), style: UIBarButtonItemStyle.Plain, target: self, action: "onLogoutButtonPressed")
        
        findUsersButton = UIBarButtonItem(image: UIImage(named: "users"), style: UIBarButtonItemStyle.Plain, target: self, action: "onFindUsersButtonPressed")
        
        requestsButton = UIBarButtonItem(image: UIImage(named: "request"), style: UIBarButtonItemStyle.Plain, target: self, action: "onRequestsButtonPressed")
        
        settingsButton = UIBarButtonItem(image: UIImage(named: "settings"), style: UIBarButtonItemStyle.Plain, target: self, action: "onSettingsButtonPressed")
        
        blockButton = UIBarButtonItem(image: UIImage(named: "block"), style: UIBarButtonItemStyle.Plain, target: self, action: "onBlockButtonPressed")
        
        blockButton!.enabled = (NSUserDefaults.standardUserDefaults().stringForKey("user_id") == "1" ? true : false)
        
        self.navigationItem.rightBarButtonItems = [logoutButton, requestsButton!, findUsersButton!, settingsButton!, blockButton!]
        
        httpReq = HTTPRequest(delegate: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        
        if(!isUserLoggedIn)
        {
            self.performSegueWithIdentifier("loginView", sender: self)
        }
        
        findUsersButton!.enabled = (NSUserDefaults.standardUserDefaults().stringForKey("user_status_id") == "1" ? true : false)
        
        requestsButton!.enabled = (NSUserDefaults.standardUserDefaults().stringForKey("user_status_id") == "1" ? true : false)
        
        settingsButton!.enabled = (NSUserDefaults.standardUserDefaults().stringForKey("user_status_id") == "1" ? true : false)
        
        blockButton!.enabled = (NSUserDefaults.standardUserDefaults().stringForKey("user_status_id") == "1" ? true : false)
        blockButton!.enabled = (NSUserDefaults.standardUserDefaults().stringForKey("user_id") == "1" ? true : false)
        
        logAdminButton!.enabled = (NSUserDefaults.standardUserDefaults().stringForKey("user_id") == "1" ? true : false)
    }
    @IBAction private func onRequestsButtonPressed()
    {
        self.performSegueWithIdentifier("requestView", sender: self)
    }
    
    @IBAction private func onFindUsersButtonPressed()
    {
        self.performSegueWithIdentifier("findUsersView", sender: self)
    }
    
    @IBAction private func onSettingsButtonPressed()
    {
        self.performSegueWithIdentifier("settingsView", sender: self)
    }
    
    @IBAction private func onBlockButtonPressed()
    {
        self.performSegueWithIdentifier("blockView", sender: self)
    }
    
    
    @IBAction func onActivateAccButtonPressed() {
        
        let params = [
            "method" : "changeUserStatus",
            "new_status_id" : "1",
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!
        ]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/users", params: params)
        
        userDeactivated = false
    }
    
    @IBAction func onDeactivateAccButtonPressed() {
        let params = [
            "method" : "changeUserStatus",
            "new_status_id" : "3",
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!
        ]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/users", params: params)
        userDeactivated = true
    }
    
    
    @IBAction private func onLogoutButtonPressed()
    {
        let params = [
            "method" : "logOut",
            "username" : NSUserDefaults.standardUserDefaults().stringForKey("username")!
        ]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/login", params: params)
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_id")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("imgUrl")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_type_id")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_status_id")
        
        self.performSegueWithIdentifier("loginView", sender: self)

    }
    
}

extension mainMenuViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        if let statusCode = JsonAdapter.getErrorInfo(result)["errNo"]
        {
            if statusCode != "200"
            {
                let title = "Status change error"
                
                let alert = UIAlertController(title: title, message: statusCode, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                presentViewController(alert, animated: true, completion: nil)
                
                userDeactivated = false
            }
            else
            {
                if userDeactivated
                {
                    NSUserDefaults.standardUserDefaults().setValue("3", forKey: "user_status_id")
                    findUsersButton!.enabled = false
                    requestsButton!.enabled  = false
                    settingsButton!.enabled = false
                    blockButton!.enabled = false
                }
                else
                {
                    NSUserDefaults.standardUserDefaults().setValue("1", forKey: "user_status_id")
                    findUsersButton!.enabled = true
                    requestsButton!.enabled  = true
                    settingsButton!.enabled = true
                    blockButton!.enabled = (NSUserDefaults.standardUserDefaults().stringForKey("user_id") == "1" ? true : false)
                }
            }
        }
    }
}
