//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+New.h"
#import "UIImage+GIF.h"

@implementation MBProgressHUD (New)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [self window];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    if ([UIScreen mainScreen].bounds.size.width <= 320) {
        hud.detailsLabelText = text;
    } else {
        hud.labelText = text;
    }
    
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    hud.animationType = MBProgressHUDAnimationFade;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;

    // 1.5秒之后再消失
    [hud hide:YES afterDelay:1.5];
}


#pragma mark 底部显示信息
+ (void)showBottom:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [self window];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.yOffset = [UIScreen mainScreen].bounds.size.height / 2 - 50;
    hud.detailsLabelText = text;
    
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    hud.animationType = MBProgressHUDAnimationFade;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1.5秒之后再消失
    [hud hide:YES afterDelay:1.5];
}




#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)mess toView:(UIView *)view {
    if (view == nil) view = [self window];//[[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = mess;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    
    return hud;
}


#pragma mark 显示加载title 和进度
+ (MBProgressHUD *)showMessage:(NSString *)mess toView:(UIView *)view AndProcess:(float)processValue {
    if (view == nil) view = [self window];//[[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = mess;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.progress = processValue;
    
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    
    return hud;
    
}


/**
 *  显示小加载圈加载
 */
+ (MBProgressHUD *)showLoadingtoView:(UIView *)view {
    if (view == nil) view = [self window];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = @"";
    hud.opacity = 0.2;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    
    return hud;
}


/**
 *  显示自定义加载（可以加载gif动态图片）
 *
 *  @param strIcon 图片地址
 *  @param strText 提示文字
 *  @param view    所在的view
 *
 *  @return 返回MBProgressHUB 对象
 */
+ (MBProgressHUD *)showLoadingCustomIconStr:(NSString *)strIcon andText:(NSString *)strText andToView:(UIView *)view {
    if (view == nil) view =  [self window];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud.labelText = strText == nil ? @"" : strText;
    //hud.opacity = 0.;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage sd_animatedGIFNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", strIcon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    hud.animationType = MBProgressHUDAnimationFade;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = NO;
    
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)mess
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; // 顶部菜单栏显示加载小圈
    return [self showMessage:mess toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [self window];
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 顶部菜单栏显示加载小圈
    [self hideHUDForView:nil];
}


+ (UIWindow *)window{
    
    return [UIApplication sharedApplication].keyWindow;
}

@end
