//
//  PayTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class PayTableViewCell: UITableViewCell {

    static var CELL_ID = "PayTableViewCell"        // id
    static var CELL_HEIGHT: CGFloat = 50.0         // height
    
    
    @IBOutlet weak var showImageView: UIImageView!
    
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSelectImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
