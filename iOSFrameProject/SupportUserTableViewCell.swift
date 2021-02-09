//
//  SupportUserTableViewCell.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/21.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let SUPPORT_USER_CELL_ID = "supportUserCellId"
let SUPPORT_USER_CELL_HEIGHT = 65

class SupportUserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showDetailLabel: UILabel!
    @IBOutlet var showReplyLabel: UILabel!
    @IBOutlet var showReplyLayoutConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.showImageView.layer.masksToBounds = true
        self.showImageView.layer.cornerRadius = self.showImageView.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
