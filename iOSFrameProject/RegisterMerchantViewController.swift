//
//  RegisterMerchantViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/6/21.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class RegisterMerchantViewController: UIViewController, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SelectMerchantAddressViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var merchantNameView: UIView!
    @IBOutlet weak var merchantNameTF: UITextField!
    
    
    @IBOutlet weak var merchantTypeView: UIView!
    @IBOutlet weak var merchantTypeTF: UITextField!
    
    
    
    @IBOutlet weak var merchantAgentNameView: UIView!
    @IBOutlet weak var merchantAgentNameTF: UITextField!
    
    
    
    @IBOutlet weak var merchantPhoneView: UIView!
    @IBOutlet weak var merchantPhoneTF: UITextField!
    
    
    
    @IBOutlet weak var merchantAddressView: UIView!
    @IBOutlet weak var merchantAddressTF: UITextField!
    
    
    
    @IBOutlet weak var merchantDescriptionView: UIView!
    @IBOutlet weak var merchantDescriptionTF: UITextView!
    
    @IBOutlet weak var merchantIconBtn: UIButton!
    
    @IBOutlet weak var merchantLicenseBtn: UIButton!
    
    @IBOutlet weak var manIDFrontBtn: UIButton!
    
    @IBOutlet weak var manIDBackBtn: UIButton!
    
    @IBOutlet weak var registerAgreementBtn: UIButton!
    
    @IBOutlet weak var applyRegisterBtn: UIButton!
    
    
    // keyBoard 上的选择栏
    fileprivate lazy var keyBoardTopView: UIView = {
        let topView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CELL_NORMAL_HEIGHT))
        topView.backgroundColor = UIColor.white
        
        let btnW: CGFloat = 60, btnH: CGFloat = 30
        
        // cancel
        let cancelBtn = UIButton.init(frame: CGRect(x: 10, y: (topView.height - btnH) / 2, width: btnW, height: btnH))
        cancelBtn.setTitle("取消", for: UIControl.State.normal)
        cancelBtn.setTitleColor(COLOR_DARK_GAY, for:.normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        cancelBtn.addTarget(self, action: #selector(keyBoardTopViewCancelBtnClick(sender:)), for: UIControl.Event.touchUpInside)
        topView.addSubview(cancelBtn)
        
        // sure
        let sureBtn = UIButton.init(frame: CGRect(x: SCREEN_WIDTH - btnW - 10, y: (topView.height - btnH) / 2, width: btnW, height: btnH))
        sureBtn.setTitle("确定", for: UIControl.State.normal)
        sureBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        sureBtn.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
        sureBtn.layer.masksToBounds = true
        sureBtn.layer.cornerRadius = CORNER_SMART
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        sureBtn.addTarget(self, action: #selector(keyBoardTopViewSureBtnClick(sender:)), for: UIControl.Event.touchUpInside)
        topView.addSubview(sureBtn)
        
        // 设置分割线
        let topLineView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.5))
        topLineView.backgroundColor = COLOR_SEPARATOR_LINE
        let bottomLineView = UIView.init(frame: CGRect(x: 0, y: topView.height - 0.5, width: SCREEN_WIDTH, height: 0.5))
        bottomLineView.backgroundColor = COLOR_SEPARATOR_LINE
        topView.addSubview(topLineView)
        topView.addSubview(bottomLineView)
        
        return topView
    }()
    
    
    // 懒加载
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePickerTem = UIImagePickerController.init()
        
        imagePickerTem.delegate = self
        imagePickerTem.allowsEditing = true
        return imagePickerTem
    }()
    
    
    fileprivate lazy var merchantTypeDataPicker: UIPickerView = {
        let dataPicker = UIPickerView.init()
        
        dataPicker.delegate = self
        dataPicker.dataSource = self
        
        return dataPicker
    }()
    
    fileprivate var merchantTypeDataSource: [MerchantTypeModel] = []
    fileprivate var selectedMerchantType: MerchantTypeModel?
    
    
    @IBOutlet weak var imgeHeightConstrait: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setViewUI()
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 初始化
        self.title = ""
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 获取当前定位信息
        self.getLocation()
        
        // 获取商家类型列表
        self.getMerchantTypeList()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - UIScrollViewDelegate
    // MARK: scrollViewDidScroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let alphaValue = (scrollView.contentOffset.y - NAVIGATION_AND_STATUS_HEIGHT) / 100.0
            if alphaValue > 0 {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(color: UIColorRGBA_Selft(r: 53, g: 201, b: 90, a: alphaValue)), for: .default)
            }
        }
    }
    
    // MARK: scrollViewWillBeginDragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - UIPikcerView Delegate
    // MARK: numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.merchantTypeDataSource.count
    }
    
    // MARK: titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.merchantTypeDataSource[row].name
    }
    
