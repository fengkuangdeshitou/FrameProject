//
//  PhotoHeaderView.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/21.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let PHOTO_HEADER_VIEW_ID = "photoHeaderViewId"
let PHOTO_HEADER_VIEW_HEIGHT = 44

class PhotoHeaderView: UITableViewHeaderFooterView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var showTitleLabel: UILabel?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setViewUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewUI() {
        self.contentView.backgroundColor = UIColor.white
        // set title
        self.showTitleLabel = UILabel.init(frame: CGRect(x: 13, y: 0, width: 200, height: PHOTO_HEADER_VIEW_HEIGHT))
        self.showTitleLabel?.text = "全部评价"
        self.showTitleLabel?.textColor = COLOR_DARK_GAY
        self.showTitleLabel?.font = UIFont.boldSystemFont(ofSize: FONT_STANDARD_SIZE)
        self.contentView.addSubview(self.showTitleLabel!)
        
        // set color block
//        let blockColorView = UIView.init(frame: CGRect(x: 10.0, y: CELL_NORMAL_HEIGHT-3, width: 55, height: 3))
//        blockColorView.backgroundColor = COLOR_DARK_GAY
//        blockColorView.layer.masksToBounds = true
//        blockColorView.layer.cornerRadius = 1.5
//        self.contentView.addSubview(blockColorView)
    }

}
