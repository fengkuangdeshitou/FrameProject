//
//  TradeRecordListTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class TradeRecordListTableViewCell: UITableViewCell {
    static let CELL_ID = "tradeRecordListCell"
    static let CELL_HEIGHT: CGFloat = 60.0
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    @IBOutlet weak var showRightLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
