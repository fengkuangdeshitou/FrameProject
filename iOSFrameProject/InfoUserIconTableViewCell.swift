//
//  InfoUserIconTableViewCell.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/27.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let INFO_USERICON_CELL_ID = "infoUserIconCellId"
let INFO_USERICON_CELL_HEIGHT  = 70

class InfoUserIconTableViewCell: UITableViewCell {

    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.showImageView.layer.masksToBounds = true
        self.showImageView.layer.cornerRadius = CORNER_NORMAL
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
