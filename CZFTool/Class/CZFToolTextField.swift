//
//  CZFToolTextField.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CZFToolTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var iconRect = super.leftViewRect(forBounds: bounds)
        
        iconRect.origin.x += 15
        
        return iconRect
    }
    
    
    // MARK: UITextField 文字与输入框的距离
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 45, dy: 0)
    }
    
    // MARK: //控制文本的位置
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 45, dy: 0)
    }
}
