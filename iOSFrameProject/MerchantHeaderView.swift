//
//  MerchantHeaderView.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MerchantHeaderView: UITableViewHeaderFooterView {

    static let HEADER_ID = "merchantHeader"
    static let HEADER_HEIGHT: CGFloat = 30.0
    
    var deleteBtn: UIButton?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setViewUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewUI() {
        // titleLabel
        self.textLabel?.font = UIFont.systemFont(ofSize: 11.0)
        
        // button
        let btnWH: CGFloat = 20;
        self.deleteBtn = UIButton.init(frame: CGRect(x: SCREEN_WIDTH - btnWH - 10.0, y: MerchantHeaderView.HEADER_HEIGHT - btnWH, width: btnWH, height: btnWH))
        self.deleteBtn?.setImage(UIImage.init(named: "search_delete.png"), for: UIControl.State.normal)
        
        self.contentView.addSubview(self.deleteBtn!)
    }
}
