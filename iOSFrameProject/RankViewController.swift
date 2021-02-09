//
//  RankViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/19.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class RankViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    fileprivate var locationCount = 0           // 重新定位次数
    
    
    var dataSource: [CityHourDataModel] = []
    
    fileprivate var isNormalOrder = true        // 是否是正序排序（PM2.5有小到大）
    
    @IBOutlet weak var rankOrderBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        let rightBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "rank_location_postion"), style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        // set tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init()
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "RankImageTableViewCell", bundle: nil), forCellReuseIdentifier: RNAK_IMAGE_CELL_ID)
        self.tableView.register(UINib.init(nibName: "RankTextTableViewCell", bundle: nil), forCellReuseIdentifier: RANK_TEXT_CELL_ID)
        
        
        // 设置刷新
        //  上拉刷新 type 1
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        switch type {
        case .meituan:
            header = MTRefreshHeaderAnimator.init(frame: CGRect.zero)
        case .wechat:
            header = WCRefreshHeaderAnimator.init(frame: CGRect.zero)
        default:
            header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
            break
        }
        
        let _ = self.tableView.es.addPullToRefresh(animator: header) { [weak self] in
            self?.refresh()
        }
        self.tableView.refreshIdentifier = String.init(describing: type)
        self.tableView.expiredTimeInterval = Double(REQUEST_TIMEOUT_VALUE)
        
        // set orderBtn
        //self.setOrderBtnShowStyle()
        // 获取网络数据
        self.getRankCitysInfoList()
    }
    
    // MARK: 设置排序显示  rank_smallToBig
    func setOrderBtnShowStyle() {
        if self.isNormalOrder {
            self.rankOrderBtn.setImage(#imageLiteral(resourceName: "rank_smallToBig"), for: .normal)
            // 有小到大
            self.dataSource.sort(by: { (cityHour1, cityHour2) -> Bool in
                if cityHour1.pm25! > cityHour2.pm25! {
                    return false
                } else if cityHour1.pm25! == cityHour2.pm25! {
                    let cityStrC1 = ChineseToPinyin.pinyin(fromChiniseString: cityHour1.cityName!)
                    let cityStrC2 = ChineseToPinyin.pinyin(fromChiniseString: cityHour2.cityName!)
                    if (cityStrC1?.compare(cityStrC2!))!.rawValue > 0 {
                        return false
                    }
                }
                return true
            })
        } else {
            self.rankOrderBtn.setImage(#imageLiteral(resourceName: "rank_bigToSmall"), for: .normal)
            // 有大到小
            self.dataSource.sort(by: { (cityHour1, cityHour2) -> Bool in
                if cityHour1.pm25! > cityHour2.pm25! {
                    return true
                } else if cityHour1.pm25! == cityHour2.pm25! {
                    let cityStrC1 = ChineseToPinyin.pinyin(fromChiniseString: cityHour1.cityName!)
                    let cityStrC2 = ChineseToPinyin.pinyin(fromChiniseString: cityHour2.cityName!)
                    if (cityStrC1?.compare(cityStrC2!))!.rawValue > 0 {
                        return true
                    }
                }
                return false
            })
        }
        
        self.tableView.reloadData()
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getRankCitysInfoList()
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: rightBarBtnItem Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        
        let cityInfo = AddressPickerDemo.getCityRelativeInfo(with: APP_DELEGATE.locationAddress?.city)
        if cityInfo != nil {
            let regionCode = cityInfo!["regionCode"] as! String
            for (index, item) in self.dataSource.enumerated() {
                if item.regionCode == regionCode {
                    // 当前城市空气质量
                    self.tableView.setContentOffset(CGPoint.init(x: 0, y: index * RANK_TEXT_Cell_HEIGHT), animated: true)
                }
            }
        } else {
            // 检测定位权限是否打开
            if CLLocationManager.authorizationStatus() == .denied {
                // 未开启定位权限
                let alertViewController = UIAlertController.init(title: "未开启定位权限", message: "为了获取更好的用户体验，请在（设置->隐私->定位服务->250你发布）开启定位权限", preferredStyle: .alert)
                alertViewController.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (alertAction) in
                    // 跳转到定位设置
                    UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
                }))
                
                self.present(alertViewController, animated: true, completion: nil)
            } else {
                // 重新开始定位
                if self.locationCount >= 3 {
                    MBProgressHUD.show("定位失败", icon: nil, view: self.view)
                    return
                }
                
                self.locationCount += 1
                MBProgressHUD.showMessage("", to: self.view)
                APP_DELEGATE.singleStartLocationOnce(locationSuccess: { (reGeocode, location) in
                    self.locationCount = 0
                    MBProgressHUD.hide(for: self.view, animated: true)
                    APP_DELEGATE.locationAddress = reGeocode
                    self.rightBarBtnItemClick(sender: UIBarButtonItem.init())
                    
                    MBProgressHUD.show("定位成功", icon: nil, view: self.view)
                }, locationFailed: { (error) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    MBProgressHUD.show("定位失败", icon: nil, view: self.view)
                })
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
        // 设置默认空内容显示
        if self.dataSource.count == 0 {
            let tableviewBGEmptyImageView = UIImageView.init(image: #imageLiteral(resourceName: "data_empty"))
            tableviewBGEmptyImageView.contentMode = .scaleAspectFit
            self.tableView.backgroundView = tableviewBGEmptyImageView
        } else {
            self.tableView.backgroundView = nil
        }
        
        return self.dataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 解析数据
        let citysHour = self.dataSource[indexPath.row]
        
//        if indexPath.row < 5 {
//            let cell = self.tableView.dequeueReusableCell(withIdentifier: RNAK_IMAGE_CELL_ID) as! RankImageTableViewCell
//            cell.selectionStyle = .none
//
//
//            // bg iamge
//            cell.showBgImageView.image = UIImage.init(named: "00\(indexPath.row % 3 + 1).png")
//
//            // order Index  and Pm2.5
//            cell.showOrderIndexLabel.text = String(indexPath.row + 1)
//            switch indexPath.row {
//            case 0:
//                cell.showOrderIndexLabel.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
//
//                cell.showPm25ValueLabel.text = "34"
//                cell.showPm25View.backgroundColor = colorPm25WithValue(pm25Value: 34)
//            case 1:
//                cell.showOrderIndexLabel.backgroundColor = UIColorFromRGB(rgbValue: 0x8f82bc)
//
//                cell.showPm25ValueLabel.text = "58"
//                cell.showPm25View.backgroundColor = colorPm25WithValue(pm25Value: 58)
//            case 2:
//                cell.showOrderIndexLabel.backgroundColor = UIColorFromRGB(rgbValue: 0x7ecef4)
//
//                cell.showPm25ValueLabel.text = "204"
//                cell.showPm25View.backgroundColor = colorPm25WithValue(pm25Value: 204)
//            default:
//                cell.showOrderIndexLabel.backgroundColor = UIColorFromRGB(rgbValue: 0xaaaaaa)
//
//                cell.showPm25ValueLabel.text = "900"
//                cell.showPm25View.backgroundColor = colorPm25WithValue(pm25Value: 900)
//            }
//
//            // address
//            cell.showAddressLabel.text = "西安市 钟楼"
//
//            return cell
//        }
        
        // text Cell
        let textCell = tableView.dequeueReusableCell(withIdentifier: RANK_TEXT_CELL_ID) as! RankTextTableViewCell
        
        // set style
        textCell.showTitleLabel.textColor = COLOR_LIGHT_GAY
        textCell.showPm25Label.textColor = COLOR_LIGHT_GAY
        if indexPath.row % 2 == 0 {
            textCell.backgroundColor = UIColor.white
        } else {
            textCell.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
        }
        
        // order and city 
        let textStyleCityDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SYSTEM_SIZE, minFont:FONT_SMART_SIZE, color: COLOR_DARK_GAY, action: {})
        let strTextCity = "\(indexPath.row + 1)       <help><link><FontMax>\(citysHour.cityName!)</FontMax></link></help>" as NSString?
        textCell.showTitleLabel.attributedText = strTextCity?.attributedString(withStyleBook: textStyleCityDict as! [AnyHashable : Any])
        if citysHour.cityName == APP_DELEGATE.locationAddress?.city {
            textCell.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
            textCell.showTitleLabel.textColor = UIColor.white
            textCell.showPm25Label.textColor = UIColor.white
        }
        
        
        // Pm2.5
        let pm25Color = colorPm25WithValue(pm25Value: citysHour.pm25!)
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: NAVIGATION_TITLE_FONT_SIZE, minFont:FONT_SMART_SIZE, color: pm25Color, action: {})    //citysHour.pm25!
        let strText = "PM2.5：<help><link><FontMax>\(String(describing: citysHour.pm25!))</FontMax></link></help>" as NSString?
        textCell.showPm25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        textCell.showColorBlockView.backgroundColor = pm25Color
        
        
        return textCell
    }
    
    // cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 解析数据
        let citysHour = self.dataSource[indexPath.row]
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SenceWallView") as! SenceWallViewController
        viewController.currentSelectedCity = citysHour.cityName
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row < 5 {
//            return CGFloat(RANK_IMAGE_CELL_HEIGHT)
//        }
        
        return CGFloat(RANK_TEXT_Cell_HEIGHT)
    }
    
    // MARK: section Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: section Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    // 排行榜顺序 逆序 切换
    @IBAction func rankOrderBtnClick(_ sender: UIButton) {
        self.isNormalOrder = !self.isNormalOrder
        self.setOrderBtnShowStyle()
    }
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    ///  **********  网络数据请求   **************** ///
    // MARK: 获取排行榜的列表数据
    func getRankCitysInfoList() {
        MBProgressHUD.showMessage("", to: self.view)
        OtherBusiness.shareIntance.responseWebGetRankList(responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.dataSource.removeAll()
            self.dataSource = resonseSuccess as! [CityHourDataModel]
            
            // 删除未能查到的数据
            var arrayTemp: [CityHourDataModel] = []
            for item in self.dataSource {
                let citysInfo = AddressPickerDemo.getCityRelativeInfo(withRegion: item.regionCode!)
                if citysInfo != nil {
                    item.cityName = citysInfo?["regionName"] as? String
                    arrayTemp.append(item)
                }
            }
            self.dataSource = arrayTemp
            
            // 重现排序
            self.setOrderBtnShowStyle()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }

    }

}
