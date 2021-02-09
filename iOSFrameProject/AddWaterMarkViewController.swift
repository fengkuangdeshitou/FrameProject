//
//  AddWaterMarkViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/18.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol AddWaterMarkViewDelegate: NSObjectProtocol {
    func addWaterMarkSuccess(newImage: UIImage)
}


class AddWaterMarkViewController: UIViewController, AppDelegateCustomDelegate, WriteWaterViewDelegate, MyPasterDelegate, EditPhotoViewDelegate {
    
    weak var delegate: AddWaterMarkViewDelegate?
    
    var originImage: UIImage?
    var dealImage: UIImage?
    fileprivate var waitDealImage: UIImage?
    fileprivate var currentLocationAddress = "" // 当前图片的拍着地址
    fileprivate var imageSize: CGSize?
    fileprivate var takePhotoDateInterval: TimeInterval?
    fileprivate var randomPm25Value: Int?
    
    fileprivate var locationCitysArray: [String]?   // 拍照定位的相似地址信息
    
    var senceData: PhotoModel?
    
    fileprivate var location: CLLocation?
    
    @IBOutlet weak var showTopView: UIView!
    
    @IBOutlet weak var waterScrollView: UIScrollView!
    
    
    fileprivate var shortDescription: String?
    fileprivate var longDescription: String?
    
    fileprivate var waterTextStr: String?             // 文字水印字符串
    
    fileprivate let waterMarkImagesArray: [String] = ["edit_watermark_air", "edit_watermark_text", "water_mark2", "water_mark3", "water_mark4", "water_mark5", "water_mark6", "water_mark7", "water_mark8", "water_mark9", "water_mark10", "water_mark11", "water_mark12", "water_mark13", "water_mark14", "water_mark15"]
    fileprivate var pasterViewArray: [UIView] = []
    
