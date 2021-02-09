//
//  MessagePushViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/16.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MessagePushViewController: UITableViewController, AppDelegateCustomDelegate {

    fileprivate var dataSource: [Array<[String : String]>] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化
        self.title = "推送设置"
        APP_DELEGATE.customDelegate = self
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem

        

        self.getWebSetting()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    // MARK: section count
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }

    // row count in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSectionArray = self.dataSource[section]
        return dataSectionArray.count
    }

    // cell content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 解析数据
        let dataSectionArray = self.dataSource[indexPath.section]
        let dataDict = dataSectionArray[indexPath.row]
        
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell0")
            if cell == nil {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cell0")
                cell?.accessoryType = .disclosureIndicator
                cell?.textLabel?.textColor = COLOR_DARK_GAY
                cell?.textLabel?.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
                
                cell?.detailTextLabel?.textColor = COLOR_LIGHT_GAY
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: FONT_SMART_SIZE)
            }
            
            cell?.textLabel?.text = dataDict[DICT_TITLE]
            
            if UIApplication.shared.currentUserNotificationSettings?.types == UIUserNotificationType.init(rawValue: 0) {
                cell?.detailTextLabel?.text = "已关闭"
                
            } else {
                cell?.detailTextLabel?.text = "已打开"
            }
            
            return cell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessagePushTableViewCell
        cell.selectionStyle = .none

        // Configure the cell...
        cell.showTitleLabel.text = dataDict[DICT_TITLE]
        
        if UIApplication.shared.currentUserNotificationSettings?.types == UIUserNotificationType.init(rawValue: 0) {
            // 全部关闭
            cell.showSwitch.isEnabled = false
        } else {
            cell.showSwitch.isEnabled = true
        }
        // 根据网络数据打开或关闭
        cell.showSwitch.accessibilityLabel = String(indexPath.section)
        cell.showSwitch.tag = indexPath.row
        cell.showSwitch.isOn = dataDict[DICT_SUB_VALUE1] == "1" ? true : false
        cell.showSwitch.addTarget(self, action: #selector(showSwitchClick(sender:)), for: UIControl.Event.valueChanged)

        return cell
    }
    
    
    // cell click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            // 跳转通知设置 UIApplicationOpenSettingsURLString
            UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    
    // cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MessagePushTableViewCell.CELL_HEIGHT
    }
    
    // header view
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return CELL_NORMAL_HEIGHT / 2.0
        }
        return 0.1
    }
    
    // footer view
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return CELL_NORMAL_HEIGHT
        }
        
        return 10.0
    }
    
    // footer String
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "要开启或关闭250消息推送，请在iPhone的【设置】-【通知】中找到“250你发布”进行设置"
        }
        
        return ""
    }

    
    // MARK: switch click
    @objc func showSwitchClick(sender: UISwitch) {
        // 解析数据
        let dataSectionArray = self.dataSource[Int(sender.accessibilityLabel!)!]
        let dataDict = dataSectionArray[sender.tag]
        
        // 设置通知
        let isOpen = dataDict[DICT_SUB_VALUE1] == "1" ? true : false
        MessageBusiness.shareIntance.responseWebPushMessageSetting(messageTypeCode: dataDict[DICT_IDENTIFIER]!, isOpen: !isOpen, responseSuccess: { (objectSuccess) in
            self.getWebSetting()
        }) { (error) in
        }
    }
    

    
    // MARK: viewdidappear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }

    
    // MARK: - AppDelegateCustomDelegate
    // MARK: appWillEnterForeground
    func appWillEnterForeground() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.tableView.reloadData()
        }
    }
    
    
    // 获取网络上的消息设置
    func getWebSetting() {
       MBProgressHUD.showMessage("", to: self.view)
        MessageBusiness.shareIntance.responseWebPushMessageGetSetting(responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let messagePushSettingArray = objectSuccess as! [MessageSettingModel]
            // 1: 开， 0：关
            self.dataSource = [[[DICT_TITLE : "接收推送通知", DICT_SUB_TITLE : ""]],
                               
                               [[DICT_TITLE : "关注消息提醒", DICT_SUB_TITLE : "", DICT_SUB_VALUE1 : self.findMessagePushStatus(messageTypeCode: MessageTypeCode.attention, messagePushArray: messagePushSettingArray), DICT_IDENTIFIER : MessageTypeCode.attention.rawValue],
                                [DICT_TITLE : "点赞消息提醒", DICT_SUB_TITLE : "", DICT_SUB_VALUE1 : self.findMessagePushStatus(messageTypeCode: MessageTypeCode.support, messagePushArray: messagePushSettingArray), DICT_IDENTIFIER : MessageTypeCode.support.rawValue],
                                [DICT_TITLE : "评论消息提醒", DICT_SUB_TITLE : "", DICT_SUB_VALUE1 : self.findMessagePushStatus(messageTypeCode: MessageTypeCode.comment, messagePushArray: messagePushSettingArray), DICT_IDENTIFIER : MessageTypeCode.comment.rawValue],
                                [DICT_TITLE : "@我消息提醒", DICT_SUB_TITLE : "", DICT_SUB_VALUE1 : self.findMessagePushStatus(messageTypeCode: MessageTypeCode.sendPhoto, messagePushArray: messagePushSettingArray), DICT_IDENTIFIER : MessageTypeCode.sendPhoto.rawValue]],
                               
                               [[DICT_TITLE : "其它", DICT_SUB_TITLE : "", DICT_SUB_VALUE1 : self.findMessagePushStatus(messageTypeCode: MessageTypeCode.other, messagePushArray: messagePushSettingArray), DICT_IDENTIFIER : MessageTypeCode.other.rawValue]],
            ]
            
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: 查询推送状态
    func findMessagePushStatus(messageTypeCode: MessageTypeCode, messagePushArray: [MessageSettingModel]) -> String {
        var status = "1"
        for mset in messagePushArray {
            if messageTypeCode.rawValue == mset.messageTypeCode! {
                status = String(mset.status!)
                return status
            }
        }
        
        return status
    }
    
}
