//
//  SettingViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/27.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ShareThirdViewDelegate {
    
    fileprivate var dataSource: [Array<[String : String]>] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "设置"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 设置 tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init()
        
        // 设置数据  [DICT_TITLE : "公司介绍", DICT_SUB_TITLE : ""],
        self.dataSource = [[[DICT_TITLE : "消息推送", DICT_IDENTIFIER : "MessagePushView"]],
                           
                            [[DICT_TITLE : "好评鼓励", DICT_SUB_TITLE : ""],
                            [DICT_TITLE : "分享给好友", DICT_SUB_TITLE : ""]],
                           
                           [[DICT_TITLE : "意见反馈", DICT_SUB_TITLE : "", DICT_IDENTIFIER : "SuggestFeedBackView"],
                            [DICT_TITLE : "关于我们", DICT_SUB_TITLE : "", DICT_IDENTIFIER : "AboutUsView"]],
                           ]
        
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - UITableView 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSectionArray = self.dataSource[section]
        return dataSectionArray.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "cell")
        infoCell?.accessoryType = .disclosureIndicator
        
        // 解析数据
        let dataSectionArray = self.dataSource[indexPath.section]
        let dataDict = dataSectionArray[indexPath.row]
        
        infoCell?.textLabel?.text = dataDict[DICT_TITLE]
        infoCell?.detailTextLabel?.text = dataDict[DICT_SUB_TITLE]
        
        
        return infoCell!
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 解析数据
        let dataSectionArray = self.dataSource[indexPath.section]
        let dataDict = dataSectionArray[indexPath.row]
        if dataDict[DICT_TITLE] == "公司介绍" {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
            viewController.isUserGesture = true
            viewController.pageUrlStr = "http://www.jointsky.com"
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        if dataDict[DICT_TITLE] == "好评鼓励" {
            let urlStr = URL_APPSTORE_APP + APP_ID
            if UIApplication.shared.canOpenURL(URL.init(string: urlStr)!) {
                UIApplication.shared.openURL(URL.init(string: urlStr)!)
            } else {
                let alertViewController = UIAlertController.init(title: "赠人玫瑰，手有余香", message: "请打开AppStore商店，搜索“250你发布”关键字，进行好评吧。", preferredStyle: .alert)
                alertViewController.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (alertAction) in
                    
                }))
                self.present(alertViewController, animated: true, completion: nil)
            }
            
        }
        
        if dataDict[DICT_TITLE] == "分享给好友" {
            // 第三方分享
            // 跳转 Share显示界面
            let viewController = ShareThirdViewController.init(nibName: "ShareThirdViewController", bundle: nil)
            viewController.customDelegate = self
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overFullScreen
            self.present(viewController, animated: true, completion: nil)
        }
        
        
        if dataDict[DICT_TITLE] == "消息推送" || dataDict[DICT_TITLE] == "意见反馈" || dataDict[DICT_TITLE] == "关于我们" {
            let viewControler = self.storyboard?.instantiateViewController(withIdentifier: dataDict[DICT_IDENTIFIER]!)
            self.navigationController?.pushViewController(viewControler!, animated: true)
            
        }
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CELL_NORMAL_HEIGHT
    }
    
    
    // MARK: section Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10.0
    }
    
    // MARK: section Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    

    // MARK: 友盟分享type
    func shareWebPageToPlatformType(platformType: UMSocialPlatformType) {
        //创建分享消息对象
        let messageObject = UMSocialMessageObject.init()
        
        //分享消息对象设置分享内容对象
        let shareObject = UMShareWebpageObject.shareObject(withTitle: "250你发布", descr: "《250你发布》是一款手机拍照，自动美化图片，发布实景照片的软件。通过其他人所拍摄的实景照片足不出户了解户外环境，为出行提供帮助。倡导数字环保，服务生活是我们的宗旨。我们将建立环保的大数据，在建设生态城市的道路上我们永不放弃，也感谢您的支持与帮助。", thumImage: #imageLiteral(resourceName: "applogo"))
        
        // https://mobile.jointsky.com/MEPStore/pages/detail.html?id=297ebe0e6078129a01616f932ba5000a
        // https://itunes.apple.com/cn/app/250%E4%BD%A0%E5%8F%91%E5%B8%83/id1070816677?mt=8
        shareObject?.webpageUrl = "https://mobile.jointsky.com/MEPStore/pages/detail.html?id=297ebe0e6078129a01616f932ba5000a"
        messageObject.shareObject = shareObject
        
        //调用分享接口
        UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self) { (data, error) in
            if (error != nil) {
                MBProgressHUD.show("分享取消", icon: nil, view: self.view)
            } else {
                MBProgressHUD.show("已分享", icon: nil, view: self.view)
            }
        }
    }
    
    
    // MARK: - ShareThirdViewDelegate
    // MARK: 平台分享
    func shareThirdViewPublish(platformType: UMSocialPlatformType) {
        self.shareWebPageToPlatformType(platformType: platformType)
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
