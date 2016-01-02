//
//  UsersViewController.swift
//  ChatApp
//
//  Created by MTLab on 02/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit
import Kingfisher

import ws
import data
import core

class UsersViewController: UITableViewController {
    
    var usersArray: [User]?
    
    var httpReq: HTTPRequest?

    override func viewDidLoad() {
        super.viewDidLoad()

        httpReq = HTTPRequest(delegate: self)
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/users", params: ["method":"getAll"])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if usersArray?.count > 0
        {
            return (usersArray?.count)!
        }
        return 0
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
        
        let user = usersArray![indexPath.row]

        cell.userProfilePic.kf_setImageWithURL(NSURL(string:user.imgUrl)!)

        cell.username.text = user.username
        cell.first_name.text = user.first_name
        cell.last_name.text = user.last_name
        cell.location.text = user.location
        
        cell.adminPic.image = (user.user_type_id == 1 ? (UIImage(named: "admin")) : nil )
        
        return cell
    }

    
}

extension UsersViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        
        self.usersArray = JsonAdapter.getUsers(result)
        tableView.reloadData()
    }
}
