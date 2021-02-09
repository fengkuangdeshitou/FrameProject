//
//  JMTabBarController.m
//  JMTabBarController
//
//  Created by JM on 2017/12/26.
//  Copyright © 2017年 JM. All rights reserved.
//
// github: https://github.com/JunAILiang
// blog: https://www.ljmvip.cn

#import "JMTabBarController.h"
#import "UIView+JM.h"
#import <AVFoundation/AVFoundation.h>

@interface JMTabBarController ()<JMTabBarDelegate>

@end

@implementation JMTabBarController

- (instancetype)initWithTabBarControllers:(NSArray *)controllers NorImageArr:(NSArray *)norImageArr SelImageArr:(NSArray *)selImageArr TitleArr:(NSArray *)titleArr Config:(JMConfig *)config{
    self = [super init];
    if (self) {
        self.viewControllers = controllers;
        self.JM_TabBar = [[JMTabBar alloc] initWithFrame:self.tabBar.frame norImageArr:norImageArr SelImageArr:selImageArr TitleArr:titleArr Config:config];
        self.JM_TabBar.myDelegate = self;
        self.JM_TabBar.height = 44.0;
    //    [self.JM_TabBar setHidden:true];
        self.JM_TabBar.y = [UIScreen mainScreen].bounds.size.height - self.JM_TabBar.height;
        
        [self setValue:self.JM_TabBar forKeyPath:@"tabBar"];

        
        [JMConfig shareConfig].tabBarController = self;
        
        //KVO
        [self addObserver:self forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSInteger selectedIndex = [change[@"new"] integerValue];
    self.JM_TabBar.selectedIndex = selectedIndex;
}

- (void)tabBar:(JMTabBar *)tabBar didSelectIndex:(NSInteger)selectIndex {
    self.selectedIndex = selectIndex;
    
    [self soundSourceWithName:@"button_click.mp3"];
}

- (BOOL)willShowSelectViewWith:(JMTabBar *)tabBar didSelectIndex:(NSInteger)selectIndex {
    
    BOOL isNext = true;
    if ([self.mmDelegate respondsToSelector:@selector(willShowSelectViewDidSelectIndex:)]) {
        isNext = [self.mmDelegate willShowSelectViewDidSelectIndex:selectIndex];
    }
    
    return isNext;
}


- (void)setTabBarHide:(BOOL)isHide {
//    [UIView animateWithDuration:0.25 animations:^{
//        if (isHide) {
//            self.tabBar.y = [UIScreen mainScreen].bounds.size.height;
//        } else {
//            self.tabBar.y = [UIScreen mainScreen].bounds.size.height - 49;
//        }
//    } completion:^(BOOL finished) {
//        self.tabBar.hidden = isHide;
//    }];
    
}

// MARK: 设置声音
- (void)soundSourceWithName:(NSString *)sourceName {
    NSURL *url = [[NSBundle mainBundle] URLForResource:sourceName withExtension:nil];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)dealloc {
    JMLog(@"被销毁了");
    [self removeObserver:self forKeyPath:@"selectedIndex"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


@end
