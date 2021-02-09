//
//  XCEmotionTool.m
//  JGGDemo
//
//  Created by gao bin on 2018/2/9.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "XCEmotionTool.h"
#import "XCEmotionModel.h"
// 最近使用表情的存储路径
#define XCRecentEmotionsPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"emotions.archive"]


@implementation XCEmotionTool

static NSMutableArray   *_recentEmotions;

/** 最近使用的表情  */
+ (void)initialize
{
    // 解档读取此目录下是否有数据
    _recentEmotions = [NSKeyedUnarchiver unarchiveObjectWithFile:XCRecentEmotionsPath];
    if (_recentEmotions == nil) {
        
        _recentEmotions = [NSMutableArray array];
    }
}


+ (void)addRecentEmotion:(XCEmotionModel *)emotion
{
    // 删除重复的表情
    [_recentEmotions removeObject:emotion];
    
    // 将表情放到数组的最前面
    [_recentEmotions insertObject:emotion atIndex:0];
    
    if (_recentEmotions.count > 20) {
        [_recentEmotions removeLastObject];
    }
    
    // 将所有的表情数据写入沙盒
    [NSKeyedArchiver archiveRootObject:_recentEmotions toFile:XCRecentEmotionsPath];
}

/**
 *  返回装着HWEmotion模型的数组
 */
+ (NSArray *)recentEmotions
{
    return _recentEmotions;
}



static NSArray  *_defaultEmotions , *_lxhEmotions , *_qqEmtions ;
/*  默认表情数据   **/
+ (NSArray *)defaultEmotions
{
    if (!_defaultEmotions) {
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"XEmotionIcons" ofType:@"bundle"];
        NSString * path = [NSString stringWithFormat:@"%@/default/info.plist",bundlePath];
        
        NSArray *emotionArr = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *emotionModelArr = [NSMutableArray array];
        for (NSDictionary *dic in emotionArr) {
            XCEmotionModel *emotionModel = [[XCEmotionModel alloc] initWithDic:dic];
            [emotionModelArr addObject:emotionModel];
        }
        _defaultEmotions = (NSArray *)emotionModelArr;
    }
    return _defaultEmotions;
}

/**  浪小花   */
+(NSArray *)lxhEmtions
{
    if (!_lxhEmotions) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"XEmotionIcons" ofType:@"bundle"];
        NSString * path = [NSString stringWithFormat:@"%@/lxh/info.plist",bundlePath];
        
        NSArray *emotionArr = [NSArray arrayWithContentsOfFile:path];
                
        NSMutableArray *emotionModelArr = [NSMutableArray array];
        for (NSDictionary *dic in emotionArr) {
            XCEmotionModel *emotionModel = [[XCEmotionModel alloc] initWithDic:dic];
            emotionModel.xcemotionType = XCentionModelTypeLxh ; //设置为浪小花表情
            [emotionModelArr addObject:emotionModel];
        }
        _lxhEmotions = (NSArray *)emotionModelArr;
    }
    return _lxhEmotions;
}

+(NSArray *)qqEmtions
{
    if (!_qqEmtions) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"XEmotionIcons" ofType:@"bundle"];
        NSString * path = [NSString stringWithFormat:@"%@/QQEmotion/QQEmtion.plist",bundlePath];
        
        NSArray *emotionArr = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *emotionModelArr = [NSMutableArray array];
        for (NSDictionary *dic in emotionArr) {
            XCEmotionModel *emotionModel = [[XCEmotionModel alloc] initWithDic:dic];
            emotionModel.xcemotionType = XCentionModelTypeQQ ; //设置为qq表情
            [emotionModelArr addObject:emotionModel];
        }
        _qqEmtions = (NSArray *)emotionModelArr;
    }
    return _qqEmtions;
}

+(UIImage *)getSelectEmtionImage:(XCEmotionModel *)emtionModel
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"XEmotionIcons" ofType:@"bundle"];
    NSString * path;
    
    switch (emtionModel.xcemotionType) {
        case XCentionModelTypeDefault: //默认表情
            path = [NSString stringWithFormat:@"%@/default",bundlePath];
            break;
        case XCentionModelTypeLxh:
            path = [NSString stringWithFormat:@"%@/lxh",bundlePath];
            break;
        case XCentionModelTypeQQ:
            path = [NSString stringWithFormat:@"%@/QQEmotion",bundlePath];
            break;
        default:
            break;
    }
    
    UIImage *img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",path,emtionModel.png]];
    return img ;
}

+(XCEmotionModel *)emotionWithChs:(NSString *)chs
{
    NSArray *defaultEmotions = [self defaultEmotions];
    for (XCEmotionModel *emotion in defaultEmotions) {
        if ([emotion.chs isEqualToString:chs]) return emotion;
    }
    
    NSArray *lxhEmotions = [self lxhEmtions];
    for (XCEmotionModel *emotion in lxhEmotions) {
        if ([emotion.chs isEqualToString:chs]) return emotion;
    }
    
    NSArray *qqEmtions = [self qqEmtions];
    for (XCEmotionModel *emotion in qqEmtions) {
        if ([emotion.chs isEqualToString:chs]) return emotion;
    }
    return nil;
}



@end
