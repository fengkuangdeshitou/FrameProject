//
//  merchantCenterCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/27.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MerchantCenterCell: UITableViewCell {
    static let CELL_ID = "merchantCenterCell"
    static let CELL_HEIGHT: CGFloat = 45.0
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
