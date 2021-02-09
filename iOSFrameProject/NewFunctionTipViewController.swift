//
//  NewFunctionTipViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/1/30.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

protocol NewFunctionTipViewDelegate: NSObjectProtocol {
    // MARK: 图片点击回调
    func imageViewClickWiathDataDict(dataDict: [String : String])
}

class NewFunctionTipViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    fileprivate var dataSource: [[String : String]] = []        // 数据源
    
    weak var newFunctionDelegate: NewFunctionTipViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setViewUI()
    }
    
    
    // MARK: - UIScrollView Delegate 方法实现
    // MARK: scrollViewDidEndDecelerating
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
        self.pageControl.currentPage = pageIndex
    }
    
    
    // MARK: close Btn Click
    @IBAction func closeBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion:  nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    // MARK: view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
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


extension NewFunctionTipViewController {
    func setViewUI()  {
        // 初始化
        
        // 设置导航栏
        
        // 设置数据源 DICT_IMAGE_PATH: 图片地址(本地/网络)   DICT_SUB_VALUE1：跳转链接(url/控制器id)
        self.dataSource = [[DICT_IMAGE_PATH : "advertise_carbon_func", DICT_SUB_VALUE1 : "MineView"], [DICT_IMAGE_PATH : "advertise_report", DICT_SUB_VALUE1 : WEBBASEURL + "/static/report2017/index.html"]]
        
        // 设置View
        let marginRightAndLeft: CGFloat = 15
        for (index, dict) in self.dataSource.enumerated() {
            let itemView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH - marginRightAndLeft*2))
            itemView.x = CGFloat(index) * SCREEN_WIDTH
            itemView.backgroundColor = UIColor.clear
            let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: itemView.height, height: itemView.height))
            imageView.center = CGPoint(x: itemView.width / 2, y: itemView.height / 2)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
            let imageUrlStr = dict[DICT_IMAGE_PATH]
            if (imageUrlStr?.hasPrefix("http"))! {
                imageView.sd_setImage(with: URL.init(string: imageUrlStr!))
            } else {
                imageView.image = UIImage.init(named: imageUrlStr!)
            }
            itemView.addSubview(imageView)
            
            // 设置点击ImageView事件
            imageView.isUserInteractionEnabled = true
            imageView.tag = index
            imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(imageViewClickWithGesture(sender:))))
            
            self.scrollView.addSubview(itemView)
        }
        
        // 设置scrollview
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: CGFloat(self.dataSource.count) * SCREEN_WIDTH, height: NAVIGATION_AND_STATUS_HEIGHT)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.isPagingEnabled = true
        
        
        // 设置pageControl
        self.pageControl.numberOfPages = self.dataSource.count
        self.pageControl.hidesForSinglePage = true
        self.pageControl.isUserInteractionEnabled = false
    }
    
    
    @objc func imageViewClickWithGesture(sender: UIGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        // 解析数据
        let dataDict = self.dataSource[(sender.view?.tag)!]
        self.newFunctionDelegate?.imageViewClickWiathDataDict(dataDict: dataDict)
    }
}
