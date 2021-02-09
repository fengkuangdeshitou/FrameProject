//
//  SelectMerchantAddressViewControler.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/7/3.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

@objc protocol SelectMerchantAddressViewDelegate {
    // 选中的字符串
    @objc optional func selectMerchantAddressViewSelectedStr(string: String)
}

class SelectMerchantAddressViewControler: UIViewController, UITableViewDelegate, UITableViewDataSource, MAMapViewDelegate, AMapSearchDelegate, AddressPickerDemoDelegate {
    
    fileprivate let mapNormalZoomLevel: CGFloat = 16.0  // 合理的地址缩放大小
    fileprivate let mapCoordinateGap = 0.0029           // 定位点于屏幕上中心点的差值

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var currentLocationView: UIView!
    
    @IBOutlet weak var currentLocalAddressBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    
    fileprivate lazy var mapView: MAMapView = {
        let map = MAMapView.init(frame: self.view.bounds)
        map.delegate = self
        map.showsUserLocation = false
        map.userTrackingMode = MAUserTrackingMode.follow
        map.isRotateEnabled = false
        map.isShowsBuildings = false
        map.isSkyModelEnabled = false
        map.isRotateCameraEnabled = false
        map.isShowsIndoorMapControl = false
        map.showsScale = false
        map.showsCompass = false
        
        // 添加 回到中心点的按钮
        let backLoctionCenterBtn = UIButton.init(type: UIButton.ButtonType.custom)
        backLoctionCenterBtn.setImage(UIImage.init(named: "discover_map_center"), for: UIControl.State.normal)
        backLoctionCenterBtn.frame = CGRect(x: map.width - CELL_NORMAL_HEIGHT - 15, y: map.height - CELL_NORMAL_HEIGHT - 15 - NAVIGATION_AND_STATUS_HEIGHT - 250-8-8-60, width: CELL_NORMAL_HEIGHT, height: CELL_NORMAL_HEIGHT)
        map.addSubview(backLoctionCenterBtn)
        backLoctionCenterBtn.addTarget(self, action: #selector(backLoctionCenterBtnClick(sender:)), for: UIControl.Event.touchUpInside)
        
        return map
    }()
    
    
    fileprivate var dataSource:[AMapPOI] = []
    
    weak var customDelegate: SelectMerchantAddressViewDelegate?
    
    // 设置位置搜索POI
    fileprivate lazy var mapSearch: AMapSearchAPI = {
        let mapSearchTemp = AMapSearchAPI.init()
        
        mapSearchTemp?.delegate = self
        
        return mapSearchTemp!
    }()
    
    
    // Select city btn
    fileprivate lazy var selectCityBtn: UIButton = {
        let temp = UIButton.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 150, height: 30))
        
