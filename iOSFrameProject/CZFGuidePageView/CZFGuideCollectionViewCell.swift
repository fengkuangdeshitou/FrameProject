//
//  CZFGuideCollectionViewCell.swift
//  CZFGuidePageViewDemo
//
//  Created by 陈帆 on 2018/2/28.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CZFGuideCollectionViewCell: UICollectionViewCell {
    static let guideCellId = "guideCellId"
    
    var showImageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showImageView = UIImageView.init()
        self.showImageView?.contentMode = UIView.ContentMode.scaleToFill
        self.contentView.addSubview(self.showImageView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.showImageView?.frame = self.contentView.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
