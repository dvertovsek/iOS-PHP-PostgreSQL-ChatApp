//
//  RequestViewController.swift
//  ChatApp
//
//  Created by MTLab on 03/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit
import Kingfisher

import ws
import data
import core

class RequestViewController: UITableViewController {
    
    var requestArray: [User]?
    
    var httpReq: HTTPRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Requests"
        
        httpReq = HTTPRequest(delegate: self)
        let params = [
            "method" : "getAll",
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!
        ]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/requests", params: params)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if requestArray?.count > 0
        {
            return (requestArray?.count)!
        }
        return 0
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 146
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
        
        let user = requestArray![indexPath.row]
        
        cell.userProfilePic.kf_setImageWithURL(NSURL(string:user.imgUrl)!)
        
        cell.username.text = user.username
        cell.first_name.text = user.first_name + " " + user.last_name + "," + user.location
        
        cell.viewProfileButton.addTarget(self, action: "onViewProfileButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.acceptButton.addTarget(self, action: "onUpdateRequestButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.denyButton.addTarget(self, action: "onUpdateRequestButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func onViewProfileButtonPressed(sender:UIButton!)
    {
        performSegueWithIdentifier("showProfilePage", sender: sender)
    }
    
    func onUpdateRequestButtonPressed(sender:UIButton!)
    {
        let cell = sender.superview?.superview as! UserTableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        let params = [
            "method" : "updateRequest",
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!,
            "user_id" : String((self.requestArray![indexPath!.row].user_id)),
            "isAccepted" : (sender.titleLabel?.text! == "Accept" ? "true" : "false")
        ]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/requests", params: params)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destination = segue.destinationViewController as? ProfilePageViewController {
            let buttonSender = sender as! UIButton
            let cell = buttonSender.superview?.superview as! UserTableViewCell
            let userIndex = tableView.indexPathForCell(cell)
            
            destination.user = self.requestArray![userIndex!.row]
        }
    }
    
}

extension RequestViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        
        self.requestArray = JsonAdapter.getUsers(result)
        tableView.reloadData()
    }
}
