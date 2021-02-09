//
//  DoUpdateViewController.swift
//  ECOCityProject
//
//  Created by 陈帆 on 2017/11/24.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class DoUpdateViewController: UIViewController {

    var isForceUpdate: Bool?    // 是否强制更新
    
    @IBOutlet weak var updateView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var updateBtn: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var updateContentLB: UILabel!
    
    @IBOutlet weak var updateViewConstraintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var closeBtnContraintTop: NSLayoutConstraint!
    
    
    
    var storeVersion: String?       // 商店上的版本号
    
    var storeUpateNots: String?     // 商店上的更新内容
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        if SCREEN_WIDTH <= 320 {  // 3.5, 4.0
            self.closeBtnContraintTop.constant = 20
        }
        
        if self.isForceUpdate != nil && self.isForceUpdate! {
            self.closeBtn.isHidden = true
        }
        
        
        // 设置圆角
        self.updateView.layer.masksToBounds = true
        self.updateView.layer.cornerRadius = CORNER_NORMAL*2
        
        self.versionLabel.layer.masksToBounds = true
        self.versionLabel.layer.cornerRadius = self.versionLabel.height / 2
        
        self.updateBtn.layer.masksToBounds = true
        self.updateBtn.layer.cornerRadius = self.updateBtn.height / 2
        
        // 设置更新信息
        if self.storeVersion != nil && self.storeVersion != nil {
            self.versionLabel.text = "V " + self.storeVersion!
            self.updateContentLB.text = self.storeUpateNots
//            self.updateContentLB.text = "1. 【优化】App启动的界面的显示\n2.【优化】照片拍照界面的体验 \n3. 初始化swift项目\n4. 修复程序中隐藏的bug\n5. 增强程序的稳定性"
        } else {
            self.versionLabel.isHidden = true
            self.updateContentLB.text = "1. 增加了很多新功能，请快快升级吧~"
        }
        
        // 设置适配
        UILabel.setLabelSpace(self.updateContentLB, withValue: self.updateContentLB.text, with: self.updateContentLB.font, andLineSpaceing: 6.0)
//        tools.setLabelSpace(self.updateContentLB, withValue: self.updateContentLB.text, with: self.updateContentLB.font, andLineSpaceing: 6.0)
        let contentHeight = UILabel.getSpaceLabelHeight(self.updateContentLB.text, with: self.updateContentLB.font, withWidth: self.updateContentLB.width, andLineSpaceing: 6.0)
//        let contentHeight = tools.getSpaceLabelHeight(self.updateContentLB.text, with: self.updateContentLB.font, withWidth: self.updateContentLB.width, andLineSpaceing: 6.0)
        self.updateContentLB.height = contentHeight
        self.updateViewConstraintHeight.constant += contentHeight - 70
        self.updateBtn.y = contentHeight + self.updateContentLB.y + 30
        
    }
    
    
    // MARK: 关闭按钮点击
    @IBAction func closeBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: 更新按钮点击
    @IBAction func updateBtnClick(_ sender: UIButton) {
        let urlStr = URL_APPSTORE_APP + APP_ID
        if UIApplication.shared.canOpenURL(URL.init(string: urlStr)!) {
            UIApplication.shared.openURL(URL.init(string: urlStr)!)
        } else {
            let alertViewController = UIAlertController.init(title: "更好的功能，只为服务于你", message: "请打开AppStore商店，搜索“250你发布”关键字，进行更新吧", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (alertAction) in
                
            }))
            self.present(alertViewController, animated: true, completion: nil)
        }
        
        guard self.isForceUpdate != nil && self.isForceUpdate! else {
            sleep(1)
            self.dismiss(animated: true, completion: nil)
            return
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
