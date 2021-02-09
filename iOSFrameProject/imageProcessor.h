//
//  imageProcessor.h
//  photoTest
//
//  Created by 周强 on 16/2/3.
//  Copyright © 2016年 com.jointsky.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol imageProcessorDeleagte <NSObject>


@optional
- (void)imageProcessorWithImage:(UIImage *)outputImage AndSecondImage:(UIImage *)secondImage AndPM25:(NSArray *)array;
- (void)imageProcessorWithImage:(UIImage *)outputImage;
@end

@interface imageProcessor : NSObject

@property (nonatomic,assign) id<imageProcessorDeleagte>delegate;
@property (nonatomic,assign) NSInteger CA;
+ (instancetype)sharedImageProcessor;

- (void)imageProcess:(UIImage *)inputImage;

#pragma mark 根据大气光A值估算PM2.5
- (NSArray *)getPM25ByCA:(double)caValue;


/**
 *  计算大气光值得出的pm2.5范围和周围环境的pm2.5拟合出合理的pm2.5值
 *
 *  @param rangeArray 大气光值计算得到pm2.5范围
 *  @param pm25Value  周围环境的pm2.5值
 *
 *  @return 合理的pm2.5的值
 */
- (NSInteger)fittingCalculationForAToPm25Range:(NSArray *)rangeArray andSurroundingPm25:(NSInteger)pm25Value;

@end
