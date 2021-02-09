//
//  MessageTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    static let CELL_ID = "cellid"
    static let CELL_HEIGHT: CGFloat = 117
    
    @IBOutlet weak var showTimeLabel: UILabel!
    
    @IBOutlet weak var showContentView: UIView!
    
    @IBOutlet weak var showTitleBtn: UIButton!
    
    @IBOutlet weak var showDetailLabel: UILabel!
    
    @IBOutlet weak var showRightImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.showContentView.layer.masksToBounds = true
        self.showContentView.layer.cornerRadius = CORNER_SMART
        self.showContentView.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.showContentView.layer.borderWidth = BORDER_WIDTH
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
