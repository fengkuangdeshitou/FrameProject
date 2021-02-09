//
//  CouphonCellHeaderView.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CouphonCellHeaderView: UITableViewHeaderFooterView {

    var showImageView: UIImageView?
    
    var showTitleButton: UIButton?
    
    var showRightLabel: UILabel?
    
    static let HEAD_ID = "cellHeaderId"
    static let HEAD_HEIGHT: CGFloat = 36.0
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = UIColor.white
        let imageWH: CGFloat = 24.0
        self.showImageView = UIImageView.init(frame: CGRect(x: 13, y: (CouphonCellHeaderView.HEAD_HEIGHT - imageWH)/2, width: imageWH, height: imageWH))
        self.showImageView?.clipsToBounds = true
        self.showImageView?.contentMode = .scaleAspectFill
        self.showImageView?.layer.masksToBounds = true
        self.showImageView?.layer.cornerRadius = imageWH / 2
        
        self.contentView.addSubview(self.showImageView!)
        
        self.showTitleButton = UIButton.init(type: .system)
        self.showTitleButton?.frame = CGRect(x: (self.showImageView?.x)! + (self.showImageView?.width)! + 5, y: 0, width: SCREEN_WIDTH - 150, height: CouphonCellHeaderView.HEAD_HEIGHT)
        self.showTitleButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: FONT_SYSTEM_SIZE)
        self.showTitleButton?.setTitleColor(COLOR_DARK_GAY, for: .normal)
        self.showTitleButton?.tintColor = COLOR_LIGHT_GAY
        self.contentView.addSubview(self.showTitleButton!)
        
        self.showRightLabel = UILabel.init(frame: CGRect(x: SCREEN_WIDTH - 80, y: 0, width: 67, height: CouphonCellHeaderView.HEAD_HEIGHT))
        self.contentView.addSubview(self.showRightLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
