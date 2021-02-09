//
//  ShareThirdViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/7/5.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

@objc protocol ShareThirdViewDelegate: NSObjectProtocol {
    // 分享调用
    @objc optional func shareThirdViewPublish(platformType: UMSocialPlatformType)
}

class ShareThirdViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var showTipLabel: UILabel!
    
    
    @IBOutlet weak var viewBottomConstrait: NSLayoutConstraint!
    
    @IBOutlet weak var viewHeightConstrait: NSLayoutConstraint!
    
    
    weak var customDelegate: ShareThirdViewDelegate?
    
    fileprivate var dataSource: [[String : String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewBottomConstrait.constant = -self.bottomView.height
        
        // 设置数据
        // 判断微博是否安装
        if UMSocialManager.default().isInstall(UMSocialPlatformType.sina) {
            self.dataSource.append([DICT_TITLE : "新浪微博", DICT_IMAGE_PATH : "share_umsocial_sina" , DICT_IDENTIFIER : String(UMSocialPlatformType.sina.rawValue)])
        }
        
        // 判断微信是否安装
        if UMSocialManager.default().isInstall(UMSocialPlatformType.wechatSession) {
            self.dataSource.append([DICT_TITLE : "微信", DICT_IMAGE_PATH : "share_umsocial_wechat" , DICT_IDENTIFIER : String(UMSocialPlatformType.wechatSession.rawValue)])
            self.dataSource.append([DICT_TITLE : "微信朋友圈", DICT_IMAGE_PATH : "share_umsocial_wechat_timeline" , DICT_IDENTIFIER : String(UMSocialPlatformType.wechatTimeLine.rawValue)])
            self.dataSource.append([DICT_TITLE : "微信收藏", DICT_IMAGE_PATH : "share_umsocial_wechat_favorite" , DICT_IDENTIFIER : String(UMSocialPlatformType.wechatFavorite.rawValue)])
        }
        
        // 判断QQ是否安装
        if UMSocialManager.default().isInstall(UMSocialPlatformType.QQ) {
            self.dataSource.append([DICT_TITLE : "QQ", DICT_IMAGE_PATH : "share_umsocial_qq" , DICT_IDENTIFIER : String(UMSocialPlatformType.QQ.rawValue)])
            self.dataSource.append([DICT_TITLE : "QQ空间", DICT_IMAGE_PATH : "share_umsocial_qzone" , DICT_IDENTIFIER : String(UMSocialPlatformType.qzone.rawValue)])
        }
        
        // 判断TIM是否安装
        if UMSocialManager.default().isInstall(UMSocialPlatformType.tim) {
            self.dataSource.append([DICT_TITLE : "TIM", DICT_IMAGE_PATH : "share_umsocial_tim" , DICT_IDENTIFIER : String(UMSocialPlatformType.tim.rawValue)])
        }
        
        // 动画
        if self.dataSource.count <= 4 {
            self.viewHeightConstrait.constant =  self.bottomView.height - 70
        } else {
            self.viewHeightConstrait.constant =  self.bottomView.height
        }
        
        // 提示
        self.showTipLabel.isHidden = self.dataSource.count == 0 ? false : true
        
        
        // 1. 定义collectionView的布局类型，流布局
        let layout = UICollectionViewFlowLayout()
        // 2. 设置cell的大小
        layout.itemSize = CGSize(width: ShareCollectionViewCell.CELL_WH, height: 320.0 / 4.0)
        // 3. 滑动方向
        /**
         默认方向是垂直
         UICollectionViewScrollDirection.vertical  省略写法是.vertical
         水平方向
         UICollectionViewScrollDirection.horizontal 省略写法是.horizontal
         */
        layout.scrollDirection = .vertical
        // 4. 每个item之间最小的间距
        layout.minimumInteritemSpacing = 0
        // 5. 每行之间最小的间距
        layout.minimumLineSpacing = 10
        // 6. 设置一个layout
        self.collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.clear
        
        // 7. 设置collectionView的代理和数据源
        collectionView.delegate = self
        collectionView.dataSource = self;
        
        // 8. collectionViewCell的注册
        collectionView.register(UINib(nibName: "ShareCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ShareCollectionViewCell.CELL_ID)
    }
    
    
    // MARK: - UICollectionViewDelegate 代理方法的实现
    // MARK: numberOfSections 代理方法
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: numberOfItemsInSection  代理方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    // MARK: cellForItemAt  代理方法
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShareCollectionViewCell.CELL_ID, for: indexPath) as! ShareCollectionViewCell
        
        // 解析数据
        let dataDict = self.dataSource[indexPath.row]
        
        cell.showImageView.backgroundColor = UIColor.white
        cell.showImageView.image = UIImage.init(named: dataDict[DICT_IMAGE_PATH]!)
        cell.showLabel.text = dataDict[DICT_TITLE]
        return cell
    }
    
    // MARK: didSelectItemAt 的代理方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 解析数据
        let dataDict = self.dataSource[indexPath.row]
        let type = Int(dataDict[DICT_IDENTIFIER]!)
        
        switch type {
        case UMSocialPlatformType.sina.rawValue:
            self.customDelegate?.shareThirdViewPublish!(platformType: UMSocialPlatformType.sina)
        case UMSocialPlatformType.wechatSession.rawValue:
            self.customDelegate?.shareThirdViewPublish!(platformType: UMSocialPlatformType.wechatSession)
        case UMSocialPlatformType.wechatTimeLine.rawValue:
            self.customDelegate?.shareThirdViewPublish!(platformType: UMSocialPlatformType.wechatTimeLine)
        case UMSocialPlatformType.wechatFavorite.rawValue:
            self.customDelegate?.shareThirdViewPublish!(platformType: UMSocialPlatformType.wechatFavorite)
        case UMSocialPlatformType.QQ.rawValue:
            self.customDelegate?.shareThirdViewPublish!(platformType: UMSocialPlatformType.QQ)
        case UMSocialPlatformType.qzone.rawValue:
            self.customDelegate?.shareThirdViewPublish!(platformType: UMSocialPlatformType.qzone)
        case UMSocialPlatformType.tim.rawValue:
            self.customDelegate?.shareThirdViewPublish!(platformType: UMSocialPlatformType.tim)
        default:
            self.customDelegate?.shareThirdViewPublish!(platformType: UMSocialPlatformType.sina)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: referenceSizeForHeaderInSection 的代理方法
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: width, height: 17)
//    }
    
    // MARK: sizeForItemAt 的代理方法
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if (indexPath as NSIndexPath).row % 2 == 1 {
//            return CGSize(width: width/2, height: height/3)
//        }
//        else {
//            return CGSize(width: width/2, height: height/2)
//        }
//    }
    
    
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
//            if self.dataSource.count == 0 {
////                MBProgressHUD.show("请安装“微博、微信、QQ”等程序", icon: nil, view: nil)
////                self.dismiss(animated: true, completion: nil)
//                self.showTipLabel.isHidden = false
//            } else {
//                self.showTipLabel.isHidden = true
//            }
//        }
        
        UIView.animate(withDuration: 0.2) {
            self.viewBottomConstrait.constant = 0
            self.bottomView.layoutIfNeeded()
        }
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
