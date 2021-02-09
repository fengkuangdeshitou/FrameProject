//
//  PublishSuccessViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/17.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class PublishSuccessViewController: UIViewController {

    var shareDealImage: UIImage?
    var senceData: PhotoModel?
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = ""
        self.cancelBtn.layer.masksToBounds = true
        self.cancelBtn.layer.cornerRadius = CORNER_SMART
        self.sendBtn.layer.masksToBounds = true
        self.sendBtn.layer.cornerRadius = CORNER_SMART
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
//        let vcArray = self.navigationController?.viewControllers
//        self.navigationController?.popToViewController(vcArray![(vcArray?.count)! - 2], animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelBtnClick(_ sender: UIButton) {
//        let vcArray = self.navigationController?.viewControllers
//        self.navigationController?.popToViewController(vcArray![(vcArray?.count)! - 2], animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendBtnClick(_ sender: UIButton) {
        if UMSocialManager.default().isInstall(UMSocialPlatformType.wechatSession) {
            // 调用微信分享
            self.shareWebPageToPlatformType(platformType: UMSocialPlatformType.wechatSession)
        } else {
            MBProgressHUD.show("请安装微信程序", icon: nil, view: self.view)
        }
        
    }
    
    
    // MARK: 友盟分享type
    func shareWebPageToPlatformType(platformType: UMSocialPlatformType) {
        //创建分享消息对象
        let messageObject = UMSocialMessageObject.init()
        
        //分享消息对象设置分享内容对象
        let shareObject = UMShareImageObject.init()
        
        shareObject.shareImage = ShowPhotoViewController.setSharCardView(publishUser: APP_DELEGATE.currentUserInfo!, senceData: self.senceData!, image: self.shareDealImage!)
        messageObject.shareObject = shareObject
        
        //调用分享接口
        UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self) { (data, error) in
            if (error != nil) {
                MBProgressHUD.show("发送取消", icon: nil, view: nil)
            } else {
                MBProgressHUD.show("已发送给朋友", icon: nil, view: nil)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
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
