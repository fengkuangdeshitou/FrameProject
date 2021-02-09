//
//  ESPullAddScrollViewForReflesh.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/17.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

/// scrollView刷新类型
///
/// - GET:  GET 方式
/// - POST: POST 方式
enum ScrollViewRefleshType : String {
    case all = "all"
    case reflesh = "reflesh"
    case moreData = "moreData"
}

class ESPullAddScrollViewForReflesh: NSObject {

    // 单例
    static let shareIntance: ESPullAddScrollViewForReflesh = {
        let espull = ESPullAddScrollViewForReflesh()
        
        return espull
    }()
}


extension ESPullAddScrollViewForReflesh {
    
    
    
    /// 添加刷新模块
    ///
    /// - Parameters:
    ///   - scrollView: 要添加刷新模块的scrollView
    ///   - refleshType: 刷新类型
    ///   - reflesh: 刷新方法
    ///   - moreData: 加载更多的方法
    func addScrollViewRefleshOrMoreData(scrollView: UIScrollView, refleshType: ESRefreshExampleType, reflesh:ESRefreshHandler?, moreData: ESRefreshHandler?) {
        // 设置刷新
        //  上拉刷新 type 1
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        var footer: ESRefreshProtocol & ESRefreshAnimatorProtocol
        switch refleshType {
        case .meituan:
            header = MTRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = MTRefreshFooterAnimator.init(frame: CGRect.zero)
        case .wechat:
            header = WCRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        default:
            header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
            break
        }
        
        if reflesh != nil {
            _ = scrollView.es.addPullToRefresh(animator: header) {
                reflesh!()
            }
        }
        
        if moreData != nil {
            _ = scrollView.es.addInfiniteScrolling(animator: footer, handler: {
                moreData!()
            })
        }
    }
}

