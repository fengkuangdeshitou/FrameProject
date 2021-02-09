//
//  WebPageViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/10/9.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit
import WebKit

class WKWebPageViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, ShareThirdViewDelegate {
    
    @IBOutlet weak var showTopLabel: UILabel!
    
    var showNavTitle: String?
    
    var localPageUrlFilePath: String?   // 本地html的路径地址
    var pageUrlStr: String?         // 页面URL
    var pageThumbImageUrl: String?  // 分享宣传图片URL
    var isUserGesture: Bool?        // 是否具有捏合收拾
    var isShowShareBtn: Bool?       // 是否显示分享
    
    var isYearReportShare: Bool?    // 是否是年报分享
    
    var isAdaptNavigationHeight: Bool?  // 是否适配导航栏高度影响
    var isShowWebPageTrack: Bool?       // 是否显示Web请求地址（有谁提供）
    
    /// webView
    fileprivate lazy var webView: WKWebView  = {
        // 创建webveiew
        // 创建一个webiview的配置项
        let configuretion = WKWebViewConfiguration()
        
        // Webview的偏好设置
        configuretion.preferences = WKPreferences()
        
        // ************   解决不能加载微信公众号文章在iOS11.0设备上的问题  ************ //
        configuretion.preferences.minimumFontSize = 0
        
        configuretion.preferences.javaScriptEnabled = true
        
        // 默认是不能通过JS自动打开窗口的，必须通过用户交互才能打开
        configuretion.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        // 通过js与webview内容交互配置
        configuretion.userContentController = WKUserContentController()
        
        // 添加一个名称，就可以在JS通过这个名称发送消息：
        // window.webkit.messageHandlers.AppModel.postMessage({body: 'xxx'})
        configuretion.userContentController.add(self, name: "iOSAppModel")
        
        let webViewTemp = WKWebView.init(frame: self.view.bounds, configuration: configuretion)
        
        webViewTemp.uiDelegate = self
        webViewTemp.navigationDelegate = self
        
        // 是否适配导航栏高度影响
        if self.isAdaptNavigationHeight != nil && self.isAdaptNavigationHeight! {
            webViewTemp.height = SCREEN_HEIGHT - NAVIGATION_AND_STATUS_HEIGHT
        }
        
        // 去掉底部黑条
        webViewTemp.isOpaque = false
        webViewTemp.backgroundColor = UIColor.clear
        
        // 是否添加捏合收拾
        if self.isUserGesture != nil && self.isUserGesture! {
            webViewTemp.autoresizingMask = (UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue))))
            webViewTemp.allowsBackForwardNavigationGestures = true
            webViewTemp.isMultipleTouchEnabled = true
            //内容自适应
            webViewTemp.sizeToFit();
            webViewTemp.isUserInteractionEnabled = true
        }
        
        self.view.addSubview(webViewTemp)
        return webViewTemp
    }()
    
    
    // MARK: activityView
    fileprivate lazy var activityView: UIActivityIndicatorView = {
        let activityViewTemp = UIActivityIndicatorView.init(style: .gray)
        
        activityViewTemp.center = self.view.center
        activityViewTemp.isHidden = true
        
        return activityViewTemp
    }()
    
    
    // MARK: ProgressView
    fileprivate lazy var progressView: UIProgressView = {
        let progressViewTemp = UIProgressView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 3))
        progressViewTemp.trackTintColor = UIColor.clear
        progressViewTemp.progressTintColor = UIColorFromRGB(rgbValue: 0x52afad)
        progressViewTemp.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        
        return progressViewTemp
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.showTopLabel.isHidden = true
        // 判断是否是年报
        if self.pageUrlStr != nil && self.isYearReportShare != nil && self.isYearReportShare! {
            self.pageUrlStr = self.pageUrlStr! + "?userId=\(String(describing: (APP_DELEGATE.currentUserInfo?.id)!))&f=1"
        }
        
        if self.isShowWebPageTrack == nil || self.isShowWebPageTrack! {
            self.showTopLabel.isHidden = false
        } else {
            self.showTopLabel.isHidden = true
        }
        
        self.setViewUI()
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: rightBarBtnItem Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        // 第三方分享
        // 跳转 Share显示界面
        let viewController = ShareThirdViewController.init(nibName: "ShareThirdViewController", bundle: nil)
        viewController.customDelegate = self
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    // MARK: - ShareThirdViewDelegate
    // MARK: 平台分享
    func shareThirdViewPublish(platformType: UMSocialPlatformType) {
        if (self.pageThumbImageUrl?.hasPrefix("http"))! {
            let thumbImageView = UIImageView.init()
            thumbImageView.sd_setImage(with: URL.init(string: self.pageThumbImageUrl!), completed: { (image, error, cacheType, url) in
                self.shareWebPageToPlatformType(platformType: platformType, thumbImage: image)
            })
        } else {
            self.shareWebPageToPlatformType(platformType: platformType, thumbImage: UIImage.init(named: self.pageThumbImageUrl!))
        }
    }
    
    
    // MARK: - UIWebViewDelegate 方法的实现
    // MARK: did start load
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //开始加载网页时展示出progressView
        self.progressView.isHidden = false
        //开始加载网页的时候将progressView的Height恢复为1.5倍
        self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        //防止progressView被网页挡住
        self.view.bringSubviewToFront(self.progressView)
        
        
        self.showTopLabel.isHidden = true
    }
    
    // MARK: did finish load
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // 取消加载圈
        self.activityView.isHidden = true
        self.activityView.stopAnimating()
        
        // 检验是否是否返回（pop/back）
        self.checkGoBack()
        
        // 禁止放大缩小
        if self.isUserGesture == nil || !self.isUserGesture! {
            let injectionJSString = "var script = document.createElement('meta');"
                + "script.name = 'viewport';"
                + "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
                + "document.getElementsByTagName('head')[0].appendChild(script);";
            webView.evaluateJavaScript(injectionJSString, completionHandler: nil)
        }
        
        // 如果不是网页显示字符串
        if self.pageUrlStr != nil && !(self.pageUrlStr?.hasPrefix("http"))! {
            webView.evaluateJavaScript("document.getElementById('qr-text').innerText='\(self.pageUrlStr!)'") { (object, error) in
                if error != nil {
                    myPrint(message: error)
                }
            }
        }
    }
    
    
    
    // MARK:  did finish error
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityView.isHidden = true
        self.activityView.stopAnimating()
        //        self.webProgressLayer.finishedLoadWithError(error)
        
        //加载失败同样需要隐藏progressView
        //self.progressView.hidden = YES;
        
        // 检验是否是否返回（pop/back）
        self.checkGoBack()
    }
    
    // MARK:didReceive 
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cred = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
    }
    
    
    // MARK: 服务器请求跳转的时候调用
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        if (request.url?.absoluteString.contains("shareReport"))! {
            ///获取到请求的 url中传回的信息 包含 jsBack 则返回上一级
            self.rightBarBtnItemClick(sender: UIBarButtonItem.init())
            return false
        }
        
        
        return true
    }
    
    // MARK: js响应回调
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        myPrint(message: "body =\(message.body), name=\(message.name)")
        let bodyStr = message.body as! String
        if (bodyStr == "shareReport") {
            self.rightBarBtnItemClick(sender: UIBarButtonItem.init())
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 析构方法 （回收垃圾）
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "title")
    }
    
    
    // MARK: view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: 友盟分享type
    func shareWebPageToPlatformType(platformType: UMSocialPlatformType, thumbImage: UIImage?) {
        //创建分享消息对象
        let messageObject = UMSocialMessageObject.init()
        let thumb:Any = thumbImage == nil ? self.pageThumbImageUrl ?? "" : thumbImage ?? ""
        //分享消息对象设置分享内容对象 thubImageUrl （链接只针对于Https链接）
        let shareObject = UMShareWebpageObject.shareObject(withTitle: self.title ?? "250你发布", descr: nil, thumImage: thumb)
        
        // 判断是否是年报
        if self.pageUrlStr != nil && self.isYearReportShare != nil && self.isYearReportShare! {
            let pageUrlStrTemp = self.pageUrlStr?.components(separatedBy: "?").first
            self.pageUrlStr = pageUrlStrTemp! + "?userId=\(String(describing: (APP_DELEGATE.currentUserInfo?.id)!))&f=0"
        }
        
        shareObject?.webpageUrl = self.pageUrlStr
        messageObject.shareObject = shareObject
        
        //调用分享接口
        UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self) { (data, error) in
            if (error != nil) {
                MBProgressHUD.show("分享取消", icon: nil, view: self.view)
            } else {
                MBProgressHUD.show("已分享", icon: nil, view: self.view)
            }
        }
        
        // 判断是否是年报 更新分享任务记录
        if self.pageUrlStr != nil && self.pageUrlStr?.range(of: "report") != nil {
            OtherBusiness.shareIntance.responseWebShareTaskNotify(taskShareCode: TaskCodeType.shareYearReport, responseSuccess: { (objectSuccess) in
            }, responseFailed: { (error) in
                // 更新本地碳币数
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_CoinTaskUpdate), object: CoinTaskUpdateType.updateCoinCount.rawValue)
            })
        }
        
    }
    
}

