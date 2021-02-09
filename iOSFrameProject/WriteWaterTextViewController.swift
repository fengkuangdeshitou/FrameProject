//
//  WriteWaterTextViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/18.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit


/// 编写水印类型
///
/// - shortText: 短水印类型
/// - longText: 长水印类型
enum WriteWaterTextType {
    case shortText
    case longText
}

protocol WriteWaterViewDelegate: NSObjectProtocol {
    func writeWaterTextSuccess(textView: UITextView, pasterView: Paster?)
    func editeCancel()
}


class WriteWaterTextViewController: UIViewController, UITextViewDelegate {
    weak var delegate: WriteWaterViewDelegate?
    
    var indexTag: Int?
    
    var pasterView: Paster?
    
    fileprivate var isShowTip = true
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var sureBtn: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var remainTextLabel: UILabel!
    
    // 字体列表
//    ["FZFangSong-Z02",
//    "FZKai-Z03",
//    "FZLiShu-S01",
//    "FZMeiHei-M07",
//    "FZShuSong-Z01",
//    "FZWeiBei-S03 -GBK1-0"]
    let typefaceList:[String] = ["Heiti SC",
                                 "Copperplate",
                                 "Hiragino Mincho ProN",
                                 "Bradley Hand",
                                 "Savoye LET",
                                 "PingFang SC"]
    
