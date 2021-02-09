//
//  DepositCashStatusViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/3.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class DepositCashStatusViewController: UIViewController {
    
    var isSuccess: Bool?

    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showStatusLabel: UILabel!
    
    @IBOutlet weak var backMyWalletBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = ""
        self.backMyWalletBtn.layer.masksToBounds = true
        self.backMyWalletBtn.layer.cornerRadius = self.backMyWalletBtn.height / 2
        self.backMyWalletBtn.layer.borderColor = COLOR_LIGHT_GAY.cgColor
        self.backMyWalletBtn.layer.borderWidth = BORDER_WIDTH
        if self.isSuccess! {
            // 成功
            self.showImageView.image = #imageLiteral(resourceName: "merchant_pay_success")
            self.showStatusLabel.text = "提现成功"
            self.showStatusLabel.textColor = COLOR_PAY_SUCCESS
        } else {
            // 失败
            self.showImageView.image = #imageLiteral(resourceName: "merchant_pay_failed")
            self.showStatusLabel.text = "提现不成功"
            self.showStatusLabel.textColor = COLOR_PAY_FAILED
        }
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        if self.isSuccess! {
            let viewControllers = self.navigationController?.viewControllers
            self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 4], animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: 我的钱包点击
    @IBAction func backMyWalletBtnClick(_ sender: UIButton) {
        let viewControllers = self.navigationController?.viewControllers
        self.navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 4], animated: true)
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
