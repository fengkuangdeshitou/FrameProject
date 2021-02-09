//
//  CZFGuidePageViewController.swift
//  CZFGuidePageViewDemo
//
//  Created by 陈帆 on 2018/2/28.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

protocol GuidePageDelegate: NSObjectProtocol {
    func willDismissHandler()
}

class CZFGuidePageViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var delegate: GuidePageDelegate?
    
    
    fileprivate lazy var collectionView: UICollectionView = {
        // layout
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionViewTemp = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        collectionViewTemp.bounces = false
        collectionViewTemp.delegate = self
        collectionViewTemp.dataSource = self
        collectionViewTemp.isPagingEnabled = true
        collectionViewTemp.showsVerticalScrollIndicator = false
        collectionViewTemp.showsHorizontalScrollIndicator = false
        
        // register cell
        collectionViewTemp.register(CZFGuideCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: CZFGuideCollectionViewCell.guideCellId)
        
        return collectionViewTemp
    }()
    
    
    // UIPageControll
    fileprivate lazy var pageControl: UIPageControl = {
        let pageControlTemp = UIPageControl.init()
        pageControlTemp.numberOfPages = GuideManager.images.count
        pageControlTemp.pageIndicatorTintColor = GuideManager.pageIndicatorColor == nil ? UIColor.init(white: 1.0, alpha: 0.5) : GuideManager.pageIndicatorColor
        pageControlTemp.currentPageIndicatorTintColor = GuideManager.currentIndicatorColor == nil ? UIColor.white : GuideManager.currentIndicatorColor
        pageControlTemp.hidesForSinglePage = true
        pageControlTemp.isUserInteractionEnabled = false
        
        pageControlTemp.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height - 30)
        
        return pageControlTemp
    }()
    
    
    fileprivate lazy var dismissButton: UIButton = {
        let dismissBtnWidth = GuideManager.dismissButtonImage?.size.width
        let dismissBtnHeight = GuideManager.dismissButtonImage?.size.height
        
        let dismissButtonTemp = UIButton.init(frame: CGRect(x: 0, y: 0, width: dismissBtnWidth!, height: dismissBtnHeight!))
        dismissButtonTemp.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height - 80.0)
        dismissButtonTemp.setImage(GuideManager.dismissButtonImage!, for: UIControl.State.normal)
        
        return dismissButtonTemp
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.dismissButton)
        
        self.collectionView.backgroundColor = UIColor.red
        self.dismissButton.isHidden = true
        self.dismissButton.addTarget(self, action: #selector(dismissButtonClick(sender:)), for: UIControl.Event.touchUpInside)
        
        if GuideManager.isShowPageControl != nil && GuideManager.isShowPageControl! {
            self.view.addSubview(self.pageControl)
        }
    }
    
    // MARK: dismissButtonClick
    @objc func dismissButtonClick(sender: UIButton) {
        self.delegate?.willDismissHandler()
    }
    
    
    // MARK: - UICollectionView Delegate implement
    // MARK: section count
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GuideManager.images.count
    }
    
    // MARK: cell content
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CZFGuideCollectionViewCell.guideCellId, for: indexPath)  as! CZFGuideCollectionViewCell
        
        cell.showImageView?.image = GuideManager.images[indexPath.row]
        
        return cell
    }
    
    // MARK: size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.bounds.size
    }
    
    // MARK:minimumLineSpacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK:minimumInteritemSpacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: scrollViewDidEndDecelerating
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.x / self.collectionView.bounds.size.width)
        
        if currentIndex == GuideManager.images.count - 1 {
            self.dismissButton.isHidden = false
            self.dismissButton.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                self.dismissButton.alpha = 1.0
            }) { (isFinish) in
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.dismissButton.alpha = 0.0
            }) { (isFinish) in
                self.dismissButton.isHidden = true
            }
        }
        
        self.pageControl.currentPage = currentIndex
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
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
