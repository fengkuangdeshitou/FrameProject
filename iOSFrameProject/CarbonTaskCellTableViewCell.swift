//
//  CarbonTaskCellTableViewCell.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/1/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CarbonTaskCellTableViewCell: UITableViewCell {

    static var carbonTaskCellId = "carbonTaskCell"  // cell id
    static var carbonTaskCellHeight = 60            // cell height
    
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    
    @IBOutlet weak var showProgressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: 设置进度
    func setProgress(complete: Int, total: Int) {
        if complete == total {
            // 已完成
            self.showProgressLabel.text = "已完成"
            self.showProgressLabel.layer.masksToBounds = true
            self.showProgressLabel.layer.cornerRadius = CORNER_NORMAL
            self.showProgressLabel.backgroundColor = UIColorFromRGB(rgbValue: 0xcccccc)
            self.showProgressLabel.textColor = UIColor.white
            self.showProgressLabel.textAlignment = NSTextAlignment.center
        } else {
            self.showProgressLabel.text = "\(complete)/\(total)"
            self.showProgressLabel.backgroundColor = UIColor.clear
            self.showProgressLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            self.showProgressLabel.textAlignment = NSTextAlignment.right
        }
    }
    
}
