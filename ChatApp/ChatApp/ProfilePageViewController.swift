//
//  ProfilePageViewController.swift
//  ChatApp
//
//  Created by MTLab on 02/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

import data
import ws
import core

class ProfilePageViewController: UITableViewController {

    var user: User?

    var public_messages: [Message]?
    
    var httpReq: HTTPRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = user!.username+"'s profile"
        
        httpReq = HTTPRequest(delegate: self)
        
        let params = ["method":"getAllPublic", "user_id":String((user?.user_id)!)]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/messages", params: params)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 2){
            if public_messages?.count > 0
            {
                return (public_messages?.count)!
            }
            return 0
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1 || indexPath.section == 2){
            return 80
        }
        return 223
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        cell.userInteractionEnabled = false

        if indexPath.section == 0
        {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
            
            cell.userProfilePic.kf_setImageWithURL(NSURL(string:user!.imgUrl)!)
            
            cell.username.text = user!.username
            cell.first_name.text = user!.first_name
            cell.last_name.text = user!.last_name
            cell.location.text = user!.location
            
            cell.adminPic.image = (user!.user_type_id == 1 ? (UIImage(named: "admin")) : nil )
            
            cell.sendFriendReqButton.addTarget(self, action: "onSendFriendReqButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.messageButton.addTarget(self, action: "onMessageButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            return cell
        }
        else if indexPath.section == 1
        {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("sendMessageCell", forIndexPath: indexPath) as! MessageTableViewCell
            
            cell.userProfilePic.kf_setImageWithURL(NSURL(string: NSUserDefaults.standardUserDefaults().valueForKey("imgUrl") as! String)!)
            cell.username.text = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
            
            cell.sendMessageButton.addTarget(self, action: "onSendMessageButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            return cell
        }
        else
        {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! MessageTableViewCell
            
            let message = public_messages![indexPath.row]
            
            cell.username.text = message.username
            cell.userProfilePic.kf_setImageWithURL(NSURL(string: message.profilePicUrl)!)
            cell.messageText.text = message.message_text
            
            cell.time_sent.text = message.time_sent
            
            return cell
        }
    }
    
    func onSendFriendReqButtonPressed(sender:UIButton!)
    {
        let alert = UIAlertController(title: "Send a friend request", message: "Enter a hello message!", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Hi! Accept me as friend."
        })
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Send", style: .Default, handler:
            { (action) -> Void in
                
                let textField = alert.textFields![0] as UITextField
                print("Text field: \(textField.text)")
                let params = [
                    "method" : "sendRequest",
                    "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!,
                    "user_id" : String((self.user?.user_id)!),
                    "hello_message" : textField.text!
                ]
                self.httpReq?.httprequest("https://chat-dare1234.rhcloud.com/requests", params: params)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func onMessageButtonPressed(sender:UIButton!)
    {
        performSegueWithIdentifier("showMessageView", sender: self)
    }
    
    func onSendMessageButtonPressed(sender:UIButton!)
    {
        
        let cell = sender.superview?.superview as! MessageTableViewCell
        let message_text = cell.messageText.text
        cell.messageText.text = ""
        if message_text != ""
        {
            let params = [
                "method" : "sendPublicMessage",
                "user_id" : String((user?.user_id)!),
                "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!,
                "message_text" : message_text!
            ]

            httpReq?.httprequest("https://chat-dare1234.rhcloud.com/messages", params: params)
        }
    }
    
}

extension ProfilePageViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        
        public_messages = JsonAdapter.getMessages(result)
        if public_messages!.count > 0
        {
            tableView.reloadData()
        }
        else
        {
            let message = JsonAdapter.getErrorInfo(result)["errNo"]
            
            if message != "200"
            {
                let title = "Notice"
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}
