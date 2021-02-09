//
//  MineTableViewCell.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/22.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class MineTableViewCell: UITableViewCell {

    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showDetailLabel: UILabel!
    
    @IBOutlet weak var showRedDotView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.showRedDotView.layer.masksToBounds = true
        self.showRedDotView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
