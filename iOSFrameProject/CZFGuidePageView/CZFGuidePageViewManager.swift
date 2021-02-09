//
//  CZFGuidePageViewManager.swift
//  CZFGuidePageViewDemo
//
//  Created by 陈帆 on 2018/2/28.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import Foundation


let GuideManager = CZFGuidePageViewManager.shareIntance

/// 自定义带方法名和行号的打印方法
///
/// - parameter message:    message
/// - parameter methodName: 方法名
/// - parameter lineNumber: 行号
func CZFPrint<T>(message: T, methodName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
        print("\(methodName)[\(lineNumber)]:\(message)")
    #endif
}

class CZFGuidePageViewManager: NSObject, GuidePageDelegate {
    fileprivate var window: UIWindow?
    
    // 滚动图片
    var images: [UIImage] = []
    // 进入App按钮图片
    var dismissButtonImage: UIImage?
    
    // 是否显示 pageControl
    var isShowPageControl: Bool?
    // default page indicator color
    var pageIndicatorColor: UIColor?
    // current indicator color
    var currentIndicatorColor: UIColor?
    
    
    
    // 单例
    static let shareIntance: CZFGuidePageViewManager = {
        let dealFact = CZFGuidePageViewManager()
        
        return dealFact
    }()
    
    
    // MARK: begin
    func begin() {
        assert(self.images.count > 0, "please set images.")
        assert(self.dismissButtonImage != nil, "please set dismiss image.")
        
        // check show condition
        if currentVersion() > preVersion() {
            saveVersion()
            
            self.window = UIWindow.init()
            self.window?.frame = UIScreen.main.bounds
            self.window?.windowLevel = UIWindow.Level.statusBar
            
            let guideVc = CZFGuidePageViewController()
            guideVc.delegate = self
            self.window?.rootViewController = guideVc
            
            self.window?.makeKeyAndVisible()
        } else {
            end()
            CZFPrint(message: "app is new")
        }
    }
    
    // MARK: - GuidePageDelegate
    func willDismissHandler() {
        saveVersion()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.window?.alpha = 0.0
        }) { (isFinish) in
            self.end()
        }
    }
    
    // MARK: end
    func end() {
        self.window?.isHidden = true
        self.window = nil
        self.images = []
    }
    
    
    // MARK:currentVersion
    func currentVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }
    
    // MARK:currentVersion
    func saveVersion() {
        do {
            try currentVersion().write(toFile: doucmentPath(), atomically: true, encoding: String.Encoding.utf8)
        } catch {
            CZFPrint(message: "write file error.")
        }
        
    }
    
    // MARK:preVersion
    func preVersion() -> String {
        
        var version = ""
        do {
            version = try String(contentsOfFile: doucmentPath(), encoding: String.Encoding.utf8)
        } catch  {
            CZFPrint(message: "get previous version error.")
        }
        
        return version
    }
    
    // MARK: document Path
    func doucmentPath() -> String {
        let homeDirectory = NSHomeDirectory()
        if homeDirectory.hasSuffix("/") {
            return homeDirectory + "Documents/version.data"
        } else {
            return homeDirectory + "/Documents/version.data"
        }
    }
}
