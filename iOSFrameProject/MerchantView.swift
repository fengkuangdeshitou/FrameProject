//
//  MerchantView.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/24.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MerchantView: UIView {

    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    @IBOutlet weak var showDistanceLabel: UILabel!
    
    @IBOutlet weak var alipayFloagImageView: UIImageView!
    
    @IBOutlet weak var weixinPayFloagImageView: UIImageView!
    
    
    @IBOutlet weak var goToPayBtn: UIButton!
    
    
    static func shareInstance() -> MerchantView? {
        let nibView = Bundle.main.loadNibNamed("MerchantView", owner: nil, options: nil)
        let view = nibView?.first as? MerchantView
        if view != nil {
            
            view?.goToPayBtn.layer.masksToBounds = true
            view?.goToPayBtn.layer.cornerRadius = (view?.goToPayBtn.height)! / 2
            
            view?.frame = CGRect(x: 0, y: 0.1, width: SCREEN_WIDTH, height: 85.0)
            return view
        }
        return nil;
    }
    
    // 设置数据
    func loadInitData(merchant: MerchantModel, userLocation: CLLocationCoordinate2D) {
        // 设置图片
        self.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + merchant.logo!), placeholderImage: DEFAULT_IMAGE())
        
        // name
        self.showTitleLabel.text = merchant.name
        
        // 描述
        self.showSubTitleLabel.text = merchant.description
        
        // 距离
        // 计算当前位置到商家的位置的距离(坐标点的直线距离)
        let point1 = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: merchant.latitude!, longitude: merchant.longitude!))
        let point2 = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude))
        // 计算距离
        let distance = MAMetersBetweenMapPoints(point1,point2)
        self.showDistanceLabel.text = "距离我" + (NSString.init(readDistanceWith: CGFloat(distance))! as String) as String
        
        // 支付方式标记
        self.alipayFloagImageView.isHidden = merchant.aliAccount == ""
        self.weixinPayFloagImageView.isHidden = merchant.wxAccount == ""
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
