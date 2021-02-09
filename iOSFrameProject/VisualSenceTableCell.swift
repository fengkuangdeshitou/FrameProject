//
//  VisualSenceTableCell.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/20.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit


class VisualSenceTableCell: UITableViewCell {
    
    @IBOutlet var titleLable: UIButton!
    @IBOutlet var moreButton: UIButton!
    
    @IBOutlet var picA: UIImageView!
    @IBOutlet var picB: UIImageView!
    @IBOutlet var picC: UIImageView!
    @IBOutlet var picD: UIImageView!
    @IBOutlet var picE: UIImageView!
    @IBOutlet var picF: UIImageView!
    @IBOutlet var bgViewLayoutConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.moreButton.setRightAndleftTextWith(#imageLiteral(resourceName: "nav_back_reverse2.png"), withTitle: "更多", for: .normal, andImageFontValue: Float(FONT_STANDARD_SIZE), andTitleFontValue: Float(FONT_STANDARD_SIZE), andTextAlignment: .left)
        self.moreButton.tintColor = self.moreButton.titleLabel?.textColor
    }
}
