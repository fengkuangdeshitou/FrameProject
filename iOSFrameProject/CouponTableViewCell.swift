//
//  CouponTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/4.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CouponTableViewCell: UITableViewCell {

    static let CELL_ID = "couponManageId"
    static let CELL_HEIGHT: CGFloat = 94.0
    
    @IBOutlet weak var couponBgTypeView: UIView!
    
    
    @IBOutlet weak var showCarbonLabel: UILabel!
    
    @IBOutlet weak var showDiscountOrMoneyLabel: UILabel!
    
    @IBOutlet weak var valideTimeLabel: UILabel!
    
    @IBOutlet weak var couponGroupUseLabel: UILabel!
    
    @IBOutlet weak var showUseFullMoneyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.couponGroupUseLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
