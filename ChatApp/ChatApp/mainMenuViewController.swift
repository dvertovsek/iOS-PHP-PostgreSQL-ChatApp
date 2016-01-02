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
        
        self.navigationController?.toolbarHidden = false
        let logoutButton = UIBarButtonItem(image: UIImage(named: "log-out-32"), style: UIBarButtonItemStyle.Plain, target: self, action: "onLogoutButtonPressed")
        
        let findUsersButton = UIBarButtonItem(image: UIImage(named: "users"), style: UIBarButtonItemStyle.Plain, target: self, action: "onFindUsersButtonPressed")
        
        self.navigationItem.rightBarButtonItems = [findUsersButton, logoutButton]
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let isUserLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("isUserLoggedIn")
        
        if(!isUserLoggedIn)
        {
            self.performSegueWithIdentifier("loginView", sender: self)
        }
        
    }
    
    @IBAction private func onFindUsersButtonPressed()
    {
        self.performSegueWithIdentifier("findUsersView", sender: self)
    }
    
    @IBAction private func onLogoutButtonPressed()
    {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isUserLoggedIn")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_id")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.performSegueWithIdentifier("loginView", sender: self)

    }
    
}
