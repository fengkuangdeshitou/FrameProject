//
//  SelectCouponTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/21.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class SelectCouponTableViewCell: UITableViewCell {

    static let CELL_ID = "cell"
    static let CELL_HEIGHT: CGFloat = 94.0
    
    @IBOutlet weak var couponBgTypeView: UIView!
    
    
    @IBOutlet weak var showCarbonLabel: UILabel!
    
    @IBOutlet weak var showDiscountOrMoneyLabel: UILabel!
    
    @IBOutlet weak var valideTimeLabel: UILabel!
    
    @IBOutlet weak var showUseFullMoneyLabel: UILabel!
    
    @IBOutlet weak var showSelectImageView: UIImageView!
    
    @IBOutlet weak var showSelectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.showSelectImageView.isHidden = true
        
        self.showSelectLabel.layer.masksToBounds = true
        self.showSelectLabel.layer.cornerRadius = self.showSelectLabel.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
