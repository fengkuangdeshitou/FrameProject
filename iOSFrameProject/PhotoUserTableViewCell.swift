//
//  PhotoUserTableViewCell.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/21.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let PHOTO_USER_CELL_ID = "photoUserCellId"
let PHOTO_USER_CELL_HEIGHT = 65

class PhotoUserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showDescripationLabel: UILabel!
    
    @IBOutlet weak var AttentionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // attention Btn
        self.AttentionBtn.layer.masksToBounds = true
        self.AttentionBtn.layer.cornerRadius = self.AttentionBtn.height / 2
        self.AttentionBtn.layer.borderColor = COLOR_HIGHT_LIGHT_SYSTEM.cgColor
        self.AttentionBtn.layer.borderWidth = BORDER_WIDTH
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
