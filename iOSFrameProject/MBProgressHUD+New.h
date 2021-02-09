//
//  MBProgressHUD+MJ.h
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (New)
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view;  // 按时间显示窗口

// 底部按时间显示窗口
+ (void)showBottom:(NSString *)text icon:(NSString *)icon view:(UIView *)view;

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;      // 弹出成功显示窗口
+ (void)showError:(NSString *)error toView:(UIView *)view;          // 弹出错误显示窗口

+ (MBProgressHUD *)showMessage:(NSString *)mess toView:(UIView *)view; // 弹出加载和显示信息窗口

+ (MBProgressHUD *)showLoadingtoView:(UIView *)view;


/**
 *  显示自定义加载（可以加载gif动态图片）
 *
 *  @param strIcon 图片地址
 *  @param strText 提示文字
 *  @param view    所在的view
 *
 *  @return 返回MBProgressHUB 对象
 */
+ (MBProgressHUD *)showLoadingCustomIconStr:(NSString *)strIcon andText:(NSString *)strText andToView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)mess;

#pragma mark 显示加载title 和进度
+ (MBProgressHUD *)showMessage:(NSString *)mess toView:(UIView *)view AndProcess:(float)processValue;

+ (void)hideHUDForView:(UIView *)view;  // 隐藏窗口
+ (void)hideHUD;

@end
