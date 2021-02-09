//
//  SenceWallViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/19.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class SenceWallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LMSTakePhotoControllerDelegate, AddressPickerDemoDelegate, STSegmentViewDelegate, EditPhotoViewDelegate {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    var segmentView: STSegmentView?
    var currentSelectedCity: String?                              // 当前选中城市
    fileprivate var currentPhotoTypeIndex = 0                     // 当前图片类型索引
    
    fileprivate var dataSource: [PhotoModel] = []

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showSelectedView: UIView!
    
    @IBOutlet weak var showCurrentTimeLabel: UILabel!
    
    @IBOutlet weak var takePhotoBtn: UIButton!
    
    
    @IBOutlet weak var showLocationBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "实景墙"
        if SCREEN_WIDTH < 375.0 {
            self.showLocationBtn.width = 100.0
        }
        
        // 设置定位城市
        if self.currentSelectedCity == nil {
            self.currentSelectedCity =  DEFAULT_LOCATIONFAILED_CITY
        }
        self.setLocationBtnShowText(cityName: self.currentSelectedCity!)
        self.showLocationBtn.addTarget(self, action: #selector(rightBarBtnItemClick(sender:)), for: .touchUpInside)
        
        
        // segmentView
        let segmentWidth: CGFloat = CGFloat(PHOTO_CODE_ARRAY.count * 70)//65
        self.segmentView = STSegmentView.init(frame: CGRect(x: 10, y: 1, width: segmentWidth - 10, height: HOME_HEADER_HEIGHT-1))
        
        // 获取 photo code title
        var titleArray: [String] = ["全部"]
        for dataDict in PHOTO_CODE_ARRAY {
            titleArray.append(dataDict["title"]!)
        }
        self.segmentView?.titleArray = titleArray;
        self.segmentView?.titleSpacing = 5;
        self.segmentView?.labelFont = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE);
        self.segmentView?.bottomLabelTextColor = COLOR_GAY;
        self.segmentView?.topLabelTextColor = COLOR_HIGHT_LIGHT_SYSTEM;
        self.segmentView?.selectedBackgroundColor = UIColor.white;
        self.segmentView?.selectedBgViewCornerRadius = 20;
        self.segmentView?.sliderHeight = 5;
        self.segmentView?.sliderColor = COLOR_HIGHT_LIGHT_SYSTEM;
        self.segmentView?.sliderTopMargin = 5;
        self.segmentView?.backgroundColor = UIColor.white
        self.segmentView?.duration = 0.3;
        self.segmentView?.delegate = self
        
        let scrollView = UIScrollView.init(frame: self.showSelectedView.bounds)
        scrollView.width = SCREEN_WIDTH - self.showCurrentTimeLabel.width - 10
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(self.segmentView!)
        scrollView.contentSize = CGSize(width: segmentWidth, height: 20.0)
        self.showSelectedView.addSubview(scrollView)
        
        // 设置导航栏 #imageLiteral(resourceName: "nav_back")
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // set tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init()
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: HOME_CELL_ID)
        
        // 设置刷新
        //  上拉刷新 type 1
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        var footer: ESRefreshProtocol & ESRefreshAnimatorProtocol
        switch type {
        case .meituan:
            header = MTRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = MTRefreshFooterAnimator.init(frame: CGRect.zero)
        case .wechat:
            header = WCRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        default:
            header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
            break
        }
        
        let _ = self.tableView.es.addPullToRefresh(animator: header) { [weak self] in
            self?.refresh()
        }
        let _ = self.tableView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            self?.loadMore()
        }
        self.tableView.refreshIdentifier = String.init(describing: type)
        self.tableView.expiredTimeInterval = Double(REQUEST_TIMEOUT_VALUE)
        
        // 获取网络数据
        self.getSenceListData(selectedCity: self.currentSelectedCity!, buttonIndex: self.currentPhotoTypeIndex, pageCount: self.page)
        
        // 接收图片信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptPhotoInfoUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_PhotoInfo), object: nil)
    }
    
    // MARK: 图片信息更新消息通知响应
    @objc func acceptPhotoInfoUpdateNotification(notification: Notification) {
        let photoInfo = notification.object as? PhotoModel
        
        if photoInfo == nil {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.refresh()
            })
        } else {
            for item in self.dataSource {
                if item.id == photoInfo?.id {
                    item.description = photoInfo?.description
                    item.dehazePhoto = photoInfo?.dehazePhoto
                    item.thumbPhoto = photoInfo?.thumbPhoto
                    item.likeCount = photoInfo?.likeCount
                    item.isLike = photoInfo?.isLike
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getSenceListData(selectedCity: self.currentSelectedCity!, buttonIndex: self.currentPhotoTypeIndex, pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getSenceListData(selectedCity: self.currentSelectedCity!, buttonIndex: self.currentPhotoTypeIndex, pageCount: self.page)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: rightBarBtnItem Click
    @objc func rightBarBtnItemClick(sender: UIButton) {
        let addressViewController = AddressPickerDemo.init()
        let navVC = UINavigationController.init(rootViewController: addressViewController)
        addressViewController.addressDelegate = self
        addressViewController.isShowAll = true
        self.present(navVC, animated: true, completion: nil)
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
        
        if self.dataSource.count % 2 == 0 {
            return self.dataSource.count / 2
        }
        
        return self.dataSource.count / 2 + 1
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: HOME_CELL_ID) as! HomeTableViewCell
        cell.selectionStyle = .none
        
        // 重新计算索引
        let rightIndex = indexPath.row * 2 + 1
        let leftIndex = indexPath.row * 2
        
        // left View
        let leftSence = self.dataSource[leftIndex]
        // image
        cell.leftImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + leftSence.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
        // PM2.5    字体样式
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SMART_SIZE, minFont: 9.0, color: colorPm25WithValue(pm25Value: leftSence.pm25!), action: {})
        let strText = "PM2.5：<help><link><FontMax>\(String(describing: leftSence.pm25!))</FontMax></link></help>" as NSString?
        cell.leftPM25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        
        // 设置响应事件
        cell.leftCellView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(customCellClick(gesture:)))
        gesture.accessibilityValue = String(leftIndex)
        cell.leftCellView.addGestureRecognizer(gesture)
        
        // Address
        cell.leftAddressLabel.text = AddressPickerDemo.getReadCityAddress(withAddressStr: leftSence.address, andCurrentCity: self.currentSelectedCity)
        // support
        cell.leftSupportBtn.setTitle(String(describing: leftSence.likeCount!), for: .normal)
        
        if rightIndex > self.dataSource.count - 1 {
            // 没有右边的 cell
            cell.rightCellView.isHidden = true
        } else {
            cell.rightCellView.isHidden = false
            // right View
            let rightSence = self.dataSource[rightIndex]
            // image
            cell.rightImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + rightSence.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
            // PM2.5
            let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SMART_SIZE, minFont: 9.0, color: colorPm25WithValue(pm25Value: rightSence.pm25!), action: {})
            let strText = "PM2.5：<help><link><FontMax>\(String(describing: rightSence.pm25!))</FontMax></link></help>" as NSString?
            cell.rightPM25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
            // Address
            cell.rightAddressLabel.text = AddressPickerDemo.getReadCityAddress(withAddressStr: rightSence.address, andCurrentCity: self.currentSelectedCity)
            // support
            cell.rightSupportBtn.setTitle(String(describing: rightSence.likeCount!), for: .normal)
            
            // 设置响应事件
            cell.rightCellView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(customCellClick(gesture:)))
            gesture.accessibilityValue = String(rightIndex)
            cell.rightCellView.addGestureRecognizer(gesture)
        }
        
        return cell
    }
    
    // MARK: custom cell Click
    @objc func customCellClick(gesture: UIGestureRecognizer) {
        let cellIndex = Int(gesture.accessibilityValue!)
        let senceData = self.dataSource[cellIndex!]
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ShowPhotoView") as! ShowPhotoViewController
        viewController.senceData = senceData
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HOME_CELL_HEIGHT
    }
    
    // MARK: scroll did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 获取顶部left 数据源的索引
        let index = Int(scrollView.contentOffset.y / HOME_CELL_HEIGHT) * 2
        
        if index < self.dataSource.count  {
            let senceData = self.dataSource[index]
            
            // 显示时间
            let takeDate = Date.init(timeIntervalSince1970: senceData.takeTime! / 1000)
            let timeArray = NSDate.getDateYearMonthDay(with: takeDate)
//            let timeArray = tools.getDateYearMonthDay(with: takeDate)
            
            self.showCurrentTimeLabel.text = "\(timeArray![0])年\n\(timeArray![1])月\(timeArray![2])日"
        }
    }
    
    
    // MARK: - LMSTakePhotoControllerDelegate 代理方法的实现
    // MARK: 拍摄成功返回拍摄图片
    func didFinishPickingImage(_ pickerImageView: LMSTakePhotoController!, take previewImage: UIImage!) {
        pickerImageView.dismiss(animated: true) {
            // 跳转到图片编辑界面
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "EditPhotoView") as! EditPhotoViewController
            viewController.originImage = previewImage
            viewController.editPhotoDelegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    // MARK: - AddressPickerDemoDelegate
    // MARK: 选中城市响应方法
    func addressPickerDemo(_ addressDemo: AddressPickerDemo!, didSelectedCity city: String!) {
        myPrint(message: "\(city)")
        
        var newCity = city
        if city != "全部" {
            if !city.hasSuffix("市") && !city.hasSuffix("地区") && !city.hasSuffix("自治州") {
                newCity = city + "市"
            }
        }
        
        self.currentSelectedCity = newCity
        self.setLocationBtnShowText(cityName: newCity!)
        addressDemo.dismiss(animated: true, completion: nil)
        
        // 刷新网络数据
        self.page = 1
        self.getSenceListData(selectedCity: self.currentSelectedCity!, buttonIndex: self.currentPhotoTypeIndex, pageCount: self.page)
        
    }
    
    
    // MARK: -  STSegmentViewDelegate 代理方法的实现
    // MARK: Button 点击索引
    func buttonClick(_ index: Int) {
        myPrint(message: "buttonIndex = \(index)")
        self.currentPhotoTypeIndex = index
        
        self.page = 1
        // 获取网络数据
        self.getSenceListData(selectedCity: self.currentSelectedCity!, buttonIndex: self.currentPhotoTypeIndex, pageCount: self.page)
    }
    
    
    // MARK: - EditPhotoViewDelegate
    // MARK: 图片上传成功的回调
    func editPhotoViewPublishImagesSuccess() {
        // 获取网络数据
        self.getSenceListData(selectedCity: self.currentSelectedCity!, buttonIndex: self.currentPhotoTypeIndex, pageCount: self.page)
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
    
    
    // MARK: 拍照按钮响应
    @IBAction func takePhotoBtnClick(_ sender: UIButton) {
        // 判断用户是否登录
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: "请先登录", isShowCancal: nil)
            return
        }
        // 判断是否是临时用户
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        
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
        
        //注释以下两行其中一行可以切换前置或者后置摄像头
        takePhotoVC.position = .back;
        //p.position = TakePhotoPositionFront;
        
        //注释以下两行其中一行可以实现身份证正面照拍摄或者背面照拍摄
        //    p.functionType = TakePhotoIDCardFrontType;
        //    p.functionType = TakePhotoIDCardBackType;
        
        takePhotoVC.delegate = self;
        takePhotoVC.allowPreview = false
        
        let navigationVC = UINavigationController.init(rootViewController: takePhotoVC)
        MBProgressHUD.showMessage("", to: self.view)
        self.present(navigationVC, animated: true) {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
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
    // MARK: 获取实景列表数据
    func getSenceListData(selectedCity: String, buttonIndex: Int, pageCount: Int) {
        var regionCode = DEFAULT_LOCATIONFAILED_CODE
        var photoTypCode = ""
        
        // regionCode
        if selectedCity == "全部" {
            regionCode = ""
        } else {
            let cityInfo = AddressPickerDemo.getCityRelativeInfo(with: selectedCity)
            if cityInfo != nil {
                regionCode = cityInfo!["regionCode"] as! String
            }
        }
        
        // photoTypCode
        var minPm25 = 0, maxPm25 = 0
        if buttonIndex != 0 {
            // 其他类型
            let dataDict = PHOTO_CODE_ARRAY[buttonIndex - 1]
            photoTypCode = dataDict["code"]!
            switch photoTypCode {
            case "001":
                minPm25 = 0
                maxPm25 = 49
                break
            case "002":
                minPm25 = 50
                maxPm25 = 99
                break
            case "003":
                minPm25 = 100
                maxPm25 = 199
                break
            case "004":
                minPm25 = 200
                maxPm25 = 499
                break
            case "005":
                minPm25 = 500
                maxPm25 = 2999
                break
            default: break
            }
        }
        
        MBProgressHUD.showMessage("", to: self.view)
        PhotoBusiness.shareIntance.responseWebGetSenceList(pageIndex: pageCount, photoTypCode: "", regionCode: regionCode, minPm25: minPm25, maxPm25: maxPm25, responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = resonseSuccess as! PageResultModel<PhotoModel>
            if pageCount == 1 {
                self.dataSource.removeAll()
                
                self.dataSource = pageResult.beanList!
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
                
                // 显示时间
                if self.dataSource.count > 0 {
                    let senceOneData = self.dataSource[0]
                    let takeDate = Date.init(timeIntervalSince1970: senceOneData.takeTime! / 1000)
                    let timeArray = NSDate.getDateYearMonthDay(with: takeDate)
                    //                    let timeArray = tools.getDateYearMonthDay(with: takeDate)
                    self.showCurrentTimeLabel.text = "\(timeArray![0])年\n\(timeArray![1])月\(timeArray![2])日"
                }
            } else {
                self.dataSource = self.dataSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.pageCode == pageResult.totalPage {
                self.tableView?.es.noticeNoMoreData()
            }
            myPrint(message: resonseSuccess)
            
            // 刷新数据
            self.tableView?.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }

}
