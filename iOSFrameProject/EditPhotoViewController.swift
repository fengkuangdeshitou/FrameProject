//
//  EditPhotoViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/19.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

@objc protocol EditPhotoViewDelegate: NSObjectProtocol {
    // 上传图片成功
    @objc optional func editPhotoViewPublishImagesSuccess();
    
    @objc optional func editPhotoViewEditLabelClick(waitDealImage: UIImage);
}


class EditPhotoViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, LMSTakePhotoControllerDelegate, AppDelegateCustomDelegate, LocationListViewDelegate, AtContactViewDelegate {

    weak var editPhotoDelegate: EditPhotoViewDelegate?
    
    var originImage: UIImage?
    var dealImage: UIImage?
    
    var senceData: PhotoModel?
    fileprivate var currentFlagTagIndex = 0     // 当前选中的标签索引
    fileprivate var imageSize: CGSize?
    
    fileprivate var currentAddress = APP_DELEGATE.locationAddress?.formattedAddress
    
    fileprivate var locationCitysArray: [String]?   // 拍照定位的相似地址信息
    
    var location: CLLocation?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textView: UIPlaceHolderTextView!
    
    @IBOutlet weak var atOtherUserBtn: UIButton!
    
    @IBOutlet weak var addWaterEditLabel: UILabel!
    
    
    @IBOutlet weak var remainWordLabel: UILabel!
    
    @IBOutlet weak var showOriginImageView: UIImageView!
    
    @IBOutlet weak var showDealImageView: UIImageView!
    
    @IBOutlet weak var showPM25Label: UILabel!
    
    @IBOutlet weak var showFlagView: UIView!
    
    
    @IBOutlet weak var publishBtn: UIButton!
    
    
    fileprivate var isShowTip = true
    
    fileprivate var atUserArray: [UserInfoModel] = []
    
    fileprivate var publishText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view。
        // 初始化
        self.title = "编辑"
        
        // 设置导航栏
        // UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        let leftBarBtnItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // setViewUI
        self.setViewUI()
        self.setSelectedPhotoTagWithIndex(index: currentFlagTagIndex)
        self.textView.text = UserDefaults.standard.string(forKey: DICT_SAVE_PHOTO_DESCIPTION)
        
        // set Table View
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        APP_DELEGATE.alertCommonShow(title: "退出此次编辑", message: "", btn1Title: "取消", btn2Title: "确定", vc: self) { (btnIndex) in
            if btnIndex == 1 {
                self.dismiss(animated: true, completion: nil)
                UserDefaults.standard.set("", forKey: DICT_SAVE_PHOTO_DESCIPTION)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    
    // MARK: - UITableView 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.accessoryType = .disclosureIndicator
//        cell?.selectionStyle = .none
        
        cell?.imageView?.image = #imageLiteral(resourceName: "edit_location_address")
        cell?.textLabel?.textColor = COLOR_DARK_GAY
        cell?.textLabel?.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        
        cell?.textLabel?.text = self.currentAddress
        
        return cell!
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 跳转到地址选择列表
        let viewController = LocationListViewController()
        viewController.locaiton = self.location
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: scroll did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView == scrollView {
            self.view.endEditing(true)
        }
    }
    
    
    // MARK: - UITextViewDelegate 代理方法的实现
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count
        
        if textLength <= PHOTO_DESCRIPTION_LENGTH - 1 {
            self.remainWordLabel.textColor = UIColorFromRGB(rgbValue: 0x7e7e7e)
        } else {
            if self.isShowTip {
                MBProgressHUD.show("超过的字符将不能被提交", icon: nil, view: self.view)
                self.isShowTip = false
            }
            self.remainWordLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        }
        self.remainWordLabel.text = "\(PHOTO_DESCRIPTION_LENGTH - textLength)"
    }
    