    // 颜色列表
    let colorList:[Int] = [0xffffff, 0x000000, 0xf49ac1, 0xfc5151, 0x1cbbb4, 0xa67c52]
    
    
    fileprivate lazy var keyBoradTopView: UIView = {
        let gap: CGFloat = 5
        let topView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CELL_NORMAL_HEIGHT))
        topView.backgroundColor = UIColor.white
        
        // 字体
        let typefaceScrollView = UIScrollView.init(frame: topView.frame)
        typefaceScrollView.width = SCREEN_WIDTH / 2
        let typefaceBtnW: CGFloat = 46
        let typefaceBtnH: CGFloat = 30
        for i in 0..<self.typefaceList.count {
            let subButton = UIButton.init(frame: CGRect(x: CGFloat(i) * typefaceBtnW + CGFloat(i+1) * gap, y: (topView.height - typefaceBtnH) / 2, width: typefaceBtnW, height: typefaceBtnH))
        
            subButton.setTitle("字体", for: UIControl.State.normal)
            subButton.titleLabel?.font = UIFont.init(name: self.typefaceList[i], size: FONT_STANDARD_SIZE)
//            UIFont.asynchronouslySetFontName(self.typefaceList[i], andCallBack: { (fontName) in
//                subButton.titleLabel?.font = UIFont.init(name: fontName!, size: FONT_STANDARD_SIZE)
//            })
            subButton.layer.masksToBounds = true
            subButton.layer.cornerRadius = typefaceBtnH / 2
            subButton.layer.borderColor = COLOR_DARK_GAY.cgColor
            subButton.layer.borderWidth = BORDER_WIDTH
            subButton.setTitleColor(COLOR_DARK_GAY, for: UIControl.State.normal)
            subButton.addTarget(self, action:#selector(typefaceBtnsClick(sender:)), for: UIControl.Event.touchUpInside)
            subButton.tag = i
            typefaceScrollView.addSubview(subButton)
        }

        // 设置分割线
        let separateLineView = UIView.init(frame: CGRect(x: SCREEN_WIDTH / 2 - 1, y: 0, width: 0.5, height: topView.height))
        separateLineView.backgroundColor = COLOR_SEPARATOR_LINE
        topView.addSubview(typefaceScrollView)
        topView.addSubview(separateLineView)
        
        
        // 颜色
        let colorScrollView = UIScrollView.init(frame: topView.frame)
        colorScrollView.width = SCREEN_WIDTH / 2
        colorScrollView.x = SCREEN_WIDTH / 2
        for i in 0..<self.colorList.count {
            let subButton = UIButton.init(frame: CGRect(x: CGFloat(i) * typefaceBtnW + CGFloat(i+1) * gap, y: (topView.height - typefaceBtnH) / 2, width: typefaceBtnH, height: typefaceBtnH))
            subButton.backgroundColor = UIColorFromRGB(rgbValue: self.colorList[i])
            subButton.layer.masksToBounds = true
            subButton.layer.cornerRadius = typefaceBtnH / 2
            subButton.layer.borderColor = UIColor.white.cgColor
            subButton.layer.borderWidth = BORDER_WIDTH * 2
            subButton.setTitleColor(COLOR_DARK_GAY, for: UIControl.State.normal)
            subButton.addTarget(self, action:#selector(colorBtnsClick(sender:)), for: UIControl.Event.touchUpInside)
            subButton.tag = i
            colorScrollView.addSubview(subButton)
        }
    
        topView.addSubview(colorScrollView)
        
        typefaceScrollView.contentSize = CGSize(width: CGFloat(self.typefaceList.count) * typefaceBtnW + CGFloat(self.typefaceList.count+1) * gap, height: 20)
        colorScrollView.contentSize = CGSize(width: CGFloat(self.colorList.count) * typefaceBtnW + CGFloat(self.colorList.count+1) * gap, height: 20)
        colorScrollView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        
        return topView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for familyName in UIFont.familyNames {
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                myPrint(message: "fontName: \(fontName)")
            }
        }
        // 初始化
        self.view.tag = self.indexTag!
        self.sureBtn.layer.masksToBounds = true
        self.sureBtn.layer.cornerRadius = CORNER_SMART
        
        if self.pasterView != nil {
            if self.pasterView?.classForCoder == ImagePaster.classForCoder() {
                // 天气贴图
                let imagePaster = self.pasterView as! ImagePaster
                self.textView.text = imagePaster.textStr
            } else {
                let textPaster = self.pasterView as! TextPaster
                self.textView.text = textPaster.text
            }
            
        }
        switch self.view.tag {
        case 0:
            self.remainTextLabel.text = String(WORDCOUNT_WATER_MARK_SHORT)
        default:
            self.remainTextLabel.text = String(WORDCOUNT_WATER_MARK_LONG)
            self.textView.inputAccessoryView = self.keyBoradTopView
        }
        
        self.textView.layer.masksToBounds = true
        self.textView.layer.cornerRadius = CORNER_NORMAL
        self.textView.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.textView.becomeFirstResponder()
        self.textView.delegate = self
        self.textView.font = UIFont.systemFont(ofSize: FONT_BIG_SIZE)
        
        self.textViewDidChange(self.textView)
    }
    
    
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.editeCancel()
        }
    }
    
    @IBAction func sureBtnClick(_ sender: UIButton) {
        //   截取过长的字符串
        switch self.view.tag {
        case 0:
            // 水印
            if self.textView.text.count > WORDCOUNT_WATER_MARK_SHORT {
                self.textView.text = CUTString(textStr: self.textView.text, start: 0, length: WORDCOUNT_WATER_MARK_SHORT)
            }
        default:
            // 纯文字
            if self.textView.text.count > WORDCOUNT_WATER_MARK_LONG  {
                self.textView.text = CUTString(textStr: self.textView.text, start: 0, length: WORDCOUNT_WATER_MARK_LONG)
            }
        }
        
        
        
        self.dismiss(animated: true) {
            self.textView.tag = self.view.tag
            self.delegate?.writeWaterTextSuccess(textView: self.textView, pasterView: self.pasterView)
        }
    }
    
    
    // MARK: - UITextViewDelegate 代理方法的实现
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count
        
        var Length = 0
        switch self.view.tag {
        case 0:
            Length = WORDCOUNT_WATER_MARK_SHORT
        default:
            Length = WORDCOUNT_WATER_MARK_LONG
        }
        
        if textLength <= Length - 1 {
            self.remainTextLabel.textColor = UIColor.white
        } else {
            if self.isShowTip {
                MBProgressHUD.show("超过的字符将不能被提交", icon: nil, view: self.view)
                self.isShowTip = false
            }
            self.remainTextLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        }
        self.remainTextLabel.text = "\(Length - textLength)"
    }
    
    
    // MARK: 字体按钮点击
    @objc func typefaceBtnsClick(sender: UIButton) {
        let familyName = self.typefaceList[sender.tag]
        self.textView.font = UIFont.init(name: familyName, size: FONT_BIG_SIZE)
//        UIFont.asynchronouslySetFontName(self.typefaceList[sender.tag]) { (fontName) in
//            self.textView.font = UIFont.init(name: self.typefaceList[sender.tag], size: FONT_BIG_SIZE)
//        }
    }
    
    // MARK: 颜色按钮点击
    @objc func colorBtnsClick(sender: UIButton) {
        self.textView.textColor = UIColorFromRGB(rgbValue: self.colorList[sender.tag])
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
