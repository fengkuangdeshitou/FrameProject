//
//  AboutUsViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/27.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    
    @IBOutlet weak var showVersionlabel: UILabel!
    
    @IBOutlet weak var showDetailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "关于"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 设置版本号
        self.showVersionlabel.text = "250你发布 V" + String(describing: (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString"))!)
        
        // 设置detail间距
        UILabel.setLabelSpace(self.showDetailLabel, withValue: self.showDetailLabel.text, with: self.showDetailLabel.font, andLineSpaceing: 6.0)
//        tools.setLabelSpace(self.showDetailLabel, withValue: self.showDetailLabel.text, with: self.showDetailLabel.font, andLineSpaceing: 6.0)
        
        // 判断手机是屏幕高度 小于 568
        if SCREEN_HEIGHT < 568 {
            self.showDetailLabel.isHidden = true
        }
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
