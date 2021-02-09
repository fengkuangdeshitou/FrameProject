//
//  DiscoverViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/20.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController, MAMapViewDelegate, UIGestureRecognizerDelegate, AddressPickerDemoDelegate {

    fileprivate var dataSource: [MAPointAnnotation] = []
    fileprivate var merchantsArray: [MerchantModel] = []
    
    fileprivate var currentSelectedCity = DEFAULT_LOCATIONFAILED_CITY

    fileprivate lazy var showLocationBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 80.0, height: 30.0)
        btn.setImage(#imageLiteral(resourceName: "home_location_icon"), for: .normal)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.setTitle(self.currentSelectedCity, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SYSTEM_SIZE)
        btn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        btn.addTarget({ (sender) in
            let addressViewController = AddressPickerDemo.init()
            let navVC = UINavigationController.init(rootViewController: addressViewController)
            addressViewController.addressDelegate = self
            self.present(navVC, animated: true, completion: nil)
        }, andEvent: UIControl.Event.touchUpInside)
        
        return btn
    }()
    
    fileprivate lazy var showSearchBtn: UIButton = {
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 200, height: 30.0)
        btn.backgroundColor = UIColor.white
        btn.setImage(UIImage.init(named: "discover_search"), for: .normal)
        btn.setTitleColor(COLOR_LIGHT_GAY, for: UIControl.State.normal)
        btn.setTitle("搜索商家", for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = btn.height / 2
        btn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SYSTEM_SIZE)
        
        btn.addTarget(self, action: #selector(searchMerchantBtnClick(sender:)), for: UIControl.Event.touchUpInside)
        
        return btn
    }()
    
    fileprivate lazy var mapView: MAMapView = {
        let map = MAMapView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - TOOL_BAR_HEIGHT))
        map.delegate = self
        map.showsUserLocation = true
        map.userTrackingMode = MAUserTrackingMode.follow
        
        // 添加 回到中心点的按钮
        let backLoctionCenterBtn = UIButton.init(type: UIButton.ButtonType.custom)
        backLoctionCenterBtn.setImage(UIImage.init(named: "discover_map_center"), for: UIControl.State.normal)
        backLoctionCenterBtn.frame = CGRect(x: map.width - CELL_NORMAL_HEIGHT - 15, y: map.height - CELL_NORMAL_HEIGHT - 15 - NAVIGATION_AND_STATUS_HEIGHT, width: CELL_NORMAL_HEIGHT, height: CELL_NORMAL_HEIGHT)
        map.addSubview(backLoctionCenterBtn)
        backLoctionCenterBtn.addTarget(self, action: #selector(backLoctionCenterBtnClick(sender:)), for: UIControl.Event.touchUpInside)
        
        return map
    }()
    
    fileprivate var merchantView: MerchantView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "发现"
        self.merchantView = MerchantView.shareInstance()
        if APP_DELEGATE.locationAddress?.city != nil {
            self.setLocationBtnShowText(cityName: (APP_DELEGATE.locationAddress?.city)!)
            self.currentSelectedCity = (APP_DELEGATE.locationAddress?.city)!
        }
        
        let leftBarBtnItem = UIBarButtonItem.init(customView: self.showLocationBtn)
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationItem.titleView = self.showSearchBtn
        
        // 添加地图
        self.view.addSubview(self.mapView)
        
        // 添加商家信息
        self.view.addSubview(self.merchantView!)
        self.merchantView?.isHidden = true
        self.merchantView?.isUserInteractionEnabled = true
        self.merchantView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(merchantViewGestureClick(gesture:))))
        self.merchantView?.goToPayBtn.addTarget(self, action: #selector(goToPayBtnClick(sneder:)), for: UIControl.Event.touchUpInside)
        
        // 获取商家列表信息
        var regionCode = DEFAULT_LOCATIONFAILED_CODE
        let cityInfo = AddressPickerDemo.getCityRelativeInfo(with: self.currentSelectedCity)
        if cityInfo != nil {
            regionCode = cityInfo!["regionCode"] as! String
        }
        self.getMerchantSearchList(regionCode: regionCode, merchantName: nil)
    }
    
    
    // MARK: backLoctionCenterBtnClick
    @objc func backLoctionCenterBtnClick(sender: UIButton) {
        if self.mapView.userLocation.location != nil {
            self.mapView.setCenter(self.mapView.userLocation.location.coordinate, animated: true)
        }
    }
    
    
    // MARK: 添加地图标注
    func getAnnotationArray(dataArray: [MerchantModel]){
        self.dataSource.removeAll()
        for merchant in dataArray {
            let pointAnnot = MAPointAnnotation.init()
            pointAnnot.coordinate = CLLocationCoordinate2D(latitude: merchant.latitude!, longitude: merchant.longitude!)
            pointAnnot.title = "title"
            pointAnnot.subtitle = merchant.id
            self.dataSource.append(pointAnnot)
        }
        self.mapView.addAnnotations(self.dataSource)
    }
    
    
    // MARK: - MAMapViewDelegate
    // MARK: annotation
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) && annotation.title == "title" {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.image = UIImage(named: "discover_merchant_nor")
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
//            annotationView!.centerOffset = CGPoint(0, -18);
            
            return annotationView!
        }
        
        return nil
    }
    
    // MARK: didSelect
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        if view.annotation.isKind(of: MAPointAnnotation.self) && view.annotation.title == "title" {
            view.image = UIImage(named: "discover_merchant_sel")
            
            for (i,merchant) in self.merchantsArray.enumerated() {
                if view.annotation.subtitle == merchant.id {
                    self.merchantView?.isHidden = false
                    self.merchantView?.tag = i
                    if self.mapView.userLocation.location != nil {
                        self.merchantView?.loadInitData(merchant: merchant, userLocation: self.mapView.userLocation.location.coordinate)
                    } else {
                        self.merchantView?.loadInitData(merchant: merchant, userLocation: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
                    }
                    
                }
            }
        }
        
    }
    
    // MARK:didDeselect
    func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!) {
        if view.annotation.isKind(of: MAPointAnnotation.self) && view.annotation.title == "title" {
            self.merchantView?.isHidden = true
            view.image = UIImage(named: "discover_merchant_nor")
        }
    }
    
    
    // MARK: - AddressPickerDemoDelegate
    // MARK: didSelectedCity
    func addressPickerDemo(_ addressDemo: AddressPickerDemo!, didSelectedCity city: String!) {
        myPrint(message: "\(city)")
        var newCity = city
        if !city.hasSuffix("市") && !city.hasSuffix("地区") && !city.hasSuffix("自治州") {
            newCity = city + "市"
        }
        
        self.currentSelectedCity = newCity!
        self.setLocationBtnShowText(cityName: newCity!)
        var regionCode = DEFAULT_LOCATIONFAILED_CODE
        let cityInfo = AddressPickerDemo.getCityRelativeInfo(with: newCity)
        if cityInfo != nil {
            regionCode = cityInfo!["regionCode"] as! String
        }
        
        // 切换地图显示区域
        self.mapView.zoomLevel = 10
        self.mapView.setCenter(CLLocationCoordinate2D(latitude: cityInfo!["latitude"] as! CLLocationDegrees, longitude: cityInfo!["longitude"] as! CLLocationDegrees), animated: true)
        
        // 刷新该城市下的商家数据
        self.getMerchantSearchList(regionCode: regionCode, merchantName: nil)
    }
    
    
    // MARK: 设置定位按钮显示
    func setLocationBtnShowText(cityName: String) {
        
        if cityName == APP_DELEGATE.locationAddress?.city {
            // 所选为定位城市
            self.showLocationBtn.setImage(#imageLiteral(resourceName: "home_location_icon"), for: .normal)
            self.showLocationBtn.setTitle(cityName, for: .normal)
        } else {
            self.showLocationBtn.setImage(nil, for: .normal)
            self.showLocationBtn.setTitle(cityName, for: .normal)
        }
    }
    
    
    // MARK: 搜索商家跳转
    @objc func searchMerchantBtnClick(sender: UIButton) {
       if self.mapView.userLocation.location != nil {
            // 保存当前的经纬度， 地址字符串
            let coordinate = self.mapView.userLocation.location.coordinate
        UserDefaults.standard.set(coordinate.latitude, forKey: LOCATION_LATITUDE)
            UserDefaults.standard.set(coordinate.longitude, forKey: LOCATION_LONGTITUDE)
            UserDefaults.standard.synchronize()  // 同步数据
        }
        
        let viewController = MerchantSearchViewController.init(nibName: "MerchantSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: 商家cell点击
    @objc func merchantViewGestureClick(gesture: UIGestureRecognizer) {
        // 判断是否登录
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        myPrint(message: "进入商家详情")
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MerchantDetialView") as! MerchantDetialViewController
        viewController.merchant = self.merchantsArray[(gesture.view?.tag)!]
        if self.mapView.userLocation.location != nil {
            viewController.userLocation = self.mapView.userLocation.location.coordinate
            
            // 保存当前的经纬度， 地址字符串
            UserDefaults.standard.set(viewController.userLocation?.latitude, forKey: LOCATION_LATITUDE)
            UserDefaults.standard.set(viewController.userLocation?.longitude, forKey: LOCATION_LONGTITUDE)
            UserDefaults.standard.synchronize()  // 同步数据
        } else {
            viewController.userLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: 去支付点击
    @objc func goToPayBtnClick(sneder: UIButton) {
        // 判断是否登录
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        myPrint(message: "去支付")
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PayView") as! PayViewController
        viewController.merchant = self.merchantsArray[(self.merchantView?.tag)!]
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        // 设置导航栏
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
    }
    
    
    // MARK: view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: view did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    // MARK: - UIGestureRecognizerDelegate 代理方法的实现
    // MARK:
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    ///  **********  网络数据请求   **************** ///
    // MARK: 获取商家列表数据
    func getMerchantSearchList(regionCode: String?, merchantName: String?) {
        MBProgressHUD.showMessage("", to: self.view)
        MerchantBusiness.shareIntance.responseWebGetMerchantSearchList(regionCode: regionCode, name: merchantName, responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // 删除地图中现有的标注
            self.mapView.removeAnnotations(self.dataSource)
            self.merchantsArray = resonseSuccess as! [MerchantModel]
            
            self.getAnnotationArray(dataArray: self.merchantsArray)
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

}
