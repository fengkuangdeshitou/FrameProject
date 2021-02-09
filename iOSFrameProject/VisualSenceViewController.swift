//
//  VisualSenceViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/20.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class VisualSenceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    @IBOutlet var tableView: UITableView!
    
    fileprivate var dataSource: [SenceStoryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "视觉"
        
        tableView.tableFooterView = UIView.init()
    ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.tableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: self.refresh, moreData: self.loadMore)
        
        // 获取网络数据
        self.getWebResponseSuccessList(pageIndex: 1)
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getWebResponseSuccessList(pageIndex: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getWebResponseSuccessList(pageIndex: self.page)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        // 设置导航栏
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : COLOR_DARK_GAY]
        self.navigationController?.navigationBar.tintColor = COLOR_DARK_GAY
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    func tableView(_ e: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200  // 200, 310
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let initIdentifier = "Cell"
        let cell: VisualSenceTableCell = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as! VisualSenceTableCell
        
        cell.titleLable.isUserInteractionEnabled = false
        cell.moreButton.isUserInteractionEnabled = false
        
        cell.picD.isHidden = true
        cell.picE.isHidden = true
        cell.picF.isHidden = true
        
        // 解析数据
        let senceStory = self.dataSource[indexPath.row]
        
        var showTitle = senceStory.name! as NSString
        showTitle = showTitle.trimmingCharacters(in: CharacterSet.newlines) as NSString
        cell.titleLable.setTitle("# \(showTitle) #", for: .normal)
        cell.titleLable.titleLabel?.adjustsFontSizeToFitWidth = true
        if senceStory.photoList != nil && (senceStory.photoList?.count)! >= 3 {
            let photoA = senceStory.photoList![0]
            let photoB = senceStory.photoList![1]
            let photoC = senceStory.photoList![2]
            
            cell.picA.sd_setImage(with: URL.init(string:WEBBASEURL_IAMGE + photoA.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
            cell.picB.sd_setImage(with: URL.init(string:WEBBASEURL_IAMGE + photoB.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
            cell.picC.sd_setImage(with: URL.init(string:WEBBASEURL_IAMGE + photoC.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
        }
        
        
        cell.selectionStyle = .none // 点击不变色
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VisualDetailsView") as! VisualDetailsViewController
        viewController.senceStory = self.dataSource[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "Segue_VisualDetails" {
//
//            let visualDetails: VisualDetailsViewController = segue.destination as! VisualDetailsViewController
//        }
//    }
    
    // 获取视觉分类列表
    func getWebResponseSuccessList(pageIndex: Int) {
        MBProgressHUD.showMessage("", to: self.view)
        VisualSenceBusiness.shareIntance.responseWebGetSenseStoryList(pageIndex: pageIndex, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = objectSuccess as! PageResultModel<SenceStoryModel>
            if pageIndex == 1 {
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
            }
            if self.page == pageResult.totalPage {
                self.tableView.es.noticeNoMoreData()
            }
            myPrint(message: objectSuccess)
            self.tableView.reloadData()
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate 代理方法的实现
    // MARK:
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
