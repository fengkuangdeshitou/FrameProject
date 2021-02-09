//
//  MerchantTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MerchantTableViewCell: UITableViewCell {
    static let CELL_HEIGHT: CGFloat = 72.0
    static let CELL_ID = "merchantCellId"
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    @IBOutlet weak var goToPayBtn: UIButton!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.goToPayBtn.layer.masksToBounds = true
        self.goToPayBtn.layer.cornerRadius = self.goToPayBtn.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
