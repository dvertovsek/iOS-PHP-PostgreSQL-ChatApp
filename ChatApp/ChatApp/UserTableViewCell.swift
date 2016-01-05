//
//  UserTableViewCell.swift
//  ChatApp
//
//  Created by MTLab on 02/01/16.
//  Copyright © 2016 tbp. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var first_name: UILabel!
    @IBOutlet weak var last_name: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var adminPic: UIImageView!
    
    @IBOutlet weak var sendFriendReqButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
//    Request
    @IBOutlet weak var viewProfileButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    
//    Block view
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var deblockButtom: UIButton!
    
}