    // MAARK: shouldChangeTextInRange
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "@" {
            myPrint(message: "@用户")
            
            let viewController = AtContactViewController.init(nibName: "AtContactViewController", bundle: nil)
            viewController.atContactDelegate = self
            let nav = UINavigationController.init(rootViewController: viewController)
            self.present(nav, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
    // MARK: - LocationListViewDelegate 代理方法的实现
    // MARK: 选址成功回调
    func locationListViewSelectedStr(string: String) {
        self.currentAddress = "\(String(describing: (APP_DELEGATE.locationAddress?.province)!))\(String(describing: (APP_DELEGATE.locationAddress?.city)!))\(String(describing: (APP_DELEGATE.locationAddress?.district)!))\(string)"
        self.tableView.reloadData()
    }
    
    
    // MARK: - AtContactViewDelegate
    // MARK:
    func atContactView(vc: AtContactViewController, selectUser: UserInfoModel) {
        var lastStr = ""
        let textStr = NSMutableString.init(string: self.textView.text)
        let locationIndex = self.textView.selectedRange.location
        
        if textStr.length > locationIndex {
            lastStr = textStr.substring(with: NSRange.init(location: locationIndex, length: 1))
        }
        
        // 添加@用户
        let isContain = self.atUserArray.contains { (user) -> Bool in
            if user.id == selectUser.id {
                return true
            }
            return false
        }
        if !isContain {
            self.atUserArray.append(selectUser)
        }
        
        
        if lastStr == "@" {
            textStr.insert("\(String(describing: selectUser.nickname!)) ", at: locationIndex)
        } else {
            textStr.insert("@\(String(describing: selectUser.nickname!)) ", at: locationIndex)
        }
        
        self.textView.text = textStr as String?
        self.textView.becomeFirstResponder()
        
        self.textViewDidChange(self.textView)
    }
    
    
    // MARK: 发布按钮响应
    @IBAction func publishBtnClick(_ sender: UIButton) {
        if APP_DELEGATE.currentUserInfo == nil {
            // 跳转登录界面
            MBProgressHUD.show("请登录", icon: nil, view: nil)
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        
        let uploadImagesArray = [self.originImage, self.dealImage]
        
        var regionCode = DEFAULT_LOCATIONFAILED_CODE
        if APP_DELEGATE.locationAddress != nil {
            let cityInfo = AddressPickerDemo.getCityRelativeInfo(with: APP_DELEGATE.locationAddress?.city)
            if cityInfo != nil {
                regionCode = cityInfo!["regionCode"] as! String
            }
        }
        
        //   截取过长的字符串
        if textView.text.count > PHOTO_DESCRIPTION_LENGTH {
            textView.text = CUTString(textStr: textView.text!, start: 0, length: PHOTO_DESCRIPTION_LENGTH)
            myPrint(message: "\( self.textView.text)")
        }
        
        // 获取@用户的id列表
        let atUserIdsStr = self.getAtUserIdsString()
        
        
        // 去除字符串中首尾换行，中间的连续换行
        var publistTempStr = self.publishText! as NSString
        publistTempStr = publistTempStr.trimmingCharacters(in: CharacterSet.newlines) as NSString
        for i in 0..<PHOTO_DESCRIPTION_LENGTH {
            myPrint(message: "\(i)")
            publistTempStr = publistTempStr.replacingOccurrences(of: "\n\n\n", with: "\n\n") as NSString
        }
        self.publishText = publistTempStr.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        
        // 对图片描述进行编码
        let descriStr = AddressPickerDemo.stringAddEncode(with: self.publishText)
        let paramters = ["pm25" : "\(String(describing: (self.senceData?.pm25)!))",
                         "photoTypeCode" : PHOTO_CODE_ARRAY[self.currentFlagTagIndex]["code"]!,
                         "regionCode" : regionCode,
                         "latitude" : "\(UserDefaults.standard.double(forKey: LOCATION_LATITUDE))",
                         "longitude" : "\(UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))",
            "takeTime" : "\(NSDate.string(from: Date.init(timeIntervalSince1970: (self.senceData?.takeTime)!), andFormatterString: DATE_STANDARD_FORMATTER)!)",
            "address" : (self.currentAddress)!,
                         "description" : descriStr ?? "",
                         "giftUserIds" : atUserIdsStr] as [String : Any]

        MBProgressHUD.showMessage("上传中...")
        WebDataResponseInterface.shareInstance.SessionManagerWebDataUpload(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoPublish, formData: { (formData) in
            for (i, item) in uploadImagesArray.enumerated() {
                let imageData = item!.jpegData(compressionQuality: 0.9)
                let fileName = i == 0 ? "oriPhotoFile" : "dehPhotoFile"     // files
                formData.appendPart(withFileData: imageData!, name: fileName, fileName: fileName + ".jpg", mimeType: "image/jpg")
            }
        }, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: { (proccess)in
            // 进度
            DispatchQueue.main.async(execute: {
                myPrint(message: "proccess = \(proccess) ====== \(Thread.current)")
            })
        }, responseSuccess: { (objectSuccess) in
            if objectSuccess != nil {
                // 上传成功
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    MBProgressHUD.hide()
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    // 设置刷新代理
                    self.editPhotoDelegate?.editPhotoViewPublishImagesSuccess!()
                    
                    // 发送更新图片的广播
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_PhotoInfo), object: nil)
                    
                    // 更新当前用户信息
                    UserBusiness.shareIntance.responseWebGetUserInfo(userId: (APP_DELEGATE.currentUserInfo?.id)!, responseSuccess: { (userSuccess) in
                        APP_DELEGATE.currentUserInfo = userSuccess as? UserInfoModel
                    }, responseFailed: { (error) in
                    })
                    
//                    // 关闭视图
//                    self.dismiss(animated: true, completion: nil)
                    // 跳转发布成功视图
                    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                    let viewController = storyBoard.instantiateViewController(withIdentifier: "PublishSuccessView") as! PublishSuccessViewController
                    
                    viewController.shareDealImage = uploadImagesArray[1]
                    self.senceData?.takeTime = (self.senceData?.takeTime)! * 1000
                    viewController.senceData = self.senceData
                    self.senceData?.address = self.currentAddress
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                    // 清空本地缓存的图片描述
                    UserDefaults.standard.set("", forKey: DICT_SAVE_PHOTO_DESCIPTION)
                    UserDefaults.standard.synchronize()
                    
                })
                
            } else {
                // 上传返回数据为空
                MBProgressHUD.show("返回数据为空", icon: nil, view: self.view)
            }
        }) { (error) in
            // 上传失败
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }
    
    
    // 获取@用户的idstr（多个用户用','隔开）
    func getAtUserIdsString() -> String {
        // 获取带有@用户ID的描述
        let descTextStr = NSMutableString.init(string: self.textView.text)
        var atUserIdsStr = ""
        for user in self.atUserArray {
            let findTextRange = descTextStr.range(of: "@\(user.nickname!) ")
            if findTextRange.location != NSNotFound {
                // 存在
                descTextStr.replaceCharacters(in: findTextRange, with: "@\(user.id!) ")
                if atUserIdsStr == "" {
                    atUserIdsStr = user.id!
                } else {
                    atUserIdsStr = "\(atUserIdsStr),\(user.id!)"
                }
            }
        }
        
        // 去掉带@的用户信息(放置同一个用户多次被@)
        var descTextStr2 = NSString.init(string: descTextStr)
        for user in self.atUserArray {
            let atUserStr = "@\(user.nickname!) "
            descTextStr2 = descTextStr2.replacingOccurrences(of: atUserStr, with: "@\(user.id!) ") as NSString
        }
        
        self.publishText = descTextStr2 as String
        return atUserIdsStr
    }
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    
    // MARK: view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 禁止ios的返回手势
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 开启
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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

extension EditPhotoViewController {
    fileprivate func setViewUI() {
        // set text View
        self.textView.delegate = self
        self.textView.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        self.textView.textColor = COLOR_DARK_GAY
        self.textView.placeholder = "说点什么吧..."
        self.textView.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.textView.placeholderColor = UIColor.lightGray
        
        // @ 用户
        self.atOtherUserBtn.layer.masksToBounds = true
        self.atOtherUserBtn.layer.cornerRadius = self.atOtherUserBtn.height / 2
        self.atOtherUserBtn.layer.borderColor = COLOR_HIGHT_LIGHT_SYSTEM.cgColor
        self.atOtherUserBtn.layer.borderWidth = BORDER_WIDTH
        self.atOtherUserBtn.addTarget(self, action: #selector(atOtherUserBtnClick(sender:)), for: .touchUpInside)
        
        // 编辑
//        self.addWaterEditLabel.isHidden = true
        self.addWaterEditLabel.layer.masksToBounds = true
        self.addWaterEditLabel.layer.cornerRadius = self.addWaterEditLabel.height / 2
        self.addWaterEditLabel.isUserInteractionEnabled = true
    self.addWaterEditLabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            // 编辑点击
            self.navigationController?.popViewController(animated: false)
            UserDefaults.standard.set(self.textView.text, forKey: DICT_SAVE_PHOTO_DESCIPTION)
            UserDefaults.standard.synchronize()
        self.editPhotoDelegate?.editPhotoViewEditLabelClick!(waitDealImage: self.showDealImageView.image!)
        }))
        
