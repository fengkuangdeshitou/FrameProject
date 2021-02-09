//
//  VisSenDetailTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/6/4.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class VisSenDetailTableViewCell: UITableViewCell {
    
    static let CELL_ID = "VisSenCellId"
    
    @IBOutlet weak var showUserImageView: UIImageView!
    
    @IBOutlet weak var showNameLabel: UILabel!
    
    @IBOutlet weak var showTimeLabel: UILabel!
    
    @IBOutlet weak var showDetailLabel: UILabel!
    
    @IBOutlet weak var showRightLabel: UILabel!
    
    @IBOutlet weak var showDetailImageView: UIImageView!
    
    @IBOutlet weak var showBottomLineView: UIView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.showUserImageView.layer.masksToBounds = true
        self.showUserImageView.layer.cornerRadius = self.showUserImageView.height / 2
        self.showUserImageView.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.showUserImageView.layer.borderWidth = BORDER_WIDTH
        
        // right text
        self.showRightLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
