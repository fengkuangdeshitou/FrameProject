//
//  HomeHeaderView.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/18.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let HOME_HEADER_HEIGHT: CGFloat = 44.0
let HOME_HEADER_ID = "homeHeaderId"

var currentIndex = 0
@objc protocol HomeHeaderViewDelegate {
    @objc optional func homeHeaderViewButtonIndexClick(index: Int) -> Bool
}

class HomeHeaderView: UICollectionReusableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var scrollView: UIScrollView?
    
    weak var homeHeaderdelegate: HomeHeaderViewDelegate?
    
    var textArray: [String] = [NSLocalizedString("besideNow", comment: ""), NSLocalizedString("worldNow", comment: ""), NSLocalizedString("myAttention", comment: "")]
    fileprivate var bottomColorView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 设置顶部分割线
        let topSeparatorLineView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.5))
        topSeparatorLineView.backgroundColor = COLOR_SEPARATOR_LINE
        self.addSubview(topSeparatorLineView)
        
        let segmentWidth: CGFloat = 320.0
        self.scrollView = UIScrollView.init(frame: CGRect(x: (SCREEN_WIDTH-segmentWidth)/2, y: 1, width: segmentWidth, height: HOME_HEADER_HEIGHT-1))
        
        let buttonWith = segmentWidth / 3
        for (index, item) in self.textArray.enumerated() {
            let button = UIButton.init(frame: CGRect(x: buttonWith * CGFloat(index), y: 0, width: buttonWith, height: (scrollView?.height)!))
            
            button.setTitle(item, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
            if index == currentIndex {
                button.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
            } else {
                button.setTitleColor(COLOR_GAY, for: .normal)
            }
            
            button.tag = index + 10
            button.addTarget(self, action: #selector(showTextButtonClick(sender:)), for: .touchUpInside)
            self.scrollView?.addSubview(button)
        }
        
        // 指示块
        let textSize = sizeWithText(text: self.textArray[0] as NSString, font: UIFont.systemFont(ofSize: FONT_STANDARD_SIZE), size: CGSize(width: 100, height: 30))
        self.bottomColorView = UIView.init(frame: CGRect(x: 0, y: HOME_HEADER_HEIGHT-6, width: textSize.width, height: 5))
        // set bottom color view
        UIView.animate(withDuration: 0.25) {
            self.bottomColorView?.centerX = buttonWith / 2 + CGFloat(currentIndex) * buttonWith
        }
        self.bottomColorView?.tag = -1
        self.bottomColorView?.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.bottomColorView?.layer.masksToBounds = true
        self.bottomColorView?.layer.cornerRadius = (self.bottomColorView?.height)! / 2
        self.scrollView?.addSubview(self.bottomColorView!)
        self.addSubview(self.scrollView!)
        self.backgroundColor = UIColor.white
    }
    
    
    // MARK: 按钮点击响应
    @objc func showTextButtonClick(sender: UIButton) {
        //代理
       let isNext =  self.homeHeaderdelegate?.homeHeaderViewButtonIndexClick!(index: sender.tag - 10)
        if !isNext! {return}
        
        let buttonIndex = sender.tag - 10
        currentIndex = buttonIndex
        // set button
        for (index, item) in (self.scrollView?.subviews.enumerated())! {
            if item.tag >= 10 {
                let button = item as! UIButton
                if buttonIndex == index {
                    // 选中
                    button.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
                } else {
                    button.setTitleColor(COLOR_GAY, for: .normal)
                }
            }
        }
        
        // set bottom color view
        UIView.animate(withDuration: 0.25) {
            self.bottomColorView?.centerX = (sender.width / 2) + CGFloat(buttonIndex) * sender.width
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
