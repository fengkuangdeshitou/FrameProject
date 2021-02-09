//
//  AtContactTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/16.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class AtContactTableViewCell: UITableViewCell {

    static let CELL_ID = "contactCell"
    static let CELL_HEIGHT: CGFloat = 44.0
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
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