        temp.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SYSTEM_SIZE)
        temp.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        temp.addTarget({ (sender) in
            let addressViewController = AddressPickerDemo.init()
            let navVC = UINavigationController.init(rootViewController: addressViewController)
            addressViewController.addressDelegate = self
            self.present(navVC, animated: true, completion: nil)
        }, andEvent: UIControl.Event.touchUpInside)
        
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.setViewUI()
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        let rightBarBtnItem = UIBarButtonItem.init(title: "确定", style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationItem.titleView = self.selectCityBtn
        if APP_DELEGATE.locationAddress != nil {
            self.setLocationBtnShowText(cityName: (APP_DELEGATE.locationAddress?.city)!)
        } else {
            self.setLocationBtnShowText(cityName: DEFAULT_LOCATIONFAILED_CITY)
        }
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        
        // 添加地图
        self.view.addSubview(self.mapView)
        self.view.bringSubviewToFront(self.currentLocationView)
        self.addMapAnnotation()
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init()
        self.tableView.separatorColor = COLOR_SEPARATOR_LINE
        self.view.bringSubviewToFront(self.bottomView)
        
        // 获取定位的经纬度
        let location = CLLocation.init(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
        self.startReverseGeocode(loction: location)
        
        // 设置当前选择地址
        if APP_DELEGATE.locationAddress != nil {
            self.currentLocalAddressBtn.setTitle(APP_DELEGATE.locationAddress?.formattedAddress, for: UIControl.State.normal)
        }
        
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        
        // 设置当前定位
        if self.dataSource.count > 0 {
            let poiInfo = self.dataSource[0]
            let formatterAddress = "\(poiInfo.province!)\(poiInfo.city!)\(poiInfo.district!)\(poiInfo.address!)"
            self.customDelegate?.selectMerchantAddressViewSelectedStr!(string: formatterAddress)
        }
    }
    
    
    // MARK: 添加地图标注
    func addMapAnnotation(){
        let pointAnnot = MAPointAnnotation.init()
        pointAnnot.coordinate = CLLocationCoordinate2D.init(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
        pointAnnot.title = "title"
        let pointY: CGFloat = (SCREEN_HEIGHT - self.tableView.height - self.currentLocationView.height - 8 * 2) / 2.0 - 30
        pointAnnot.lockedScreenPoint = CGPoint(x: SCREEN_WIDTH/2, y: pointY)
        pointAnnot.isLockedToScreen = true
        self.mapView.addAnnotation(pointAnnot)
        //self.mapView.showAnnotations([pointAnnot], animated: true)
    }
    
    
    // MARK: - UITableView 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 解析数据
        let poiInfo = self.dataSource[indexPath.row]
        
        // text Cell
        var textCell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if textCell == nil {
            textCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
            textCell?.detailTextLabel?.textColor = COLOR_LIGHT_GAY
            textCell?.textLabel?.textColor = COLOR_DARK_GAY
        }
        
        textCell?.textLabel?.text = poiInfo.name
        
        textCell?.detailTextLabel?.text = poiInfo.address
        
        return textCell!
    }
    
    // cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        // 解析数据
        let poiInfo = self.dataSource[indexPath.row]
        
        // 跳转
        self.navigationController?.popViewController(animated: true)
        let formatterAddress = "\(poiInfo.province!)\(poiInfo.city!)\(poiInfo.district!)\(poiInfo.address!)"
        self.customDelegate?.selectMerchantAddressViewSelectedStr!(string: formatterAddress)
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: section Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    // MARK: section Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    
    // MARK: backLoctionCenterBtnClick
    @objc func backLoctionCenterBtnClick(sender: UIButton) {
        mapView.setZoomLevel(mapNormalZoomLevel, animated: true)
        if self.mapView.userLocation.location != nil {
            let location = CLLocationCoordinate2D.init(latitude: self.mapView.userLocation.location.coordinate.latitude - mapCoordinateGap, longitude: self.mapView.userLocation.location.coordinate.longitude)
            self.mapView.setCenter(location, animated: true)
        }
        
        // 重新请求周围地址列表
        let location = self.getAnnoPointLocation()
        if location != nil {
            // 重新定位附近的位置
            self.startReverseGeocode(loction: location!)
        }
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
            
            annotationView!.image = UIImage(named: "select_merchant_point")
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            //            annotationView!.centerOffset = CGPoint(0, -18);
            
            return annotationView!
        }
        
        return nil
    }
    
    
    // MARK: mapDidMoveByUser
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if !wasUserAction {
            return
        }
        
        let location = self.getAnnoPointLocation()
        if location != nil {
            // 重新定位附近的位置
            self.startReverseGeocode(loction: location!)
        }
        
    }
    
    
    // MARK:  MAP缩放完之后回调
    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        if !wasUserAction {
            return
        }
        
        let location = self.getAnnoPointLocation()
        if location != nil {
            // 重新定位附近的位置
            self.startReverseGeocode(loction: location!)
        }
    }
    
    // MARK: mapInitComplete
    func mapInitComplete(_ mapView: MAMapView!) {
        mapView.showsUserLocation = true
        mapView.setZoomLevel(mapNormalZoomLevel, animated: false)
        if self.mapView.userLocation.location != nil {
            // 重新定位附近的位置
            self.startReverseGeocode(loction: self.mapView.userLocation.location)
            let location = CLLocationCoordinate2D.init(latitude: self.mapView.userLocation.location.coordinate.latitude - mapCoordinateGap, longitude: self.mapView.userLocation.location.coordinate.longitude)
            self.mapView.setCenter(location, animated: true)
        }
    }
    
    
    // MARK: - AMapSearchDelegate 代理方法的实现
    // MARK: onPOISearchDone
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        if response.count == 0 {
            return
        }
        self.dataSource = response.pois
        
        // 设置当前定位
        if response.pois.count > 0 {
            let currentFirstPois = response.pois[0]
            myPrint(message: currentFirstPois.mj_keyValues())
            if currentFirstPois.name.count > 0 {
                self.currentLocalAddressBtn.setTitle(currentFirstPois.name, for: .normal)
            } else {
                self.currentLocalAddressBtn.setTitle(currentFirstPois.address, for: .normal)
            }
        }
        self.tableView.scrollsToTop = true
        self.tableView.reloadData()
        
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    
    // MARK:
    
    
    // MARK: - AddressPickerDemoDelegate
    // MARK: 选中城市响应方法
    func addressPickerDemo(_ addressDemo: AddressPickerDemo!, didSelectedCity city: String!) {
        myPrint(message: "\(city)")
        var newCity = city
        if !city.hasSuffix("市") && !city.hasSuffix("地区") && !city.hasSuffix("自治州") {
            newCity = city + "市"
        }
        
        self.setLocationBtnShowText(cityName: newCity! )
        //addressDemo.dismiss(animated: true, completion: nil)
        
        
        let cityInfo = AddressPickerDemo.getCityRelativeInfo(with: newCity)
        
        // 切换地图显示区域
        self.mapView.zoomLevel = mapNormalZoomLevel
        let location = CLLocation.init(latitude: cityInfo!["latitude"] as! CLLocationDegrees, longitude: cityInfo!["longitude"] as! CLLocationDegrees)
        self.mapView.setCenter(location.coordinate, animated: true)
        
        // 重新定位附近的位置
        self.startReverseGeocode(loction: location)
    }
    
    
    
    // MARK: 获取标注的位置坐标
    func getAnnoPointLocation() -> CLLocation? {
        var annPoint: MAPointAnnotation?
        for anno in self.mapView.annotations {
            if (anno as AnyObject).isKind(of: MAPointAnnotation.self) && (anno as AnyObject).title == "title" {
                annPoint  =  anno as? MAPointAnnotation
            }
        }
        
        if annPoint != nil {
            let location = CLLocation.init(latitude: (annPoint?.coordinate.latitude)!, longitude: (annPoint?.coordinate.longitude)!)
            return location
        }
        
        return nil
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
    
    
    // MARK: 开始位置搜索
    func startReverseGeocode(loction: CLLocation) {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(loction.coordinate.latitude), longitude: CGFloat(loction.coordinate.longitude))
        request.keywords = ""
        request.requireExtension = true
        
        self.mapSearch.aMapPOIAroundSearch(request)
    }

}


