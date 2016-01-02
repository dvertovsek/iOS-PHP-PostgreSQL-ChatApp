//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by MTLab on 02/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var time_sent: UILabel!
    
    @IBOutlet weak var sendMessageButton: UIButton!
}
