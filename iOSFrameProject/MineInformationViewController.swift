//
//  MineInformationViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/27.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class MineInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var exitLoginBtn: UIButton!
    
    
    var dataSource: [[String : String]] = []
    
    // 懒加载
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePickerTem = UIImagePickerController.init()
        
        imagePickerTem.delegate = self
        imagePickerTem.allowsEditing = true
        return imagePickerTem
    }()
    
    // 头像
    fileprivate var currentUserImage: UIImage = #imageLiteral(resourceName: "defaultUserImage")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "个人信息"
        self.exitLoginBtn.layer.masksToBounds = true
        self.exitLoginBtn.layer.cornerRadius = CORNER_NORMAL
        
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // set Table View
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "InfoUserIconTableViewCell", bundle: nil), forCellReuseIdentifier: INFO_USERICON_CELL_ID)
        
        // 设置数据 [DICT_TITLE : "邮箱", DICT_SUB_TITLE : (APP_DELEGATE.currentUserInfo?.mail)!]
        // 手机号＋*号
        var phoneNumberEncStr = (APP_DELEGATE.currentUserInfo?.phoneNumber)!
        if phoneNumberEncStr.count == WORDCOUNT_USER_PHONE {
            phoneNumberEncStr = AddressPickerDemo.stringPhoneNumEncodeStart(with: phoneNumberEncStr)
        }
        self.dataSource = [[DICT_TITLE : "昵称", DICT_SUB_TITLE : (APP_DELEGATE.currentUserInfo?.nickname)!],
                           [DICT_TITLE : "说说", DICT_SUB_TITLE : (APP_DELEGATE.currentUserInfo?.speak)!]]
        
        if APP_DELEGATE.currentUserInfo?.roleCode != RoleCodeType.roleTemp.rawValue {
//            self.dataSource.insert([DICT_TITLE : "密码", DICT_SUB_TITLE : "******"], at: 2)
            self.dataSource.append([DICT_TITLE : "手机号", DICT_SUB_TITLE : phoneNumberEncStr])
        } else {
            self.dataSource.append([DICT_TITLE : "升级正式用户", DICT_SUB_TITLE : ""])
        }
        
        /// 注册接收消息通知
        // 接收用户信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserInfoUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
        
    }
    
    
    // MARK: 用户信息更新消息通知响应
    @objc func acceptUserInfoUpdateNotification(notification: Notification) {
        let userInfo = notification.object as? UserInfoModel
        
        if userInfo == nil {
            // 设置数据  [DICT_TITLE : "邮箱", DICT_SUB_TITLE : (APP_DELEGATE.currentUserInfo?.mail)!]
            // 手机号＋*号
            var phoneNumberEncStr = (APP_DELEGATE.currentUserInfo?.phoneNumber)!
            if phoneNumberEncStr.count == WORDCOUNT_USER_PHONE {
                phoneNumberEncStr = AddressPickerDemo.stringPhoneNumEncodeStart(with: phoneNumberEncStr)
            }
            self.dataSource = [[DICT_TITLE : "昵称", DICT_SUB_TITLE : (APP_DELEGATE.currentUserInfo?.nickname)!],
                               [DICT_TITLE : "说说", DICT_SUB_TITLE : (APP_DELEGATE.currentUserInfo?.speak)!],]
            if APP_DELEGATE.currentUserInfo?.roleCode != RoleCodeType.roleTemp.rawValue {
//                self.dataSource.insert([DICT_TITLE : "密码", DICT_SUB_TITLE : "******"], at: 2)
                self.dataSource.append([DICT_TITLE : "手机号", DICT_SUB_TITLE : phoneNumberEncStr])
            } else {
                self.dataSource.append([DICT_TITLE : "升级正式用户", DICT_SUB_TITLE : ""])
            }
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - UITableView 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0  {
            return 1
        }
        return self.dataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // photo User
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: INFO_USERICON_CELL_ID) as! InfoUserIconTableViewCell
            cell.accessoryType = .disclosureIndicator
            
            cell.showTitleLabel.text = "头像"
            cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (APP_DELEGATE.currentUserInfo?.avatar)!), placeholderImage: self.currentUserImage)
            
            return cell
        }
        
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "cell")
        infoCell?.accessoryType = .disclosureIndicator
        
        // 解析数据
        let dataDict = self.dataSource[indexPath.row]
        
        infoCell?.textLabel?.text = dataDict[DICT_TITLE]
        infoCell?.detailTextLabel?.text = dataDict[DICT_SUB_TITLE]
        
        
        return infoCell!
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 临时用户不能修改头像、昵称、说说
        if indexPath.section == 0 {
            if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
                // 临时用户
                MBProgressHUD.show("请先升级为正式用户", icon: nil, view: self.view)
                return
            }
            
            // 修改头像
            let buttons = [[
                "title": "拍照",
                "handler": "camera",
                ],
               [
                "title": "从相册选择",
                "handler": "album",
                "type": "default"
                ]
            ]
            let cancelBtn = [
                "title": "取消",
                ]
            
            let mmActionSheet = MMActionSheet.init(title: nil, buttons: buttons, duration: nil, cancelBtn: cancelBtn)
            mmActionSheet.callBack = { (handler) ->() in
                if handler == "cancel" {
                    return
                }
                switch handler {
                case "camera":
                    // 拍照
                    //判断是否支持相机或相机权限是否开启
                    let takePhotoVC = LMSTakePhotoController.init()
                    if !takePhotoVC.isCameraAvailable || !takePhotoVC.isAuthorizedCamera {
                        let alertViewController = UIAlertController.init(title: "未获取到拍照权限", message: "请在（设置->隐私->相机->250你发布）中开启", preferredStyle: .alert)
                        // 取消
                        alertViewController.addAction(UIAlertAction.init(title: "确定", style: .cancel, handler: { (alertAction) in
                            // 跳转到设置
                            UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
                        }))
                        self.present(alertViewController, animated: true, completion: nil)
                        
                        return;
                    }
                    self.imagePicker.sourceType = .camera
                case "album":
                    // 从相册选择
                    self.imagePicker.sourceType = .savedPhotosAlbum
                default:
                    myPrint(message: "cancel")
                }
                self.present(self.imagePicker, animated: true, completion:nil)
            }
            mmActionSheet.present()
            
        } else {
            let dataDict = self.dataSource[indexPath.row]
            
            if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue && dataDict[DICT_TITLE]! != "升级正式用户" {
                // 临时用户
                MBProgressHUD.show("请先升级为正式用户", icon: nil, view: self.view)
                return
            }
            
            // 修改其他基本信息
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeInfoView") as! ChangeInfoViewController
            switch dataDict[DICT_TITLE]! {
            case "昵称":
                viewController.chageInfoType = .changeUserName
                viewController.defaultInputText = APP_DELEGATE.currentUserInfo?.nickname
            case "说说":
                let changeSpeekVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangeSpeekView") as! ChangeSpeekViewController
                changeSpeekVC.defaultInputText = APP_DELEGATE.currentUserInfo?.speak
                self.navigationController?.pushViewController(changeSpeekVC, animated: true)
                return
            case "密码":
                // 修改密码
                let  changePwdVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePwdView") as! ChangePwdViewController
                changePwdVC.defaultInputText = APP_DELEGATE.currentUserInfo?.phoneNumber
                changePwdVC.title = "修改密码"
                self.navigationController?.pushViewController(changePwdVC, animated: true)
                return
            case "升级正式用户":
                let  changePwdVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePwdView") as! ChangePwdViewController
                changePwdVC.defaultInputText = ""
                changePwdVC.title = "用户升级"
                self.navigationController?.pushViewController(changePwdVC, animated: true)
                return
            case "手机号":
                viewController.chageInfoType = .changeStopOnePhone
                viewController.defaultInputText = APP_DELEGATE.currentUserInfo?.phoneNumber
            default:
                viewController.chageInfoType = .changeEmail
                viewController.defaultInputText = APP_DELEGATE.currentUserInfo?.mail
            }
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat(INFO_USERICON_CELL_HEIGHT)
        }
        
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
    
    
    // MARK: scroll did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    
    //MARK:- UIImagePickerControllerDelegate
    // MARK: image picker controller
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String :Any]){
        
        let type:String = (info[UIImagePickerController.InfoKey.mediaType.rawValue] as! String)
        //当选择的类型是图片
        if type=="public.image"
        {
            let img = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage
            
            self.currentUserImage = UIImage.scal(toSize: img, size: CGSize(width: 300, height: 300))
//            self.currentUserImage = tools.scal(toSize: img, size: CGSize(width: 100, height: 100))
            
            // 更新头像
            UserBusiness.shareIntance.responseWebUploadUserAvatar(userImage: self.currentUserImage, responseSuccess: { (objectSuccess) in
                APP_DELEGATE.currentUserInfo = objectSuccess as? UserInfoModel
                // 刷新头像
                self.tableView.reloadData()
                MBProgressHUD.show("已更换头像", icon: nil, view: self.view)
                
                // 发送更新用户信息的广播
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
            }) {(error) in
            }
            
            picker.dismiss(animated:true, completion:nil)
        }
    }
    
    // MARK: image picker did cancel
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion:nil)
    }
    
    
    // MARK: 退出登录响应
    @IBAction func exitLoginBtnClick(_ sender: UIButton) {
        let buttons = [[
                "title": "确定",
                "handler": "sure",
                "type": "danger"
            ]
        ]
        let cancelBtn = [
            "title": "取消",
            ]
        
        let mmActionSheet = MMActionSheet.init(title: "您要退出登录吗？", buttons: buttons, duration: nil, cancelBtn: cancelBtn)
        mmActionSheet.callBack = { (handler) ->() in
            if handler == "cancel" {
                return
            }
            switch handler {
            case "sure":
                // 确定退出登录
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
                let userIconUrlStr = APP_DELEGATE.currentUserInfo?.avatar
                viewController.userAvatarUrl = userIconUrlStr ?? ""
                viewController.isShowCancelButton = false
                let nav = UINavigationController.init(rootViewController: viewController)
                APP_DELEGATE.jmTabBarViewController?.selectedViewController?.present(nav, animated: true, completion: {})
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
                
                
                // 清空用户数据
                // 解绑推送
                if APP_DELEGATE.currentUserInfo != nil {
                    let userId = (APP_DELEGATE.currentUserInfo?.id)!
                    UMessage.removeAlias(userId, type: UM_ALIAS_TYPE, response: { (object, error) in
                        myPrint(message: "addAliasError: \(String(describing: error))")
                    })
                }
                APP_DELEGATE.currentUserInfo = nil
                UserDefaults.standard.set("", forKey: ACCESS_TOKEN)
                UserDefaults.standard.set(nil, forKey: DICT_USER_INFO)
                UserDefaults.standard.synchronize()
            default:
                myPrint(message: "cancel")
            }
        }
        mmActionSheet.present()
    }
    
    
    // MARK: view will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 重新读取本地用户信息
        let dataSourceDict = UserDefaults.standard.dictionary(forKey: DICT_USER_INFO)
        if dataSourceDict != nil && APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.currentUserInfo = UserInfoModel.init(json: (dataSourceDict?.mapJSON())!)
        }
        
        if dataSourceDict == nil || APP_DELEGATE.currentUserInfo == nil {
            MBProgressHUD.show("用户信息异常，请重新登录", icon: nil, view: nil)
            // 跳转登录界面
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
            let userIconUrlStr = APP_DELEGATE.currentUserInfo?.avatar
            viewController.userAvatarUrl = userIconUrlStr ?? ""
            
            let nav = UINavigationController.init(rootViewController: viewController)
            self.present(nav, animated: true, completion: nil)
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
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
}
