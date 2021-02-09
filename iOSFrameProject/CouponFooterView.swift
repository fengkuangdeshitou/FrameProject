//
//  CouponFooterView.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CouponFooterView: UITableViewHeaderFooterView {

    static let FOOTER_ID = "couponFooter"
    static let FOOTER_HEIGHT: CGFloat = 29
    
    var showImageView: UIImageView?
    var showTitleLabel: UILabel?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let subView = UIView.init(frame: CGRect(x: (SCREEN_WIDTH-290)/2.0, y: 0, width: 290, height: CouponFooterView.FOOTER_HEIGHT))
        subView.backgroundColor = UIColor.white
        self.contentView.addSubview(subView)
        
        self.showImageView = UIImageView.init(frame: CGRect(x: 5, y: 3, width: CouponFooterView.FOOTER_HEIGHT-6, height: CouponFooterView.FOOTER_HEIGHT-6))
        self.showImageView?.clipsToBounds = true
        self.showImageView?.contentMode = .scaleAspectFill
        self.showImageView?.layer.masksToBounds = true
        self.showImageView?.layer.cornerRadius = (self.showImageView?.height)! / 2
        
        subView.addSubview(self.showImageView!)
        
        self.showTitleLabel = UILabel.init(frame: CGRect(x: (self.showImageView?.x)! + (self.showImageView?.width)! + 8, y: 0, width: subView.width - 50, height: subView.height))
        self.showTitleLabel?.textColor = UIColorFromRGB(rgbValue: 0xff782f)
        self.showTitleLabel?.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        subView.addSubview(self.showTitleLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
