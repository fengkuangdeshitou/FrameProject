//
//  MerchantSearchViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MerchantSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    fileprivate var dataSource: [MerchantModel] = []
    
    fileprivate var mRecordArray: NSArray = []
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate lazy var searchTextField: CZFToolTextField = {
        let textField = CZFToolTextField.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 120, height: 30))
        
        textField.backgroundColor = UIColor.white
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = textField.height / 2
        textField.delegate = self
        textField.returnKeyType = UIReturnKeyType.search
        
        // left view
        let leftSearchImageView = UIImageView.init(frame: CGRect(x: 0, y: (textField.height-17.0)/2.0, width: 18, height: 17))
        leftSearchImageView.image = UIImage.init(named: "discover_search")
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = leftSearchImageView
        textField.textColor = COLOR_DARK_GAY
        textField.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        textField.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = ""
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        let rightBarBtnItem = UIBarButtonItem.init(title: "搜索", style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        self.navigationItem.titleView = self.searchTextField
        
        
        // 设置tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(UINib.init(nibName: "MerchantTableViewCell", bundle: nil), forCellReuseIdentifier: MerchantTableViewCell.CELL_ID)
        self.tableView.register(MerchantHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: MerchantHeaderView.HEADER_ID)
        
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.searchTextField.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        _ = self.textFieldShouldReturn(self.searchTextField)
    }
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchTextField.text == "" {
            return 1
        }
        
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
        if self.searchTextField.text == "" {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            
            if cell == nil {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
                cell?.selectionStyle = .none
            }
            UIView.removeSubviews(cell?.contentView)
            let gapXY = 8, labelHeight = 25, inlineWidth = 15, fontSize = 14;
            for (i, _) in self.mRecordArray.enumerated() {
                let titlelabel = UILabel.init(frame: CGRect.zero)
                
                titlelabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
                titlelabel.textColor = COLOR_DARK_GAY
                titlelabel.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
                titlelabel.textAlignment = .center
                titlelabel.tag = i
                titlelabel.layer.masksToBounds = true
                titlelabel.layer.cornerRadius = CORNER_SMART
                
                titlelabel.isUserInteractionEnabled = true
                titlelabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
                    self.searchTextField.text = titlelabel.text
                    _ = self.textFieldShouldReturn(self.searchTextField)
                }))
            
                
                //这个frame是初设的，没关系，后面还会重新设置其size。  //lbDetailInformation1
                let attributes1: NSDictionary = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize))]
                let str = self.mRecordArray[i] as! NSString
                let textSize = str.boundingRect(with: CGSize.init(width: SCREEN_WIDTH-CGFloat(2*gapXY), height: 100), options: .truncatesLastVisibleLine, attributes: attributes1 as? [NSAttributedString.Key : Any], context: nil).size
                
                
                // 获取前一个label
                var titleLabelX = CGFloat(gapXY), titlelabelY = CGFloat(gapXY);
                if (i != 0) {
                    let preLabel = cell?.contentView.subviews[i - 1]
                    titleLabelX = (preLabel?.x)! + (preLabel?.width)! + CGFloat(gapXY)
                    let currentContentWidth = titleLabelX + textSize.width + CGFloat(inlineWidth + gapXY)
                    titleLabelX = currentContentWidth <= SCREEN_WIDTH ? titleLabelX : CGFloat(gapXY)
                    titlelabelY = currentContentWidth <= SCREEN_WIDTH ? preLabel!.y : ((preLabel?.y)! + CGFloat(gapXY + labelHeight))
                }
                
                titlelabel.frame = CGRect(x: titleLabelX, y: titlelabelY, width: CGFloat(Int(textSize.width) + inlineWidth), height: CGFloat(labelHeight))
                titlelabel.text = str as String
                
                cell?.contentView.addSubview(titlelabel)
            }
            
            let lastLabel = cell?.contentView.subviews.last
            if lastLabel == nil {
                cell?.height = CGFloat(labelHeight + gapXY)
            } else {
                cell?.height = (lastLabel?.y)! + CGFloat(labelHeight + gapXY)
            }
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MerchantTableViewCell.CELL_ID) as! MerchantTableViewCell
            cell.accessoryType = .disclosureIndicator
            
            // 解析数据
            let merchant = self.dataSource[indexPath.row]
            
            // 设置图片
            cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + merchant.logo!), placeholderImage: DEFAULT_IMAGE())
            
            // name
            cell.showTitleLabel.text = merchant.name
            
            // 描述
            cell.showSubTitleLabel.text = merchant.description
            
            // 设置支付响应
            cell.goToPayBtn.tag = indexPath.row
            cell.goToPayBtn.addTarget(self, action: #selector(goToPayBtnClick(sneder:)), for: UIControl.Event.touchUpInside)

            return cell
        }
        
        
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.searchTextField.text == "" {
            return
        }
        
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
        
        
        // 跳转商铺详情
        self.searchTextField.resignFirstResponder()
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "MerchantDetialView") as! MerchantDetialViewController
        viewController.merchant = self.dataSource[indexPath.row]
        viewController.userLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.searchTextField.text == "" {
            let cell = self.tableView(tableView, cellForRowAt: indexPath)
            return cell.height
        }
        return MerchantTableViewCell.CELL_HEIGHT
    }
    
    
    // MARK: header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.searchTextField.text == "" {
            let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: MerchantHeaderView.HEADER_ID) as! MerchantHeaderView
            headerView.textLabel?.text = "最近搜索"
            
            headerView.deleteBtn?.addTarget({ (sender) in
                let alertVC = UIAlertController.init(title: "确认删除全部最近搜索记录？", message: nil, preferredStyle: .alert)
                // 取消
                alertVC.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (sender) in
                    
                }))
                // 确定
                alertVC.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (sender) in
                    self.clearHistoryRecord()
                }))
                self.present(alertVC, animated: true, completion: nil)
            }, andEvent: UIControl.Event.touchUpInside)
            
            return headerView
        }
        return nil
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.searchTextField.text == "" {
            return MerchantHeaderView.HEADER_HEIGHT
        }
        return 0.1
    }
    
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchTextField.resignFirstResponder()
    }
    
    
    // MARK: - UITextFieldDelegate
    // MARK:  textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            MBProgressHUD.show("请输入商家名称", icon: nil, view: self.view)
            return true
        }
    
        
        let searchResultArray = NSMutableArray.init(array: self.mRecordArray)
        
        // 保存搜索记录
        for (i, _) in searchResultArray.enumerated() {        // 去掉重复的历史记录
            let stringText = searchResultArray[i] as! String
            if stringText == self.searchTextField.text {
                searchResultArray.remove(stringText)
                break
            }
        }
        searchResultArray.insert(self.searchTextField.text as Any, at: 0)
        // 获取存入plist文件的完整路径
        let plistPath = DOCUMENTS_PATH.appendingPathComponent(SEARCH_HISTORY_PATH)
        searchResultArray.write(toFile: plistPath, atomically: true)

        
        // 搜索商家
        self.getMerchantSearchList(regionCode: nil, merchantName: self.searchTextField.text)
        
        return true
    }
    
    // MARK: shouldChangeCharactersIn
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        
        if nowString == "" {
            self.tableView.backgroundView = nil
            self.searchTextField.text = nowString
            self.tableView.reloadData()
        }
        
        return true
    }
    
    
    // MARK: 清除历史记录
    func clearHistoryRecord() {
        let plistPath = DOCUMENTS_PATH.appendingPathComponent(SEARCH_HISTORY_PATH)
        self.mRecordArray = []
        self.mRecordArray.write(toFile: plistPath, atomically: true)
        
        self.tableView.reloadData()
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
        self.searchTextField.resignFirstResponder()
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "PayView") as! PayViewController
        viewController.merchant = self.dataSource[sneder.tag]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchTextField.becomeFirstResponder()
        
        
        
        // 获取历史记录数据 -- （历史记录缓存到本地）
        let plistPath = DOCUMENTS_PATH.appendingPathComponent(SEARCH_HISTORY_PATH)
        let historyArray = NSMutableArray.init(contentsOfFile: plistPath)
        self.mRecordArray = historyArray == nil ? NSArray.init() : historyArray!
        
        self.tableView.reloadData()
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
            
            // 清空数据
            self.dataSource.removeAll()
            self.dataSource = resonseSuccess as! [MerchantModel]
            
            self.tableView.reloadData()
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

}