    // set pastView
    fileprivate lazy var myPasterView: MyPaster = {
        let paster = MyPaster.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 89 - NAVIGATION_AND_STATUS_HEIGHT))
        paster.delegate = self
        paster.backgroundColor = UIColor.black
        paster.deleteIcon = #imageLiteral(resourceName: "water_mark_close.png");
        paster.sizeIcon = #imageLiteral(resourceName: "water_mark_zoom.png");
        paster.rotateIcon = #imageLiteral(resourceName: "water_mark_edit.png");
        
        return paster
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "添加水印"
        self.view.backgroundColor = UIColor.black
        self.longDescription = ""
        self.senceData = PhotoModel.init()
        
        // 设置导航栏
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        let rightBarBtnItem = UIBarButtonItem.init(title: "",style:.plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        // set PastView
        self.myPasterView.originImage = self.originImage
        self.showTopView.addSubview(self.myPasterView)
        
        // 设置water响应事件
        let imageWH = 70
        for (i, imgePath) in self.waterMarkImagesArray.enumerated() {
            let waterMarkImageView = UIImageView.init(frame: CGRect(x: 10 * (i + 1) + i * imageWH, y: 8, width: imageWH, height: imageWH))
            waterMarkImageView.image = UIImage.init(named: imgePath)
            waterMarkImageView.backgroundColor = UIColor.white//UIColor(red: CGFloat(Double(arc4random_uniform(256) + 125)/255.0), green: CGFloat(Double(arc4random_uniform(256) + 125)/255.0), blue: CGFloat(Double(arc4random_uniform(256) + 125)/255.0), alpha: 1.0)
            
            waterMarkImageView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(waterMarkOtherImageViewClick(gesture:)))
            waterMarkImageView.addGestureRecognizer(gesture)
            gesture.view?.tag = i
            
            self.waterScrollView.addSubview(waterMarkImageView)
        }
        self.waterScrollView.contentSize = CGSize(width: 10 * (self.waterMarkImagesArray.count + 1) + self.waterMarkImagesArray.count * imageWH, height: 20)
        self.waterScrollView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        
        
        // 图片处理
        self.DealImagethings()
    }
    
    // MARK: 增加图片贴图或天@objc 气贴图
    @objc func addWaterAirPasterView(gesture: UIGestureRecognizer) {
        
        let imagePaster = ImagePaster.init()
        imagePaster.indexTag = (gesture.view?.tag)!
        if gesture.view?.tag == 0 {
            imagePaster.textStr = self.shortDescription!
            imagePaster.image = AddWaterMarkViewController.setWaterMarkView(senceData: self.senceData!, shortDescription: self.shortDescription!)
        } else {
            imagePaster.image = UIImage.init(named: self.waterMarkImagesArray[(gesture.view?.tag)!])
        }
        self.myPasterView.add(imagePaster)
    }

    
    // MARK: 选择水印点@objc 击响应
    @objc func waterMarkOtherImageViewClick(gesture: UIGestureRecognizer) {
        if gesture.view?.tag == 0 {
            // 添加天气水印
            self.addWaterAirPasterView(gesture: gesture)
        } else if gesture.view?.tag == 1 {
            // 添加纯文字
            let viewController = WriteWaterTextViewController.init(nibName: "WriteWaterTextViewController", bundle: nil)
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overFullScreen
            viewController.delegate = self
            viewController.indexTag = 1
            self.present(viewController, animated: true, completion: nil)
        } else {
            // 添加贴图
            // 添加天气水印
            self.addWaterAirPasterView(gesture: gesture)
        }
    }
    
    
    // MARK: 图片处理
    func DealImagethings() {
        // 获取拍摄时间
        self.takePhotoDateInterval = Date().timeIntervalSince1970
        
        // 加入等比例缩放  -- 缩放origin IMage 的尺寸
        if Int((self.originImage?.size.width)!) >= Int((self.originImage?.size.height)!) {
            let imgNewHeight = UIImage.getImageWithOrHeight(with: self.originImage, andWidht: Float(SCREEN_WIDTH/2), andHeight: 0.0)
            imageSize = CGSize.init(width: SCREEN_WIDTH, height: CGFloat(imgNewHeight * 2))
        } else {
            let imgNewHeight = UIImage.getImageWithOrHeight(with: self.originImage, andWidht: 0.0, andHeight: Float(SCREEN_HEIGHT/2))
            imageSize = CGSize.init(width: CGFloat(imgNewHeight * 2), height: SCREEN_HEIGHT)
        }
        
        // 获取图片的拍摄位置
        MBProgressHUD.showMessage("正在测算PM2.5", to: nil)
        //        MBProgressHUD.showMessage("获取图片拍摄位置", to: self.view)
        APP_DELEGATE.customDelegate = self
        APP_DELEGATE.singleStartLocationOnce(locationSuccess: { (locationReGeocode, location) in
            //            MBProgressHUD.hide(for: self.view)
            // 定位成功
            // 更新手机的定位位置
            self.location = location
            APP_DELEGATE.locationAddress = locationReGeocode
            self.currentLocationAddress = locationReGeocode.formattedAddress
            
            // 获取空气质量数据
            //            MBProgressHUD.showMessage("正在测算PM2.5", to: self.view)
            self.getAirDataWithResult(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
            
        }) { (error) in
            //            MBProgressHUD.hide(for: self.view)
            
            // 定位失败
            self.currentLocationAddress = "未获取到拍摄地址"
            
            // 获取空气质量数据
            //            MBProgressHUD.showMessage("正在测算PM2.5", to: self.view)
            self.getAirDataWithResult(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
        }
    }
    
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        if self.waitDealImage != nil {
            // 跳转到图片编辑界面
            let storyBorad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let viewController = storyBorad.instantiateViewController(withIdentifier: "EditPhotoView") as! EditPhotoViewController
            viewController.originImage = self.originImage
            viewController.dealImage = self.waitDealImage
            viewController.senceData = self.senceData
            viewController.location = self.location
            viewController.editPhotoDelegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            //self.navigationController?.popViewController(animated: true)
            APP_DELEGATE.alertCommonShow(title: "退出此次编辑", message: "", btn1Title: "取消", btn2Title: "确定", vc: self) { (btnIndex) in
                if btnIndex == 1 {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }
    }
    
    // MARK: right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        let storyBorad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        
        // 跳转到图片编辑界面
        let viewController = storyBorad.instantiateViewController(withIdentifier: "EditPhotoView") as! EditPhotoViewController
        viewController.originImage = self.originImage
        viewController.dealImage = self.myPasterView.getImage()
        viewController.senceData = self.senceData
        viewController.location = self.location
        viewController.editPhotoDelegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: -  MyPasterDelegate
    // MARK: pasterEidt
    func myPaster(_ myPaster: MyPaster!, pasterEdit paster: Paster!) {
        let viewController = WriteWaterTextViewController.init(nibName: "WriteWaterTextViewController", bundle: nil)
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.pasterView = paster

        viewController.delegate = self
        viewController.indexTag = paster.indexTag
        self.present(viewController, animated: true, completion: nil)
    }

    
    
    // MARK: - WriteWaterViewDelegate
    // MARK: writeWaterTextSuccess
    func writeWaterTextSuccess(textView: UITextView, pasterView: Paster?) {
        if pasterView == nil {
            // 创建
            self.setMarkTextPassTextView(textView: textView)
        } else {
            // get image Item
            var myPasterItem: MyPasterItem? = nil
            for view in self.myPasterView.contentImageView.subviews {
                if view.tag == pasterView?.indexTag {
                    myPasterItem = view as? MyPasterItem
                    break;
                }
            }
            
            if pasterView?.classForCoder == TextPaster.classForCoder() {
                // 修改纯文字
                let textPaster = pasterView! as! TextPaster
                textPaster.text = textView.text
                textPaster.font = textView.font
                textPaster.textColor = textView.textColor
                let textPasterItem = myPasterItem as! MyTextPasterItem
                textPasterItem.paster = textPaster
            } else {
                let imagePaster = pasterView! as! ImagePaster
                imagePaster.textStr = textView.text
                imagePaster.image = AddWaterMarkViewController.setWaterMarkView(senceData: self.senceData!, shortDescription: textView.text)
                let imagePasterItem = myPasterItem as! MyImagePasterItem
                imagePasterItem.paster = imagePaster
            }
        }
    }
    
    
    // MARK: - EditPhotoViewDelegate
    // MARK: editPhotoViewEditLabelClick
    func editPhotoViewEditLabelClick(waitDealImage: UIImage) {
        self.waitDealImage = waitDealImage
    }
    
    // MARK: editPhotoViewPublishImagesSuccess
    func editPhotoViewPublishImagesSuccess() {
        
    }
    
    
    // 设置纯文字贴图
    func setMarkTextPassTextView(textView: UITextView) {
        
        let textPaster = TextPaster.init()
        textPaster.indexTag = textView.tag
        textPaster.text = textView.text
        textPaster.font = textView.font
        textPaster.textColor = textView.textColor
        //        textPaster.backgroundImage = #imageLiteral(resourceName: "water_mark7.png")
        self.myPasterView.add(textPaster)
    }

    // MARK: 获取纯文字水印图片
    func getMarkTextImage(textView: UITextView) -> UIImage {
        
        
        let longTextLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: textView.width, height: 0.0))
        longTextLabel.numberOfLines = 0
        longTextLabel.text = textView.text
        longTextLabel.textColor = textView.textColor
        
        let size = (textView.font?.pointSize)! > CGFloat(250.0) ? 250.0 : textView.font?.pointSize
        longTextLabel.font = UIFont(name: (textView.font?.fontName)!, size: size!)
//        longTextLabel.font = textView.font
        
        let textHeight = UILabel.getSpaceLabelHeight(longTextLabel.text, with: longTextLabel.font, withWidth: longTextLabel.width, andLineSpaceing: 3.0)
        if textHeight < 80 {
            longTextLabel.height = 120.0
        } else {
            let str = String(format: "%.0f", textHeight)
            longTextLabel.height = CGFloat(Float(str)!)
        }
        
        let image = UIImage.init(view: longTextLabel)
        return image!
    }
    
    
    // MARK: cancel
    func editeCancel() {
        // 取消
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
    
    
    // MARK: 获取空气质量数据
    func getAirDataWithResult(latitude: Double, longitude: Double) {
        let paramters = ["longitude" : "\(longitude)", "latitude": "\(latitude)"]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebDataALLParamters(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_StationHourDataGetNearbyPm25, parameters: paramters as NSDictionary, resquestType: .POST, outRequestTime: 5, responseProgress: {_ in}, responseSuccess: { (objectSuccess) in
            if objectSuccess == nil {
                // 获取空气质量2
                self.getAirQualityDataWithCity(cityName: APP_DELEGATE.locationAddress?.city)
//                self.getAirQualityDataRankWithCityName(cityName: APP_DELEGATE.locationAddress?.city)
            } else {
                let pm25Value = objectSuccess as! Int
                if pm25Value < 5 && APP_DELEGATE.locationAddress != nil {
                    // 获取空气质量2
                    self.getAirQualityDataWithCity(cityName: APP_DELEGATE.locationAddress?.city)
//                    self.getAirQualityDataRankWithCityName(cityName: APP_DELEGATE.locationAddress?.city)
                } else {
                    // 存储本次的PM2.5值
                    UserDefaults.standard.set(pm25Value, forKey: PHOTO_PM_25)
                    UserDefaults.standard.synchronize()
                    // 图片美化和PM2.5校正
                    self.imageBeautyAndPM25Check(pm25Value: pm25Value)
                }
            }
        }) { (error) in
            myPrint(message: "error:\(error)")
            // 获取空气质量失败后 -- 获取空气质量2
            self.getAirQualityDataWithCity(cityName: APP_DELEGATE.locationAddress?.city)
//            self.getAirQualityDataRankWithCityName(cityName: APP_DELEGATE.locationAddress?.city)
        }
    }
    
    // MARK: 获取空气质量数据2
    func getAirQualityDataWithCity(cityName: String?) {
        if cityName == nil {
            self.imageBeautyAndPM25Check(pm25Value: 10)
            return
        }
        
        
          //  获取城市的空气质量数据
        WebDataResponseInterface.shareInstance.sessionManagerOriginWebData(strUrl: "http://www.foverle.com", strApi: "/api/weather/airqality/" + cityName!, parameters: nil, resquestType: RequestType.GET, outRequestTime: 2, AESCPwd: nil, isTipInfo: nil, responseProgress: {_ in}, responseSuccess: { (objectSuccess) in
            let result = WebResultModel<CityAirQualityModel>.init(json: JSON.init(objectSuccess as Any))
            if result.status == ResponseCodeType.success.rawValue {
                // 获取成功
                self.imageBeautyAndPM25Check(pm25Value: (result.data?.pm25)!)
            } else {
                var pm25Value = UserDefaults.standard.integer(forKey: PHOTO_PM_25)
                if pm25Value < 5 {pm25Value = 10}
                self.imageBeautyAndPM25Check(pm25Value: pm25Value)
            }
        }) { (error) in
            var pm25Value = UserDefaults.standard.integer(forKey: PHOTO_PM_25)
            if pm25Value < 5 {pm25Value = 10}
            self.imageBeautyAndPM25Check(pm25Value: pm25Value)
        }
    }
    
    
    // MARK: 获取空气质量数据3
    func getAirQualityDataRankWithCityName(cityName: String?) {
        if cityName == nil {
            self.imageBeautyAndPM25Check(pm25Value: 10)
            return
        }
        
        OtherBusiness.shareIntance.responseWebGetRankList(responseSuccess: { (resonseSuccess) in
            let citysDataSource = resonseSuccess as! [CityHourDataModel]
            
            // 查询PM2.5
            var pm25Value = UserDefaults.standard.integer(forKey: PHOTO_PM_25)
            for item in citysDataSource {
                if item.cityName == cityName {
                    pm25Value = item.pm25!
                    break
                }
            }
            if pm25Value < 5 {pm25Value = 10}
            self.imageBeautyAndPM25Check(pm25Value: pm25Value)
            
        }) { (error) in
            var pm25Value = UserDefaults.standard.integer(forKey: PHOTO_PM_25)
            if pm25Value < 5 {pm25Value = 10}
            self.imageBeautyAndPM25Check(pm25Value: pm25Value)
        }
    }
    
    
    // MARK: 图片美化和PM2.5校正
    func imageBeautyAndPM25Check(pm25Value: Int) {
        // 1. 图片去雾
        let imageProce = imageProcessor.shared()
        imageProce?.imageProcess(UIImage.scal(toSize: self.originImage, size: CGSize(width: 50, height: 50)))
        self.dealImage = UIImage.dealHBSImage(UIImage.fixOrientation(self.originImage), andLight: 0.0, andContrast: 1.05, andsaturation: 2.0)
        //        self.dealImage = tools.dealHBSImage(tools.fixOrientation(self.originImage), andLight: 0.0, andContrast: 1.05, andsaturation: 2.0)
        
        // 2. 计算图片中的PM2.5
        let arrayGetPM2_5 = imageProce?.getPM25(byCA: Double((imageProce?.ca)!)) as! [String]
        var averAgePM2_5 = (Int(arrayGetPM2_5[1])!+Int(arrayGetPM2_5[0])!)/2;
        if averAgePM2_5 < 0 {averAgePM2_5 = -averAgePM2_5;}
        
        // 3. 将大气光值计算得到的pm2.5的范围和周围环境的pm2.5值进行拟合运算，获取合理的pm2.5的值
        if pm25Value <= 5 {
            let pm25 = averAgePM2_5 < 100 ? averAgePM2_5 : 80
            self.randomPm25Value = imageProce?.fittingCalculationForA(toPm25Range: arrayGetPM2_5, andSurroundingPm25: pm25)
        } else {
            self.randomPm25Value = imageProce?.fittingCalculationForA(toPm25Range: arrayGetPM2_5, andSurroundingPm25: pm25Value)
        }
        if self.randomPm25Value! <= 5 {  // 防止Pm2.5小于等于5
            self.randomPm25Value = Int(NSString.randomString(with: "10"))
        } else {
            self.randomPm25Value = Int(NSString.randomString(with: String(self.randomPm25Value!)))
        }
        
        MBProgressHUD.hide()
        MBProgressHUD.hide(for: self.view, animated: true)
        
        // 填充数据
        if APP_DELEGATE.locationAddress != nil {
            self.senceData?.address = WeatherViewController.getStreetAddress(isAddDistrict: true)
        }
        
        self.senceData?.pm25 = self.randomPm25Value
        self.senceData?.takeTime = self.takePhotoDateInterval
        
        // 显示图片
        self.myPasterView.originImage = self.dealImage
        // 添加水印
        let labeltextDict = ShowPhotoViewController.airQualityChangeToString(pm25: (self.senceData?.pm25)!)
        self.shortDescription = labeltextDict["title"]
        let imageTemp = UIImageView.init()
        let gestureTemp = UITapGestureRecognizer.init(target: self, action: #selector(addWaterAirPasterView(gesture:)))
        imageTemp.addGestureRecognizer(gestureTemp)
        imageTemp.tag = 0
        self.addWaterAirPasterView(gesture: gestureTemp)
    }
    
    
    
    // MARK: 获取获取水印图片
    static func setWaterMarkView(senceData: PhotoModel, shortDescription: String) -> UIImage {
        // 设置水印页面
        let waterMarkView = WaterMarkOneView.shareInstance()
        waterMarkView?.showAddress = senceData.address
        waterMarkView?.showPM25 = senceData.pm25
        waterMarkView?.showPM25LevelStr = NSString.init(pm25LevelDescription: senceData.pm25!)! as String
        waterMarkView?.showDesciption = shortDescription
        waterMarkView?.loadInitData()
        let image = UIImage.init(view: waterMarkView)
        
        return image!
    }
}



extension UIImageView:NSCopying
{
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let label = UIImageView()
        
        var outCount:UInt32
        
        var propertyArray:[NSString] = [NSString]()
        
        outCount = 0
        let peopers:UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(UIImageView.classForCoder(), &outCount)!
        
        let count:Int = Int(outCount);
        
        for i in 0...(count - 1)
        {
            let method = peopers[i]
            
            let sel = method_getName(method)
            
            let methodName = sel_getName(sel)
            
            let na:NSString = NSString.init(utf8String: methodName)!
            
            propertyArray.append(na);
            
        }
        
        // 不要忘记释放内存，否则C语言的指针很容易成野指针的
        free(peopers)
        
        for i in 8...(count - 6)
        {
            let name  = propertyArray[i]
            let value = self.value(forKey: name as String)
            label.setValue(value, forKey: name as String)
        }
        
        return label
    }
}

