//
//  BCurrentCityCell.h
//  Bee
//
//  Created by 林洁 on 16/1/12.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNLocationManager.h"
#import "LNSearchManager.h"

@interface BCurrentCityCell : UITableViewCell {
    
    int YN;
}

@property (nonatomic, strong) UIButton *GPSButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) LNLocationManager *locationManager;

@property (nonatomic, strong) LNSearchManager *searchManager;

@property (nonatomic, strong) NSTimer *timer;       // 计时定位的时间

@property (nonatomic, assign) int runLoopCount;     // 循环的次数

@property (nonatomic, assign) BOOL isLocaling;      // 是否正在定位

@property (nonatomic, copy) void (^buttonClickBlock)(UIButton *button);

- (void)buttonWhenClick:(void(^)(UIButton *button))block;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com