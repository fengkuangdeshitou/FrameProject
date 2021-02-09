//
//  PayStatusViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/27.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class PayStatusViewController: UIViewController {

    var payStatus: Int?         // -1：支付失败， 1：支付成功
    
    @IBOutlet weak var showStatusImageView: UIImageView!
    
    @IBOutlet weak var showStatusLabel: UILabel!
    
    
    @IBOutlet weak var lookOrderBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = ""
        self.lookOrderBtn.layer.masksToBounds = true
        self.lookOrderBtn.layer.cornerRadius = self.lookOrderBtn.height / 2
        self.lookOrderBtn.layer.borderColor = COLOR_LIGHT_GAY.cgColor
        self.lookOrderBtn.layer.borderWidth = BORDER_WIDTH
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
        // 设置状态
        if self.payStatus == 1 {
            // 支付成功
            self.showStatusImageView.image = #imageLiteral(resourceName: "merchant_pay_success")
            self.showStatusLabel.text = "支付成功"
            
        } else {
            // 支付失败
            self.showStatusImageView.image = #imageLiteral(resourceName: "merchant_pay_failed")
            self.showStatusLabel.text = "支付未成功"
            self.lookOrderBtn.isHidden = true
        }
        
        // 发送支付状态消息通知
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_PayStatus), object: self.payStatus == 1 ? true : false)
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        let viewControllers = self.navigationController?.viewControllers
        if (viewControllers?.count)! > 2 {
            self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 3], animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: 查看订单点击
    @IBAction func lookOrderBtnClick(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineOrderView") as! MineOrderViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
