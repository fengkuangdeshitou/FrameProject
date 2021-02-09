//
//  ReportPhotoViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/10/13.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class ReportPhotoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var reportPhotoId: String?
    
    fileprivate var dataSource: [String] = []
    
    fileprivate var currentIndex = -1
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "举报"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        let rightBarBtnItem = UIBarButtonItem.init(title: "举报", style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        
        // set TableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set data
        self.dataSource = ["色情低俗","广告骚扰","诱导分享","谣言","政治敏感","暴力","其他"]
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: rightBarBtnItem Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        // 举报
        
        let paramters = ["photoId" : self.reportPhotoId,
                         "content" : self.dataSource[self.currentIndex]]
        MBProgressHUD.showMessage("", to: self.view)
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoReport, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in}, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            MBProgressHUD.showSuccess("已举报", to: self.view)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
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
        let reportInfo = self.dataSource[indexPath.row]
        
        // text Cell
        let textCell = tableView.dequeueReusableCell(withIdentifier: "cell")
        textCell?.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        if indexPath.row == self.currentIndex {
            textCell?.accessoryType = .checkmark
        } else {
            textCell?.accessoryType = .none
        }
        
        textCell?.textLabel?.text = reportInfo
        
        return textCell!
    }
    
    // cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        self.currentIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELL_NORMAL_HEIGHT
    }
    
    // MARK: section Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: section Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationStyle()
    }
    
    // view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        
    }
    

    // MARK:  设置导航栏样式
    func setNavigationStyle() {
        //        self.automaticallyAdjustsScrollViewInsets = true
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
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

}
