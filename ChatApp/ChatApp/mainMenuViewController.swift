//
//  mainMenuViewController.swift
//  ChatApp
//
//  Created by MTLab on 01/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

class mainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        
        if(!isUserLoggedIn)
        {
            self.performSegueWithIdentifier("loginView", sender: self)
        }
        
    }
    
    @IBAction func onLogoutButtonPressed(sender: UIBarButtonItem) {
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_id")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.performSegueWithIdentifier("loginView", sender: self)
        
    }
    
}
