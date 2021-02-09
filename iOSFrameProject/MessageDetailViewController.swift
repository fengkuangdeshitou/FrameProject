//
//  MessageDetailViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MessageDetailViewController: UIViewController {

    var message: MessageModel?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showTimeLabel: UILabel!
    
    @IBOutlet weak var showContentLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = message?.title
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // set header View
        // 时间
        // 设置拍摄时间
        let takeDate = Date.init(timeIntervalSince1970: TimeInterval((message?.createdTime)! / 1000))
        self.showTimeLabel.text = NSDate.stringNormalRead(with: takeDate)
        
        // 内容设置
        self.showContentLabel.text = message?.content
        UILabel.setLabelSpace(self.showContentLabel, withValue: self.showContentLabel.text, with: self.showContentLabel.font, andLineSpaceing: 6.0)
        
        let labelHeight = UILabel.getSpaceLabelHeight(self.showContentLabel.text, with: self.showContentLabel.font, withWidth: SCREEN_WIDTH - 72, andLineSpaceing: 6.0)
        self.showContentLabel.height = labelHeight
        
        // set tableView
        self.tableView.tableHeaderView?.height = self.showContentLabel.x + self.showContentLabel.height
        self.tableView.tableFooterView = UIView.init()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 设置导航栏
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : COLOR_DARK_GAY]
        self.navigationController?.navigationBar.tintColor = COLOR_GAY
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
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
