//
//  HomeTableViewCell.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/18.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let HOME_CELL_ID = "homeCellId"
let HOME_CELL_HEIGHT: CGFloat = 224.0


class HomeTableViewCell: UITableViewCell {

    // left
    @IBOutlet weak var leftCellView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var leftPM25Label: UILabel!
    @IBOutlet weak var leftAddressLabel: UILabel!
    @IBOutlet weak var leftSupportBtn: UIButton!
    
    
    // right
    @IBOutlet weak var rightCellView: UIView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var rightPM25Label: UILabel!
    @IBOutlet weak var rightAddressLabel: UILabel!
    @IBOutlet weak var rightSupportBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
