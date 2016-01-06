//
//  MessageTableViewController.swift
//  ChatApp
//
//  Created by MTLab on 05/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

import ws
import core
import data

class MessageTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageTxtField: UITextField!
    
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    
    var private_messages: [Message]?

    var httpReq: HTTPRequest?
    
    var Useruser_id: String?
    var Userusername: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        navigationItem.title = "Conversation with " + Userusername!
        httpReq = HTTPRequest(delegate: self)
        
        let params = [
            "method" : "getAll",
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!,
            "user_id" : Useruser_id!
        ]
        
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/messages", params: params)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 400
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func onSendMessageButtonPressed() {
        
        let params = [
            "method" : "sendPrivateMessage",
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!,
            "user_id" : Useruser_id!,
            "message_text" : messageTxtField.text!
        ]
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/messages", params: params)
    }

}

extension MessageTableViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if private_messages?.count > 0
        {
            return (private_messages?.count)!
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let priv_message = private_messages![indexPath.row]
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        cell.userProfilePic.kf_setImageWithURL(NSURL(string: priv_message.profilePicUrl)!)
        cell.username.text = priv_message.username
        cell.messageText.text = priv_message.message_text
        cell.time_sent.text = priv_message.time_sent
        
        if(priv_message.username == NSUserDefaults.standardUserDefaults().stringForKey("username")!)
        {
            cell.backgroundColor = UIColor(red: 125/255, green: 108/255, blue: 255/255, alpha: 1)
        }
        else
        {
             cell.backgroundColor = UIColor.purpleColor()
        }
                
        return cell
    }
}

extension MessageTableViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {

        let statusCode = JsonAdapter.getErrorInfo(result)["errNo"]
        
        if statusCode != "200"
        {
            let title = "Message send error"
            
            let alert = UIAlertController(title: title, message: statusCode, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            private_messages = JsonAdapter.getMessages(result)
            tableView.reloadData()
        }
    }
}
