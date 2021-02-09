//
//  UIButton+UIButtonBlock.m
//  Ecosphere250Publish
//
//  Created by jointsky on 2017/3/10.
//  Copyright © 2017年 陈帆. All rights reserved.
//

#import "UIButton+UIButtonBlock.h"

#import <objc/runtime.h>


static id associateKey;

@implementation UIButton (UIButtonBlock)


/**
 button 扩展block回调方法
 
 @param btnAction block action 回调方法
 @param events events
 */
- (void)addTargetWithBlock:(buttonAction)btnAction andEvent:(UIControlEvents)events {
    
    objc_setAssociatedObject(self, &associateKey, btnAction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addTarget:self action:@selector(buttonClick:) forControlEvents:events];
}


// button click
- (void)buttonClick:(UIButton *)sender {
    buttonAction btnAction = objc_getAssociatedObject(self, &associateKey);
    
    if (btnAction) {
        btnAction(sender);
    }
}

@end
