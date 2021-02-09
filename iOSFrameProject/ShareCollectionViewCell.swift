//
//  ShareCollectionViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/7/5.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class ShareCollectionViewCell: UICollectionViewCell {

    static let CELL_ID = "shareCell"
    static let CELL_WH: CGFloat = (UIScreen.main.bounds.size.width - 8*2) / 4.0
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showLabel: UILabel!
    
    
    @IBOutlet weak var showImageBackView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.showImageBackView.layer.masksToBounds = true
        self.showImageBackView.layer.cornerRadius = self.showImageBackView.height / 2
    }

}
