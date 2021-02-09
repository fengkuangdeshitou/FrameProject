//
//  VisualDetailsTableCellPic.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/23.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class VisualDetailsTableCellPic: UITableViewCell {
    
    @IBOutlet var picImage: UIImageView!
    @IBOutlet var pm25Label: UILabel!
    @IBOutlet var giveLikeLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    
    @IBOutlet var giveLikeLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var commentsLayoutConstraint: NSLayoutConstraint!
}



