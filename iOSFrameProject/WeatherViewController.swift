//
//  WeatherViewController.swift
//  ECOCityProject
//
//  Created by 陈帆 on 2017/12/14.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

let WEATHER_IS_SHOW_AUTO_KEY = "weatherIsShowAutoKey"       // 是否自动显示天气窗口key

@objc protocol WeatherViewDelegate {
    
    /// 城市选择回调
    @objc optional func weatherViewSelectedCity()
    
    /// 用户头像点击回调
    @objc optional func weatherViewUserIcon()
    
    /// 背景图像点击
    @objc optional func weatherViewBackground()
    
    /// 更新天气数据回调
    @objc optional func weatherRefleshWeatherData()
}

class WeatherViewController: UIViewController, AMapSearchDelegate {
    
    public var isAutoDismiss: Bool?
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var showAlertView: UIView!
    
    @IBOutlet weak var showTemperatureLB: UILabel!
    
    @IBOutlet weak var showWeatherLB: UILabel!
    
    @IBOutlet weak var showLocationLB: UIButton!
    
    @IBOutlet weak var showWindDirectionLB: UIButton!
    
    @IBOutlet weak var showWindSpeedLB: UIButton!
    
    @IBOutlet weak var showHumidityLB: UIButton!
    
    @IBOutlet weak var showAutoTipBtn: UIButton!
    
    @IBOutlet weak var showUpdateTimeLB: UILabel!
    
    @IBOutlet weak var showPM25BgView: UIView!
    
    private var isShowAlertView: Bool = true
    
    weak var weatherDelegate: WeatherViewDelegate?
    
    // 点击事件响应枚举
    enum ViewClickType {
        case selectedCity           // 城市选择
        case weather                // 天气点击
        case userIcon               // 用户头像点击
        case backgroundView         // 背景view点击
    }
    
