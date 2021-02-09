//
//  MineSupportPhotoViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/27.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class MineSupportPhotoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1

    fileprivate var dataSource: [PhotoModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "我点赞的照片"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // set tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(UINib.init(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: HOME_CELL_ID)
        self.tableView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        
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
        self.getMineAttentionImagesListData(pageCount: self.page)
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getMineAttentionImagesListData(pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getMineAttentionImagesListData(pageCount: self.page)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
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
        cell.leftAddressLabel.text = leftSence.address
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
            cell.rightImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE +  rightSence.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
            // PM2.5
            let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SMART_SIZE, minFont: 9.0, color: colorPm25WithValue(pm25Value: rightSence.pm25!), action: {})
            let strText = "PM2.5：<help><link><FontMax>\(String(describing: rightSence.pm25!))</FontMax></link></help>" as NSString?
            cell.rightPM25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
            // Address
            cell.rightAddressLabel.text = rightSence.address
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    ///  **********  网络数据请求   **************** ///
    // MARK: 获取我关注的图片列表
    func getMineAttentionImagesListData(pageCount: Int) {
        MBProgressHUD.showMessage("", to: self.view)
        PhotoBusiness.shareIntance.responseWebGetMineSupportSenceList(pageIndex: pageCount, responseSuccess: { (resonseSuccess) in
             MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = resonseSuccess as! PageResultModel<PhotoModel>
            if pageCount == 1 {
                self.dataSource.removeAll()
                
                self.dataSource = pageResult.beanList!
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
            } else {
                self.dataSource = self.dataSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.beanList?.count == 0 {
                self.page -= 1
                if self.page < 1 { self.page = 1 }
                self.tableView.es.noticeNoMoreData()
            }
            if self.page == pageResult.totalPage {
                self.tableView.es.noticeNoMoreData()
            }
            // 刷新
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
