//
//  BlockUsersTableView.swift
//  ChatApp
//
//  Created by MTLab on 04/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

import ws
import data
import core

class BlockUsersTableView: UITableViewController {

    var usersArray: [User]?
    
    var httpReq: HTTPRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Users to block"
        
        httpReq = HTTPRequest(delegate: self)
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/users", params: ["method":"getAll"])
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if usersArray?.count > 0
        {
            return (usersArray?.count)!
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
        
        let user = usersArray![indexPath.row]
        
        cell.userProfilePic.kf_setImageWithURL(NSURL(string:user.imgUrl)!)
        cell.username.text = user.username
        cell.blockButton.addTarget(self, action: "onBlockButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.deblockButtom.addTarget(self, action: "ondeblockButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func onBlockButtonPressed(sender:UIButton!)
    {
        
        let cell = sender.superview?.superview as! UserTableViewCell
        let indexPath = tableView.indexPathForCell(cell)
            
        let params = [
            "method" : "changeUserStatus",
            "new_status_id" : "2",
            "sender_user_id" : String(usersArray![indexPath!.row].user_id)
        ]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/users", params: params)
    }
 
    func ondeblockButtonPressed(sender:UIButton!)
    {
        
        let cell = sender.superview?.superview as! UserTableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        let params = [
            "method" : "changeUserStatus",
            "new_status_id" : "1",
            "sender_user_id" : String(usersArray![indexPath!.row].user_id)
        ]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/users", params: params)
    }

}

extension BlockUsersTableView: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        
        let statusCode = JsonAdapter.getErrorInfo(result)["errNo"]
        
        if statusCode != "null"
        {
            let message = (statusCode == "200" ? "Status change successful!" : statusCode)
            let alert = UIAlertController(title: "Notice", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
            presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            usersArray = JsonAdapter.getUsers(result)
            tableView.reloadData()
        }
    }
}
