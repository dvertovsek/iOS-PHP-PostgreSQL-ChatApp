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
    
    @IBOutlet weak var birthdate: UILabel!
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var adminPic: UIImageView!

}
