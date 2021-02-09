//
//  RankImageTableViewCell.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/22.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let RNAK_IMAGE_CELL_ID = "rankImageCellId"
let RANK_IMAGE_CELL_HEIGHT = 168

class RankImageTableViewCell: UITableViewCell {

    @IBOutlet weak var showBgImageView: UIImageView!
    
    @IBOutlet weak var showOrderIndexLabel: UILabel!
    
    @IBOutlet weak var showPm25View: UIView!
    
    @IBOutlet weak var showPm25ValueLabel: UILabel!
    
    @IBOutlet weak var showAddressLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.showBgImageView.clipsToBounds = true
        self.showBgImageView.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
