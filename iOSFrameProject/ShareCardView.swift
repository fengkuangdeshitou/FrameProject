//
//  ShareCardView.swift
//  ECOCityProject
//
//  Created by 陈帆 on 2017/12/20.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class ShareCardView: UIView {

    var showImage: UIImage?
    
    var showPM25: Int?
    
    var showTimeStr: String?
    
    var showAddress: String?
    
    var showUserName: String?
    
    
    
    @IBOutlet weak var showCardView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    
    
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showPM25Label: UILabel!
    
    @IBOutlet weak var showTimeLabel: UILabel!
    
    @IBOutlet weak var showAddressLabel: UILabel!
    
    @IBOutlet weak var showNameLabel: UILabel!
    
    
    static func shareInstance() -> ShareCardView? {
        let nibView = Bundle.main.loadNibNamed("ShareCardView", owner: nil, options: nil)
        let view = nibView?.first as? ShareCardView
        if view != nil {
            view?.width = SCREEN_WIDTH
            view?.height = SCREEN_HEIGHT
            return view
        }
        return nil;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadInitData() {
        // 图片
        self.showImageView.clipsToBounds = true
        self.showImageView.contentMode = .scaleAspectFill
        self.showImageView.image = self.showImage
        let realHeight = (SCREEN_WIDTH-2*8) / ((self.showImage?.size.width)! / (self.showImage?.size.height)!)
        self.showImageView.height = realHeight
        self.bottomView.y = realHeight+3+8
        self.showCardView.height = realHeight+3+8 + self.bottomView.height
        
        
        // PM2.5    字体样式
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_STANDARD_SIZE, minFont: 11.0, color: colorPm25WithValue(pm25Value: self.showPM25!), action: {})
        let strText = "PM2.5：<help><link><FontMax>\(String(describing: self.showPM25!))</FontMax></link></help> μg/m³" as NSString?
        self.showPM25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        // 时间
        self.showTimeLabel.text = self.showTimeStr
        // 地址
        self.showAddressLabel.width = SCREEN_WIDTH - 50
        self.showAddressLabel.text = self.showAddress
        self.showAddressLabel.height = UILabel.getSpaceLabelHeight(self.showAddressLabel.text, with: self.showAddressLabel.font, withWidth: self.showAddressLabel.width, andLineSpaceing: 0.0)
//        self.showAddressLabel.height = tools.getSpaceLabelHeight(self.showAddressLabel.text, with: self.showAddressLabel.font, withWidth: self.showAddressLabel.width, andLineSpaceing: 0.0)
        // 用户名
        self.showNameLabel.text = self.showUserName! + " 发布"
        self.showNameLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}