        // set origin image
        self.showOriginImageView.clipsToBounds = true
        self.showOriginImageView.contentMode = .scaleAspectFill
        self.showOriginImageView.image = self.originImage
        self.showOriginImageView.isUserInteractionEnabled = true
    self.showOriginImageView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.showImageDetail(index: 0)
        }))
        
        // set deal image
        self.showDealImageView.clipsToBounds = true
        self.showDealImageView.contentMode = .scaleAspectFill
        self.showDealImageView.image = self.dealImage
        self.showDealImageView.isUserInteractionEnabled = true
    self.showDealImageView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.showImageDetail(index: 1)
        }))
        
        
        // 显示Pm2.5
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: NAVIGATION_TITLE_FONT_SIZE, minFont: 9.0, color: colorPm25WithValue(pm25Value: (self.senceData?.pm25)!), action: {})
        var strText = "PM2.5：<help><link><FontMax>\(String(describing: (self.senceData?.pm25)!))</FontMax></link></help>μg/m³" as NSString?
        if APP_DELEGATE.isCheckApp {
            strText = "最近站点PM2.5：<help><link><FontMax>\(String(describing: (self.senceData?.pm25)!))</FontMax></link></help>μg/m³" as NSString?
        }
        self.showPM25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        
        
        // 设置标签
        let gapXY = 8, labelHeight = 20, inlineWidth = 15;
        for (i, item) in PHOTO_CODE_ARRAY.enumerated() {
            
            let titlelabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
            titlelabel.font = UIFont.systemFont(ofSize: FONT_SMART_SIZE)
            titlelabel.textColor = COLOR_GAY;
            titlelabel.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION;
            titlelabel.textAlignment = .center;
            titlelabel.tag = i;
            titlelabel.layer.masksToBounds = true;
            titlelabel.layer.cornerRadius = CGFloat(labelHeight / 2);
            
            titlelabel.isUserInteractionEnabled = true;
            titlelabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
                self.setSelectedPhotoTagWithIndex(index: i)
            }))
            
            //这个frame是初设的，没关系，后面还会重新设置其size。  //lbDetailInformation1
            let attributes1 = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: FONT_SMART_SIZE)];
            let str1 = item["title"]! as NSString;
            let textSize1 = str1.boundingRect(with: self.showFlagView.bounds.size, options: .truncatesLastVisibleLine, attributes: attributes1, context: nil).size
            
            // 获取前一个label
            var titleLabelX = gapXY, titlelabelY = gapXY;
            if (i != 0) {
                let preLabel = self.showFlagView.subviews[i - 1] as! UILabel;
                titleLabelX = Int(preLabel.x) + Int(preLabel.width) + gapXY;
                let currentContentWidth = titleLabelX+Int(textSize1.width)+inlineWidth+gapXY;
                titleLabelX = currentContentWidth <= Int(SCREEN_WIDTH - 198.0) ? titleLabelX : gapXY;
                
                titlelabelY = currentContentWidth <= Int(SCREEN_WIDTH - 198.0) ? Int(preLabel.y) : (Int(preLabel.y)+gapXY+labelHeight);
            }
            
            titlelabel.frame = CGRect(x: titleLabelX, y: titlelabelY, width: Int(textSize1.width)+inlineWidth, height: labelHeight)
            titlelabel.text = str1 as String;
            
            self.showFlagView.addSubview(titlelabel)
        }
        
        // 隐藏showFlagView
        self.showFlagView.isHidden = true
        
        // 设置发布按钮
        self.publishBtn.layer.masksToBounds = true
        self.publishBtn.layer.cornerRadius = self.publishBtn.height / 2
    }
    
    // MARK: 设置图片Tag
    func setSelectedPhotoTagWithIndex(index: Int) {
        currentFlagTagIndex = index
        for item in self.showFlagView.subviews {
            let label = item as! UILabel
            if item.tag == index {
                // 选中
                label.textColor = UIColor.white
                label.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
            } else {
                // 未选中
                label.textColor = COLOR_GAY
                label.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
            }
        }
    }
    
    
    // 图片点击浏览
    func showImageDetail(index: Int) {
        let modelOne = LWImageBrowserModel.init(placeholder: self.originImage, thumbnailURL: URL.init(string: ""), hdurl: URL.init(string: ""), containerView: self.tableView.tableHeaderView, positionInContainer: self.showOriginImageView.frame, index: 0)
        
        let modelTwo = LWImageBrowserModel.init(placeholder: self.dealImage, thumbnailURL: URL.init(string: ""), hdurl: URL.init(string: ""), containerView: self.tableView.tableHeaderView, positionInContainer: self.showDealImageView.frame, index: 1)
        
        let browser = LWImageBrowser.init(imageBrowserModels: [modelOne!, modelTwo!], currentIndex: index)
        browser?.show()
    }
    
    
    // MARK: @用户点击
    @objc func atOtherUserBtnClick(sender: UIButton) {
        myPrint(message: "@用户")
        
        let viewController = AtContactViewController.init(nibName: "AtContactViewController", bundle: nil)
        viewController.atContactDelegate = self
        let nav = UINavigationController.init(rootViewController: viewController)
        self.present(nav, animated: true, completion: nil)
    }
}