//    // MARK: didSelectRow
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.merchantTypeTF.text = self.merchantTypeDataSource[row]
//    }
    
    // MARK: rowHeightForComponent
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CELL_NORMAL_HEIGHT
    }
    
    
    // MARK: - UITextFieldDelegate
    // MARK: textFieldShouldBeginEditing
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.merchantAddressTF {
            // 地图标点选择
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectMerchantAddressView") as! SelectMerchantAddressViewControler
            viewController.customDelegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
            
            return false
        }
        
        return true
    }
    
    // MARK: shouldChangeCharactersIn
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        
        // 限制商家名称最大字数
        if textField == self.merchantNameTF {
            if nowString.count > WORDCOUNT_MERCHNAT_REGISTER_MERCHANT_NAME_MAX {
                MBProgressHUD.show("商家名称最大为50个字" , icon: nil, view: self.view)
                return false
            }
        }
        
        // 限制主负责人最大字数
        if textField == self.merchantAgentNameTF {
            if nowString.count > WORDCOUNT_MERCHNAT_REGISTER_MERCHANT_NAME_MAX {
                MBProgressHUD.show("主负责人最大为50个字" , icon: nil, view: self.view)
                return false
            }
        }
        
        // 限制联系电话最大字数
        if textField == self.merchantPhoneTF {
            if nowString.count > WORDCOUNT_USER_PHONE {
                MBProgressHUD.show("联系电话最长为11位数字" , icon: nil, view: self.view)
                return false
            }
        }
        
        // 限制商家地址最大字数
        if textField == self.merchantAddressTF {
            if nowString.count > WORDCOUNT_MERCHNAT_REGISTER_MERCHANT_ADDRESS_MAX {
                MBProgressHUD.show("商家地址最大为500个字" , icon: nil, view: self.view)
                return false
            }
        }
        
        
        return true
    }
    
    // MARK: - UITextViewDelegate
    // MAARK: shouldChangeTextInRange
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let textString = textView.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: text)
        
        // 限制商家描述最大字数
        if textView == self.merchantDescriptionTF {
            if nowString.count > WORDCOUNT_MERCHNAT_REGISTER_MERCHANT_DESCRIPTION_MAX {
                MBProgressHUD.show("商家描述最大为1000个字" , icon: nil, view: self.view)
                return false
            }
        }
        
        return true
    }
    
    
    //MARK:- UIImagePickerControllerDelegate
    // MARK: image picker controller
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey :Any]){
        let type:String = (info[.mediaType] as! String)
        //当选择的类型是图片
        if type=="public.image"
        {
            let dealImage = info[.originalImage] as? UIImage
            switch picker.view.tag {
            case 0:
                self.merchantIconBtn.setImage(nil, for: .normal)
                self.merchantIconBtn.setTitle(nil, for: .normal)
                self.merchantIconBtn.setBackgroundImage(dealImage, for: .normal)
            case 1:
                self.merchantLicenseBtn.setImage(nil, for: .normal)
                self.merchantLicenseBtn.setTitle(nil, for: .normal)
                self.merchantLicenseBtn.setBackgroundImage(dealImage, for: .normal)
            case 2:
                self.manIDFrontBtn.setImage(nil, for: .normal)
                self.manIDFrontBtn.setTitle(nil, for: .normal)
                self.manIDFrontBtn.setBackgroundImage(dealImage, for: .normal)
            default:
                self.manIDBackBtn.setImage(nil, for: .normal)
                self.manIDBackBtn.setTitle(nil, for: .normal)
                self.manIDBackBtn.setBackgroundImage(dealImage, for: .normal)
            }
            picker.dismiss(animated:true, completion:nil)
        }
    }
    
    
    // MARK: - SelectMerchantAddressViewDelegate
    // MARK: selectMerchantAddressViewSelectedStr
    func selectMerchantAddressViewSelectedStr(string: String) {
        self.merchantAddressTF.text = string
    }
    
    
    
    // MARK: Icon Select Click
    @IBAction func iconSelectButtonClick(_ sender: UIButton) {
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
        self.imagePicker.allowsEditing = false
        self.imagePicker.view.tag = sender.tag
        
        self.present(self.imagePicker, animated: true, completion:nil)
    }
    
    
    // MARK: 入驻协议点击
    @IBAction func registerAgreementBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if !sender.isSelected {
            return
        }
        
        // 如何获取碳币
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let webViewController = storyBoard.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
        webViewController.isAdaptNavigationHeight = true
        webViewController.pageUrlStr = WEBBASEURL + "/static/about/merchantJoin.html"
        webViewController.isShowWebPageTrack = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    // MARK: 入驻按钮点击
    @IBAction func applyRegisterBtn(_ sender: UIButton) {
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
        
        
        
        let image1 = self.merchantIconBtn.backgroundImage(for: .normal)
        let image2 = self.merchantLicenseBtn.backgroundImage(for: .normal)
        let image3 = self.manIDFrontBtn.backgroundImage(for: .normal)
        let image4 = self.manIDBackBtn.backgroundImage(for: .normal)
        
        if self.merchantNameTF.text == "" || self.merchantTypeTF.text == "" || self.merchantAgentNameTF.text == "" || self.merchantPhoneTF.text == "" || self.merchantAddressTF.text == "" || self.merchantDescriptionTF.text == "" || image1 == nil || image2 == nil || image3 == nil || image4 == nil {
            MBProgressHUD.show("请填写完所有内容项", icon: nil, view: self.view)
            
            return
        }
        
        // 判断手机号是否正确
        // 手机号
        // 判断手机号位数是否为11位
        if (self.merchantPhoneTF?.text?.count)! != WORDCOUNT_USER_PHONE {
            MBProgressHUD.show("手机号格式不对", icon: nil, view: self.view)
            return
        }
        
        // 判断是否为手机号
        if !NSString.checkPhoneNumInput(withPhoneNum: self.merchantPhoneTF.text) {
            MBProgressHUD.show("手机号格式不对", icon: nil, view: self.view)
            return
        }
        
        
        // 判断是否同意协议
        if !self.registerAgreementBtn.isSelected {
            MBProgressHUD.show("请同意《商家入驻平台协议》", icon: nil, view: self.view)
            return
        }
        
        
        // 申请入驻
        self.uploadMerchantRegisterInformation(image1: image1!, image2: image2!, image3: image3!, image4: image4!)
    }
    
    
    // MARK: keyBoard Top View -- cancelBtnClick
    @objc func keyBoardTopViewCancelBtnClick(sender: UIButton) {
        self.view.endEditing(true)
    }
    // MARK: keyBoard Top View -- sureBtnClick
    @objc func keyBoardTopViewSureBtnClick(sender: UIButton) {
        self.selectedMerchantType = self.merchantTypeDataSource[self.merchantTypeDataPicker.selectedRow(inComponent: 0)]
        self.merchantTypeTF.text = self.selectedMerchantType?.name
        self.view.endEditing(true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.scrollViewDidScroll(self.tableView)
    }
    
    // MARK:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColorRGBA_Selft(r: 53, g: 201, b: 90, a: 1.0)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: 获取商家类别
    func getMerchantTypeList() {
        MBProgressHUD.showMessage("", to: self.view)
        MerchantBusiness.shareIntance.responseWebGetMerchantTypeList(responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.merchantTypeDataSource = objectSuccess as! [MerchantTypeModel]
            
            self.merchantTypeDataPicker.reloadAllComponents()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: 上传商家入驻信息
    func uploadMerchantRegisterInformation(image1: UIImage, image2: UIImage, image3: UIImage, image4: UIImage) {
        
        
        let uploadImagesArray = [["image": image1, "name" : "logoFile"],
                                 ["image": image2, "name" : "licenseFile"],
                                 ["image": image3, "name" : "IDCardPosFile"],
                                 ["image": image4, "name" : "IDCardNegFile"]]
        
        // 去除字符串中首尾换行，中间的连续换行
        var publistTempStr = self.merchantDescriptionTF.text as NSString
        publistTempStr = publistTempStr.trimmingCharacters(in: CharacterSet.newlines) as NSString
        for i in 0..<WORDCOUNT_MERCHNAT_REGISTER_MERCHANT_DESCRIPTION_MAX {
            myPrint(message: "\(i)")
            publistTempStr = publistTempStr.replacingOccurrences(of: "\n\n\n", with: "\n\n") as NSString
        }
        publistTempStr = publistTempStr.replacingOccurrences(of: "\n\n\n", with: "\n\n") as NSString

        // region Code
        var regionCode = DEFAULT_LOCATIONFAILED_CODE
        if APP_DELEGATE.locationAddress != nil {
            let cityInfo = AddressPickerDemo.getCityRelativeInfo(with: APP_DELEGATE.locationAddress?.city)
            if cityInfo != nil {
                regionCode = cityInfo!["regionCode"] as! String
            }
        }
        
        // 对图片描述进行编码
        let paramters = ["name" : self.merchantNameTF.text ?? "",
            "typeCode" : self.selectedMerchantType?.code ?? "",
            "trueName" : self.merchantAgentNameTF.text ?? "",
            "contact" : self.merchantPhoneTF.text ?? "",
            "introduction" : publistTempStr,
            "regionCode" : regionCode,
            "address" : self.merchantAddressTF.text ?? "",
            "latitude" : "\(UserDefaults.standard.double(forKey: LOCATION_LATITUDE))",
            "longitude" : "\(UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))"] as [String : Any]

        MBProgressHUD.showMessage("", to: self.view)
        WebDataResponseInterface.shareInstance.SessionManagerWebDataUpload(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UploadMerchantRegisterInfo, formData: { (formData) in
            for dict in uploadImagesArray {
                let imageDat = (dict["image"] as! UIImage).jpegData(compressionQuality: 0.6)
                let fileName = dict["name"] as! String    // files
                formData.appendPart(withFileData: imageDat!, name: fileName, fileName: fileName+"jpg", mimeType: "image/jpg")
            }
        }, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: { (proccess)in
            // 进度
            DispatchQueue.main.async(execute: {
                myPrint(message: "proccess = \(proccess) ====== \(Thread.current)")
            })
        }, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if objectSuccess != nil {
                MBProgressHUD.show("入驻成功，信息正在审核中...", icon: nil, view: self.view)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    self.navigationController?.popViewController(animated: true)
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
    

}


extension RegisterMerchantViewController {
    func setViewUI() {
        
        // 设置图片高度适配
        let advertiseImage = UIImage.init(named: "merchant_register_top.png")
        self.imgeHeightConstrait.constant = SCREEN_WIDTH / ((advertiseImage?.size.width)! / (advertiseImage?.size.height)!)
        
        self.tableView.tableHeaderView?.backgroundColor = UIColor.white
        self.tableView.tableFooterView = UIView.init()
        self.tableView.tableHeaderView?.height = (1012-212) + self.imgeHeightConstrait.constant
        self.tableView.delegate = self
        
        // 设置View 边框和圆角
        self.merchantNameView.layer.masksToBounds = true
        self.merchantNameView.layer.cornerRadius = CORNER_NORMAL
        self.merchantNameView.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.merchantNameView.layer.borderWidth = BORDER_WIDTH
        
        self.merchantTypeView.layer.masksToBounds = true
        self.merchantTypeView.layer.cornerRadius = CORNER_NORMAL
        self.merchantTypeView.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.merchantTypeView.layer.borderWidth = BORDER_WIDTH
        
        self.merchantAgentNameView.layer.masksToBounds = true
        self.merchantAgentNameView.layer.cornerRadius = CORNER_NORMAL
        self.merchantAgentNameView.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.merchantAgentNameView.layer.borderWidth = BORDER_WIDTH
        
        self.merchantPhoneView.layer.masksToBounds = true
        self.merchantPhoneView.layer.cornerRadius = CORNER_NORMAL
        self.merchantPhoneView.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.merchantPhoneView.layer.borderWidth = BORDER_WIDTH
        
        self.merchantAddressView.layer.masksToBounds = true
        self.merchantAddressView.layer.cornerRadius = CORNER_NORMAL
        self.merchantAddressView.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.merchantAddressView.layer.borderWidth = BORDER_WIDTH
        
        self.merchantDescriptionView.layer.masksToBounds = true
        self.merchantDescriptionView.layer.cornerRadius = CORNER_NORMAL
        self.merchantDescriptionView.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.merchantDescriptionView.layer.borderWidth = BORDER_WIDTH
        
        // 设置button样式
        self.merchantIconBtn.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.merchantIconBtn.layer.borderWidth = BORDER_WIDTH * 2
        
        self.merchantLicenseBtn.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.merchantLicenseBtn.layer.borderWidth = BORDER_WIDTH * 2
        
        self.manIDFrontBtn.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.manIDFrontBtn.layer.borderWidth = BORDER_WIDTH * 2
        
        self.manIDBackBtn.layer.borderColor = COLOR_SEPARATOR_LINE.cgColor
        self.manIDBackBtn.layer.borderWidth = BORDER_WIDTH * 2
        
        
        // 设置 button
        self.merchantIconBtn.setTopAndBottomImage(#imageLiteral(resourceName: "merchant_icon_add.png"), withTitle: "上传商家图标", for: .normal, andTintColor: COLOR_DARK_GAY, withTextFont: UIFont.systemFont(ofSize: FONT_SMART_SIZE), andImageTitleGap: 25)
        
        self.merchantLicenseBtn.setTopAndBottomImage(#imageLiteral(resourceName: "merchant_icon_add.png"), withTitle: "上传商家执照", for: .normal, andTintColor: COLOR_DARK_GAY, withTextFont: UIFont.systemFont(ofSize: FONT_SMART_SIZE), andImageTitleGap: 25)
        
        self.manIDFrontBtn.setTopAndBottomImage(#imageLiteral(resourceName: "merchant_icon_add.png"), withTitle: "上传负责人身份证(人像面)", for: .normal, andTintColor: COLOR_DARK_GAY, withTextFont: UIFont.systemFont(ofSize: 11.0), andImageTitleGap: 25)
        
        self.manIDBackBtn.setTopAndBottomImage(#imageLiteral(resourceName: "merchant_icon_add.png"), withTitle: "上传负责人身份证(国徽面)", for: .normal, andTintColor: COLOR_DARK_GAY, withTextFont: UIFont.systemFont(ofSize: 11.0), andImageTitleGap: 25)
        
        self.applyRegisterBtn.layer.masksToBounds = true
        self.applyRegisterBtn.layer.cornerRadius = self.applyRegisterBtn.height / 2
        
        
        // set TextField
        self.merchantTypeTF.placeholder = "请选择商家类型"
        let merchantTypeRightImageView = UIImageView.init(image: #imageLiteral(resourceName: "merchant_type_select.png"))
        merchantTypeRightImageView.contentMode = .scaleAspectFit
        merchantTypeRightImageView.width += 5.0
        self.merchantTypeTF.rightViewMode = .always
        self.merchantTypeTF.rightView = merchantTypeRightImageView
        self.merchantTypeTF.inputView = self.merchantTypeDataPicker
        self.merchantTypeTF.inputAccessoryView = self.keyBoardTopView
        
        let merchantAddressRightImageView = UIImageView.init(image: #imageLiteral(resourceName: "merchant_register_location.png"))
        merchantAddressRightImageView.contentMode = .scaleAspectFit
        merchantAddressRightImageView.width += 5.0
        self.merchantAddressTF.rightViewMode = .always
        self.merchantAddressTF.rightView = merchantAddressRightImageView
        
        // 设置代理
        self.merchantNameTF.delegate = self
        self.merchantAgentNameTF.delegate = self
        self.merchantPhoneTF.delegate = self
        self.merchantAddressTF.delegate = self
        self.merchantDescriptionTF.delegate = self
        
        // 设置手势或响应事件
        self.merchantAddressTF.rightView?.isUserInteractionEnabled = true
        self.merchantAddressTF.rightView?.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            // 地图标点选择
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectMerchantAddressView") as! SelectMerchantAddressViewControler
            viewController.customDelegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
    }
    
    
    
    // MARK: 获取当前位置信息
    func getLocation() {
        // 获取当前定位信息
        APP_DELEGATE.singleStartLocationOnce(locationSuccess: { (locationReGeocode, location) in
            // 定位成功
            APP_DELEGATE.locationAddress = locationReGeocode
            
            self.merchantAddressTF.text = locationReGeocode.formattedAddress
        }) { (error) in
            // 定位失败
            self.merchantAddressTF.text = ""
        }
    }
}
