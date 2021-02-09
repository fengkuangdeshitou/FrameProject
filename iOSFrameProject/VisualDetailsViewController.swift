//
//  VisualDetailsViewController.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/23.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class VisualDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var senceStory: SenceStoryModel?
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var showTitle = (self.senceStory?.name)! as NSString
        showTitle = showTitle.trimmingCharacters(in: CharacterSet.newlines) as NSString
        self.title = "# \(showTitle) #"
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        tableView.tableFooterView = UIView.init()
        self.tableView.register(UINib.init(nibName: "VisSenDetailTableViewCell", bundle: nil), forCellReuseIdentifier: VisSenDetailTableViewCell.CELL_ID)
        
        self.getVisualSenceDetail()
    }
    
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ e: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            let labelHeight = UILabel.getSpaceLabelHeight((self.senceStory?.description)!, with: UIFont.systemFont(ofSize: FONT_SYSTEM_SIZE), withWidth: SCREEN_WIDTH - 24 * 2, andLineSpaceing: 6.0)
            
            return labelHeight + 20
        }else {
            // 解析数据
            let photo = self.senceStory?.photoList![indexPath.row - 1]
            
            return CGFloat((photo?.imageWidth)!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.senceStory?.photoList?.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let initIdentifier = "CellA"
            let cell: VisualDetailsTableCellText = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as! VisualDetailsTableCellText
            
            UILabel.setLabelSpace(cell.textLabels, withValue: (self.senceStory?.description)!, with: cell.textLabels.font, andLineSpaceing: 6.0)
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none // 点击不变色
            return cell
        }else {
            
            // 解析数据
            let photo = self.senceStory?.photoList![indexPath.row - 1]
//            let initIdentifier = "CellB"
//            let cell: VisualDetailsTableCellPic = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as! VisualDetailsTableCellPic
        
            let cell = tableView.dequeueReusableCell(withIdentifier: VisSenDetailTableViewCell.CELL_ID) as! VisSenDetailTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none // 点击不变色
            
            // 用户头像
            cell.showUserImageView.sd_setImage(with: URL(string: WEBBASEURL_IAMGE + (photo?.user?.avatar)!), placeholderImage: DEFAULT_USER_ICON)
            
            // UserName
            cell.showNameLabel.text = photo?.user?.nickname
            
            // 右边地址显示
            cell.showRightLabel.text = NSString.getCityAndProinceName(withAddressStr: (photo?.address)!)
            
            // 拍摄时间
            let takeDate = Date.init(timeIntervalSince1970: (photo?.takeTime)! / 1000)
            cell.showTimeLabel.text = "拍摄于 " + NSDate.stringNormalRead(with: takeDate)
            
            // 描述
            let descriStr = "" //AddressPickerDemo.stringReplaceEncode(with: (photo?.description)!)
            cell.showDetailLabel.numberOfLines = 0
            cell.showDetailLabel.text = descriStr
            
            // 详细图片展示
            cell.showDetailImageView.sd_setImage(with: URL(string: WEBBASEURL_IAMGE + (photo?.dehazePhoto)!), placeholderImage: DEFAULT_IMAGE())
            
            // 设置cell适配
            var descriLabelHeight: CGFloat = 0.0
            if descriStr != "" {
                descriLabelHeight = UILabel.getSpaceLabelHeight(descriStr, with: cell.showDetailLabel.font, withWidth: SCREEN_WIDTH - 21*2, andLineSpaceing: 3.0)
            }
            UILabel.setLabelSpace(cell.showDetailLabel, withValue: descriStr, with: cell.showDetailLabel.font, andLineSpaceing: 3.0)
            cell.showDetailLabel.height = descriLabelHeight
            cell.showDetailLabel.width = SCREEN_WIDTH - 21*2
            cell.showDetailImageView.width = cell.showDetailLabel.width
            cell.showBottomLineView.width = cell.showDetailImageView.width
            
            if descriLabelHeight == CGFloat(0.0) {
                cell.showDetailImageView.y = cell.showDetailLabel.y
            } else {
                cell.showDetailImageView.y = cell.showDetailLabel.y + cell.showDetailLabel.height + 20
            }
            cell.showDetailImageView.height = cell.showDetailImageView.width * 3.0 / 4.0
            
            
            // cell frame
            cell.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: cell.showDetailImageView.y + cell.showDetailImageView.height + 20)
            photo?.imageWidth = Float(cell.height)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            return
        }
        
        // 解析数据
        let photo = self.senceStory?.photoList![indexPath.row - 1]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ShowPhotoView") as! ShowPhotoViewController
        viewController.senceData = photo
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    /**
     计算label的宽度和高度
     :param: text       label的text的值
     :returns: 返回计算后label的CGRece
     */
    func labelSize(text: String) -> CGRect{
        
        let attributes = [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)] // 设置字体大小
        
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        
        let rect: CGRect = text.boundingRect(with: CGSize.init(width: SCREEN_WIDTH-30, height: 999.9), options: option, attributes: attributes, context: nil) // 获取字符串的frame
        
        return rect
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        // 设置导航栏
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE),NSAttributedString.Key.foregroundColor:COLOR_DARK_GAY]
//        self.navigationController?.navigationBar.titleTeNSAttributedString.Key.fontontAttributeName : UIFont.systemFont(ofSize: NAVIGATION_TINSAttributedString.Key.foregroundColorlorAttributeName : COLOR_DARK_GAY]
        self.navigationController?.navigationBar.tintColor = COLOR_DARK_GAY
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    
    
    // MARK: 获取视觉故事详情
    func getVisualSenceDetail()  {
        MBProgressHUD.showMessage("", to: self.view)
        VisualSenceBusiness.shareIntance.responseWebGetSenseStoryDetial(visualId: (self.senceStory?.id)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.senceStory = objectSuccess as? SenceStoryModel
            
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

