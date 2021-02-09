//
//  RankTextTableViewCell.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/22.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let RANK_TEXT_CELL_ID = "rankTextCellId"
let RANK_TEXT_Cell_HEIGHT = 50

class RankTextTableViewCell: UITableViewCell {

    @IBOutlet weak var showColorBlockView: UIView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showPm25Label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
