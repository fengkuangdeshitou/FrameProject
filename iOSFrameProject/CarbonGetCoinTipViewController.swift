//
//  CarbonGetCoinTipViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/2/2.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CarbonGetCoinTipViewController: UIViewController, CAAnimationDelegate {
    var carbonCoinCount: Int?               // 显示碳币奖励个数
    
    var carbonCoinGetDesciption: String?    // 显示碳币因何奖励描述
    
    fileprivate var carbonCoinShowAnimImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        
        
        let iamgeViewWH: CGFloat = 250
        self.carbonCoinShowAnimImageView = UIImageView.init(image: #imageLiteral(resourceName: "mine_congratulation_coin"))
        self.carbonCoinShowAnimImageView?.frame = CGRect(x: (SCREEN_WIDTH - iamgeViewWH)/2, y: (SCREEN_HEIGHT - iamgeViewWH)/2, width: iamgeViewWH, height: iamgeViewWH)
        self.carbonCoinShowAnimImageView?.contentMode = .scaleAspectFit
        
        // 添加碳币数显示
        let carbonCoinHeight: CGFloat = 22
        let carbonCoinLabel = UILabel.init(frame: CGRect(x: 0, y: iamgeViewWH - carbonCoinHeight*5, width: iamgeViewWH, height: carbonCoinHeight))
        carbonCoinLabel.textAlignment = .center
        carbonCoinLabel.font = UIFont.init(name: "Arial Rounded MT", size: FONT_BIG_SIZE)
        carbonCoinLabel.textColor = UIColorFromRGB(rgbValue: 0x8b572a)
        
        // 设置样式
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: 22, minFont: 15, color: carbonCoinLabel.textColor, action: {})
        let strText = "获得<help><link><FontMax>10</FontMax></link></help>碳币" as NSString?
        carbonCoinLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        self.carbonCoinShowAnimImageView?.addSubview(carbonCoinLabel)
        
        self.view.addSubview(self.carbonCoinShowAnimImageView!)
        
        // 设置提醒理由Label
        // 添加碳币数显示
        let carbonCoinTipHeight: CGFloat = 20
        let carbonCoinTipLabel = UILabel.init(frame: CGRect(x: 0, y: iamgeViewWH - 72, width: iamgeViewWH, height: carbonCoinTipHeight))
        carbonCoinTipLabel.textAlignment = .center
        carbonCoinTipLabel.font = UIFont.systemFont(ofSize: FONT_SMART_SIZE)
        carbonCoinTipLabel.textColor = UIColorFromRGB(rgbValue: 0xfb9e01)
        carbonCoinTipLabel.text = self.carbonCoinGetDesciption
        
        self.carbonCoinShowAnimImageView?.addSubview(carbonCoinTipLabel)
        
        // 设置动画
        self.carbonCoinShowAnimImageView?.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.setCarbonCoinAnimation(isShow: true)
        }
    }
    
    
    func setCarbonCoinAnimation(isShow: Bool) {
        self.carbonCoinShowAnimImageView?.isHidden = !isShow
        
        
        // 动画1
        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.fromValue = 0.1
        animation2.toValue = 1.0

        let animationArray = CAAnimationGroup()
        animationArray.delegate = self
        animationArray.animations = [animation2]
        animationArray.duration = 0.5
        animationArray.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        animationArray.fillMode = CAMediaTimingFillMode.forwards
        animationArray.isRemovedOnCompletion = true

        self.carbonCoinShowAnimImageView?.layer.add(animationArray, forKey: "animationGroup")
    }
    
    
    // MARK:  - CAAnimationDelegate
    // MARK: 动画完成
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
