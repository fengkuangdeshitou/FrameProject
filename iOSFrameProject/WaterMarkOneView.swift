//
//  WaterMarkOneView.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/18.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class WaterMarkOneView: UIView {

    static let defaultPasterViewW_H: CGFloat = 200.0    // 默认View宽高
    
    var showAddress: String?
    
    var showPM25: Int?
    
    var showPM25LevelStr: String?
    
    var showDesciption: String?
    
    
    @IBOutlet weak var showbgImageView: UIImageView!
    
    @IBOutlet weak var showAddressLabel: UILabel!
    
    @IBOutlet weak var showPM25Label: UILabel!
    
    @IBOutlet weak var showPM25LevelLabel: UILabel!
    
    @IBOutlet weak var showDescriptionLabel: UILabel!
    
    
    static func shareInstance() -> WaterMarkOneView? {
        let nibView = Bundle.main.loadNibNamed("WaterMarkOneView", owner: nil, options: nil)
        let view = nibView?.first as? WaterMarkOneView
        if view != nil {
            return view
        }
        return nil;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadInitData() {
        // 地址
        self.showAddressLabel.text = self.showAddress
        
        // PM2.5
        self.showPM25Label.text = String(describing: self.showPM25!)
        
        // PM2.5 Level Str
        self.showPM25LevelLabel.text = self.showPM25LevelStr
        // 描述
        self.showDescriptionLabel.text = self.showDesciption
        self.showDescriptionLabel.adjustsFontSizeToFitWidth = true
        self.layoutSubviews()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
