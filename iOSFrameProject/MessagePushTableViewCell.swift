//
//  MessagePushTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/16.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MessagePushTableViewCell: UITableViewCell {
    
    static let CELL_ID = "cell"
    static let CELL_HEIGHT: CGFloat = 45

    @IBOutlet weak var showTitleLabel: UILabel!
    
    
    @IBOutlet weak var showSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
