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

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
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
        
        navigationItem.title = "Conversation with " + Userusername!
        httpReq = HTTPRequest(delegate: self)
        
        let params = [
            "method" : "getAll",
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!,
            "user_id" : Useruser_id!
        ]
        
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/messages", params: params)
    }
    
    
    @IBAction func onSendMessageButtonPressed() {
        
        let params = [
            "method" : "sendPrivateMessage",
            "sender_user_id" : NSUserDefaults.standardUserDefaults().stringForKey("user_id")!,
            "user_id" : Useruser_id!,
            "message_text" : messageTextField.text!
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
             cell.backgroundView?.backgroundColor = UIColor(red: 125, green: 108, blue: 255, alpha: 1)
        }
        else
        {
             cell.backgroundView?.backgroundColor = UIColor(red: 125, green: 108, blue: 67, alpha: 1)
        }
                
        return cell
    }
}

extension MessageTableViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        private_messages = JsonAdapter.getMessages(result)
        tableView.reloadData()
    }
}
