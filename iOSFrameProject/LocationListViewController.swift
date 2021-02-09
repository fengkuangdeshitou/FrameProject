//
//  LocationListViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/10/23.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

@objc protocol LocationListViewDelegate {
    // 选中的字符串
    @objc optional func locationListViewSelectedStr(string: String)
}


class LocationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AMapSearchDelegate {

    var locaiton: CLLocation?
    
    
    fileprivate var dataSource:[AMapPOI] = []
    
    weak var delegate: LocationListViewDelegate?
    
    // 设置位置搜索POI
    fileprivate lazy var mapSearch: AMapSearchAPI = {
        let mapSearchTemp = AMapSearchAPI.init()
        
        mapSearchTemp?.delegate = self
        
        return mapSearchTemp!
    }()
    
    
    fileprivate lazy var tableView:UITableView = {
        let tableViewTemp = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableViewTemp.delegate = self
        tableViewTemp.dataSource = self
        tableViewTemp.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: NAVIGATION_AND_STATUS_HEIGHT, right: 0)
        tableViewTemp.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: NAVIGATION_AND_STATUS_HEIGHT, right: 0)
        
        return tableViewTemp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "选择拍摄位置"
        self.view.backgroundColor = UIColor.white
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 设置tableView
        self.view.addSubview(self.tableView)
        
        // 获取定位相关信息
        if self.locaiton != nil {
            self.startReverseGeocode(loction: self.locaiton!)
        }
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
        self.delegate?.locationListViewSelectedStr!(string: poiInfo.name)
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: section Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: section Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    // MARK: - AMapSearchDelegate 代理方法的实现
    // MARK: onPOISearchDone
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        if response.count == 0 {
            return
        }
        self.dataSource = response.pois
        self.tableView.reloadData()
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