extension WKWebPageViewController {
    func setViewUI() {
        // 设置 webView
        let request: URLRequest?
        if self.localPageUrlFilePath == nil {
            // 加载网页
            if (self.pageUrlStr?.hasPrefix("http"))! {
               request = URLRequest.init(url: URL.init(string: self.pageUrlStr!)!)
            } else {
                let baseHtml = Bundle.main.path(forResource: "QRbase.html", ofType: nil)
                request = URLRequest.init(url: URL.init(fileURLWithPath: baseHtml!))
            }
        } else {
            // 加载本地文件
            request = URLRequest.init(url: URL.init(fileURLWithPath: self.localPageUrlFilePath!))
        }
        
        self.webView.load(request!)
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        if self.isShowShareBtn != nil && self.isShowShareBtn! {
            let rightBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "share_platform"), style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
            self.navigationItem.rightBarButtonItem = rightBarBtnItem
        }
        
        // 设置加载圈
        self.view.addSubview(self.activityView)
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        
        
        // 添加加载进度条
        self.view.addSubview(self.progressView)
        // 添加KVO进度加载方法
        self.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    
    func showLeftNavigationItem(){
        
        let goBackBtn = UIButton.init()
        let closeBtn = UIButton.init()
        
        goBackBtn.setImage(UIImage.init(named: "nav_back"), for: UIControl.State.normal)
        goBackBtn.setTitle(" 返回", for: UIControl.State.normal)
        goBackBtn.addTarget(self, action: #selector(goBack), for: UIControl.Event.touchUpInside)
        goBackBtn.sizeToFit()
        goBackBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        
        let backItem = UIBarButtonItem.init(customView: goBackBtn)
        closeBtn.setTitle("关闭", for: UIControl.State.normal)
        closeBtn.addTarget(self, action: #selector(leftBarBtnItemClick(sender:)), for: UIControl.Event.touchUpInside)
        closeBtn.sizeToFit()
        let closeItem = UIBarButtonItem.init(customView: closeBtn)
        
        let items:[UIBarButtonItem] = [backItem,closeItem]
        self.navigationItem.leftBarButtonItems = items
    }
    
    @objc func goBack(){
        self.webView.goBack()
    }
    
    
    /// 检查返回（pop/goback）
    func checkGoBack(){
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = !self.webView.canGoBack
        if self.webView.canGoBack{
            showLeftNavigationItem()
        }else{
            let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
            self.navigationItem.leftBarButtonItem = leftBarBtnItem
        }
    }
    
    
    // MARK: 在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.progress = Float(self.webView.estimatedProgress)
            if self.progressView.progress == 1 {
                /*
                 *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
                 *动画时长0.25s，延时0.3s后开始动画
                 *动画结束后将progressView隐藏
                 */
                UIView.animate(withDuration: 0.25, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.4)
                }, completion: { (isFinish) in
                    self.progressView.isHidden = true
                })
            }
        } else if keyPath == "title" {
            // 设置title
            if self.showNavTitle == nil {
                self.title = self.webView.title
            }
            
            // 设置网页提供方
            if webView.url?.absoluteString != nil && (webView.url?.absoluteString.hasPrefix("http"))! {
                var webProvideUser = (webView.url?.absoluteString)! as NSString
                
                let startRange = webProvideUser.range(of: "://")
                webProvideUser = webProvideUser.substring(from: startRange.location + startRange.length) as NSString
                
                let endRange = webProvideUser.range(of: "/")
                let result = webProvideUser.substring(with: NSMakeRange(0, endRange.location))
                
                if self.isShowWebPageTrack == nil || self.isShowWebPageTrack! {
                    self.showTopLabel.isHidden = false
                } else {
                    self.showTopLabel.isHidden = true
                }
                self.showTopLabel.text = "网页由 \(result) 提供"
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}


