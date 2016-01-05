//
//  LogTableViewController.swift
//  ChatApp
//
//  Created by MTLab on 05/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

import ws
import core
import data

class LogTableViewController: UITableViewController {

    var httpReq : HTTPRequest?
    
    var logArray: [LogEntry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        httpReq = HTTPRequest(delegate: self)
        httpReq?.httprequest("https://chat-dare1234.rhcloud.com/login", params: ["method" : "appLog"])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if logArray?.count > 0
        {
            return (logArray?.count)!
        }
        return 0
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
        
        let user = logArray![indexPath.row]
        
        cell.userProfilePic.kf_setImageWithURL(NSURL(string:user.imgUrl)!)
        
        cell.username.text = user.username + "," + user.description + " at " + user.log_time
        
        return cell
    }
}

extension LogTableViewController: WebServiceResultDelegate
{
    func getResult(result: AnyObject) {
        logArray = JsonAdapter.getLogEntry(result)
        tableView.reloadData()
    }
}