    private var viewClickType: ViewClickType = .weather
    
    
    // map search api
    fileprivate lazy var mapSearch: AMapSearchAPI = {
        let mapSearchTemp = AMapSearchAPI.init()
        mapSearchTemp?.delegate = self
        return mapSearchTemp!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.showAlertView.isHidden = true
        self.showAutoTipBtn.isSelected = UserDefaults.standard.bool(forKey: WEATHER_IS_SHOW_AUTO_KEY)
        
        // 设置点击背景退出天气界面
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            // 显示动画
            if self.isShowAlertView {
                self.isShowAlertView = false
                self.setAnimation(isShow: self.isShowAlertView)
            }
        }))
        
        // 设置天气数据
        self.setWeatherData(pm25: APP_DELEGATE.currentLivePm25!)
        
        // 设置多少秒后执行操作
        if self.isAutoDismiss != nil && self.isAutoDismiss! {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                // 显示动画
                self.isShowAlertView = false
                self.setAnimation(isShow: self.isShowAlertView)
            }
        }
    }
    
    
    // MARK: 设置天气数据
    func setWeatherData(pm25: Int) {
        APP_DELEGATE.currentLivePm25 = pm25
        // 温度
        self.showTemperatureLB.text = "\(APP_DELEGATE.locationWeather?.temperature! ?? "0°")°"
        // 天气
        self.showWeatherLB.text = APP_DELEGATE.locationWeather?.weather!
        self.showWeatherLB.adjustsFontSizeToFitWidth = true
        
        // 定位
        self.showLocationLB.isHidden = false
        if APP_DELEGATE.currenctSelectedCity == APP_DELEGATE.locationAddress?.city {
            if APP_DELEGATE.locationAddress != nil {
                self.showLocationLB.setTitle(WeatherViewController.getStreetAddress(isAddDistrict: false), for: .normal)
            } else {
                self.showLocationLB.setTitle(APP_DELEGATE.currenctSelectedCity, for: .normal)
            }
            self.showLocationLB.setImage(#imageLiteral(resourceName: "home_location_icon.png"), for: .normal)
        } else {
            self.showLocationLB.setTitle(APP_DELEGATE.currenctSelectedCity, for: .normal)
            self.showLocationLB.setImage(nil, for: .normal)
        }
        
        
        // 风向
        self.showWindDirectionLB.setTitle(" \(APP_DELEGATE.locationWeather?.windDirection! ?? "")风", for: .normal)
        if APP_DELEGATE.locationWeather?.windDirection! == "无风向" || APP_DELEGATE.locationWeather?.windDirection! == "旋转不定" {
            self.showWindDirectionLB.setTitle(" \(APP_DELEGATE.locationWeather?.windDirection! ?? "")", for: .normal)
        }
        
        // 风力
        self.showWindSpeedLB.setTitle(" \(APP_DELEGATE.locationWeather?.windPower! ?? "")级", for: .normal)
        // 湿度
        self.showHumidityLB.setTitle(" \(APP_DELEGATE.locationWeather?.humidity! ?? "")%", for: .normal)
        
        // 发布时间
        let reportTime = NSDate.init(from: APP_DELEGATE.locationWeather?.reportTime!, andFormatterString: "yyyy-MM-dd HH:mm:ss")
//        let reportTime = tools.date(from: APP_DELEGATE.locationWeather?.reportTime!, andFormatterString: "yyyy-MM-dd HH:mm:ss")
        self.showUpdateTimeLB.text = NSDate.formattingTimeCanEasyRead(reportTime! as Date)
//        self.showUpdateTimeLB.text = tools.formattingTimeCanEasyRead(reportTime)
        
        // PM2.5背景色
        let pm25Color = colorPm25WithValue(pm25Value: pm25)
        self.showPM25BgView.backgroundColor = pm25Color.withAlphaComponent(0.6)
    }
    
    // MARK: 城市选择点击
    @IBAction func selectedCityBtnClick(_ sender: UIButton) {
        self.viewClickType = .selectedCity
        // 显示动画
        self.isShowAlertView = false
        self.setAnimation(isShow: self.isShowAlertView)
    }
    
    
    // MARK: 天气按钮点击
    @IBAction func weatherBtnClick(_ sender: UIButton) {
        self.viewClickType = .weather
        // 显示动画
        if self.isShowAlertView {
            self.isShowAlertView = false
            self.setAnimation(isShow: self.isShowAlertView)
        }
        
    }
    
    // MARK: 刷新天气数据
    @IBAction func weatherRefleshBtnClick(_ sender: UIButton) {
        MBProgressHUD.showMessage("", to: self.view)
        self.getWeatherData()
    }
    
    // MARK: 不再显示按钮点击响应
    @IBAction func weatherTipBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UserDefaults.standard.set(sender.isSelected, forKey: WEATHER_IS_SHOW_AUTO_KEY)
        UserDefaults.standard.synchronize() // 同步数据
    }
    
    // MARK: 用户头像点击
    @IBAction func userIconBtnClick(_ sender: UIButton) {
        self.viewClickType = .userIcon
        // 显示动画
        self.isShowAlertView = false
        self.setAnimation(isShow: self.isShowAlertView)
    }
    
    
    // MARK: - AMapSearchDelegate 代理方法的实现
    // MARK: weather search done
    func onWeatherSearchDone(_ request: AMapWeatherSearchRequest!, response: AMapWeatherSearchResponse!) {
        
        if response.lives.count > 0 {
            let localWeatherLive = response.lives[0]
            myPrint(message: "\(localWeatherLive.windPower)")
            APP_DELEGATE.locationWeather = localWeatherLive
            // 获取PM2.5值
            self.getCurrentWeatherPm25Data()
            
            // 更新天气数据回调
            self.weatherDelegate?.weatherRefleshWeatherData!()
        }
    }
    
    // MARK: failed
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if (error != nil) {
            MBProgressHUD.hide(for: self.view, animated: true)
            MBProgressHUD.showBottom("获取天气数据出错", icon: nil, view: self.view)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 显示动画
        self.setAnimation(isShow: self.isShowAlertView)
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
    
    
    // MARK: 获取天气数据
    func getWeatherData() {
        // weather
        let weatherSearchRequest = AMapWeatherSearchRequest.init()
        weatherSearchRequest.city = APP_DELEGATE.currenctSelectedCity
        weatherSearchRequest.type = .live  // 实时天气
        self.mapSearch.aMapWeatherSearch(weatherSearchRequest)
    }
    
    
    // 获取当前位置的PM2.5
    func getCurrentWeatherPm25Data() {
        var paramters = ["longitude" : "\(UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))", "latitude": "\(UserDefaults.standard.double(forKey: LOCATION_LATITUDE))"]
        if APP_DELEGATE.currenctSelectedCity != APP_DELEGATE.locationAddress?.city {
            // 不是定位城市
            // 获取选择城市的信息（包含中心经纬度）
            let cityDict = AddressPickerDemo.getCityRelativeInfo(with: APP_DELEGATE.currenctSelectedCity)
            if cityDict != nil {
                paramters = ["longitude" : "\(cityDict!["longitude"] ?? DEFAULT_CITY_CENTER_LONGITUDE)", "latitude": "\(cityDict!["latitude"] ?? DEFAULT_CITY_CENTER_LATITUDE)"]
            } else {
                paramters = ["longitude" : DEFAULT_CITY_CENTER_LONGITUDE, "latitude": DEFAULT_CITY_CENTER_LATITUDE]
            }
        }
        
        WebDataResponseInterface.shareInstance.SessionManagerWebDataALLParamters(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_StationHourDataGetNearbyPm25, parameters: paramters as NSDictionary, resquestType: .POST, outRequestTime: 5, responseProgress: {_ in}, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if objectSuccess == nil {
                // 图片美化和PM2.5校正
                var pm25Value = UserDefaults.standard.integer(forKey: PHOTO_PM_25)
                if pm25Value < 5 {pm25Value = Int(NSString.randomString(with: "10"))!}
                self.setWeatherData(pm25: pm25Value)
            } else {
                var pm25Value = objectSuccess as! Int
                if pm25Value <= 5 { pm25Value = Int(NSString.randomString(with: "10"))!}
                self.setWeatherData(pm25: pm25Value)
                
            }
            MBProgressHUD.show("天气数据已更新", icon: nil, view: self.view)
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            myPrint(message: "error:\(error)")
            // 获取空气质量失败
            // 图片美化和PM2.5校正
            var pm25Value = UserDefaults.standard.integer(forKey: PHOTO_PM_25)
            if pm25Value < 5 {pm25Value = Int(NSString.randomString(with: "10"))!}
            self.setWeatherData(pm25: pm25Value)
            MBProgressHUD.show("天气数据已更新", icon: nil, view: self.view)
        }
    }
    
    // 动画
    func setAnimation(isShow: Bool) {
        let alertViewHeight: CGFloat = 236
        
        // 设置初始值
        if isShow {
            // 显示
            self.showAlertView.center = CGPoint(x: SCREEN_WIDTH/2 + 25, y: -20)
            self.showAlertView.isHidden = false
            self.showAlertView.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 1, animations: {
                self.showAlertView.center = CGPoint(x: SCREEN_WIDTH/2, y: alertViewHeight/2)
                self.showAlertView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }) { (isComplete) in
                self.rippleAnimationForLayer()
            }
        } else {
            // 隐藏
            self.showAlertView.center = CGPoint(x: SCREEN_WIDTH/2, y: alertViewHeight/2)
            self.showAlertView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            UIView.animate(withDuration: 1, animations: {
                self.showAlertView.center = CGPoint(x: SCREEN_WIDTH/2 + 25, y: -20)
                self.showAlertView.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            }) { (isComplete) in
                self.rippleAnimationForLayer()
            }
        }
    }
    
    // MARK: 水波动画
    func rippleAnimationForLayer() {
        print("动画执行完成")
        if !self.isShowAlertView {
            self.dismiss(animated: true, completion: {
                switch self.viewClickType {
                case .selectedCity:
                    self.weatherDelegate?.weatherViewSelectedCity!()
                case .weather:
                    myPrint(message: "do nothing")
                case .userIcon:
                    self.weatherDelegate?.weatherViewUserIcon!()
                case .backgroundView:
                    self.weatherDelegate?.weatherViewBackground!()
                }
            })
        } else {
            let animation3 = CATransition()
            animation3.type = CATransitionType(rawValue: "rippleEffect")
            animation3.fillMode = CAMediaTimingFillMode.forwards
            animation3.isRemovedOnCompletion = false
            animation3.duration = 0.5
            self.showAlertView.layer.add(animation3, forKey: "animation3")
        }
    }
    
    
    // MARK: 获取街道地址
    static func getStreetAddress(isAddDistrict: Bool) -> String {
        var streetStr = ""
        if APP_DELEGATE.locationAddress?.district != nil && isAddDistrict {
            streetStr = (APP_DELEGATE.locationAddress?.district)!
        }
        
        if APP_DELEGATE.locationAddress?.street != nil {
            streetStr += (APP_DELEGATE.locationAddress?.street)!
            if APP_DELEGATE.locationAddress?.number != nil {
                streetStr += (APP_DELEGATE.locationAddress?.number)!
            }
        } else {
            if APP_DELEGATE.locationAddress?.poiName != nil {
                streetStr += (APP_DELEGATE.locationAddress?.poiName)!
            } else {
                if APP_DELEGATE.locationAddress?.aoiName != nil {
                    streetStr += (APP_DELEGATE.locationAddress?.aoiName)!
                }
            }
        }
        
        return streetStr
    }
    
    
    // MARK: 根据Python抓取网络数据
    func getCityPm25WithPython(cityName: String) -> Int {
        return 1
    }

}
