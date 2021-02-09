//
//  CarbonIncomeCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/1/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CarbonIncomeCell: UITableViewCell {

    static var carbonIncomeCellId = "carbonIncomeCellId"        // cell id
    
    static var carbonIncomeCellHeight = 60                      // cell height
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showDetailLabel: UILabel!
    
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