// 类扩展
extension SelectMerchantAddressViewControler {
    func setViewUI() {
        // 设置圆角和阴影
//        self.currentLocationView.layer.masksToBounds = true
        self.currentLocationView.layer.cornerRadius = CORNER_NORMAL
        self.currentLocationView.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.currentLocationView.layer.shadowOpacity = 0.6;
        self.currentLocationView.layer.shadowColor = UIColor.black.cgColor
        
        self.currentLocalAddressBtn.setImage(#imageLiteral(resourceName: "edit_location_address"), for: .normal)
        self.currentLocalAddressBtn.titleLabel?.numberOfLines = 0
        
        self.tableView.layer.masksToBounds = true
        self.tableView.layer.cornerRadius = CORNER_NORMAL
        self.bottomView.layer.cornerRadius = CORNER_NORMAL
        self.bottomView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.bottomView.layer.shadowOpacity = 0.6;
        self.bottomView.layer.shadowColor = UIColor.black.cgColor
        
    }
    
    
    func selectCityBtnClick(sender: UIButton) {
        let addressViewController = AddressPickerDemo.init()
        let navVC = UINavigationController.init(rootViewController: addressViewController)
        addressViewController.addressDelegate = self
        self.present(navVC, animated: true, completion: nil)
    }
    
    
    // MARK: 设置定位按钮显示
    func setLocationBtnShowText(cityName: String) {
        if cityName == APP_DELEGATE.locationAddress?.city {
            // 所选为定位城市
            self.selectCityBtn.setImage(#imageLiteral(resourceName: "home_location_icon"), for: .normal)
            self.selectCityBtn.setTitle(cityName, for: .normal)
        } else {
            self.selectCityBtn.setImage(nil, for: .normal)
            self.selectCityBtn.setTitle(cityName, for: .normal)
        }
    }
}
