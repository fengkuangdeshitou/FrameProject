//
//  UIButton+UIButtonBlock.h
//  Ecosphere250Publish
//
//  Created by jointsky on 2017/3/10.
//  Copyright © 2017年 陈帆. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^buttonAction) (UIButton *sender);

@interface UIButton (UIButtonBlock)



/**
 button 扩展block回调方法

 @param actionBtn block action 回调方法
 @param events events
 */
- (void)addTargetWithBlock:(buttonAction)actionBtn andEvent:(UIControlEvents)events;


@end
