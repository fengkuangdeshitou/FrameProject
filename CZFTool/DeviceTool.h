
//
//  DeviceTool.h
//  getIPhoneInfo
//
//  Created by jointsky on 2017/2/13.
//  Copyright © 2017年 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DeviceTool : NSObject


/**
 *  可读格式化存储大小
 *
 *  @param size 存储大小   单位：B
 *
 *  @return B, K, M, G 为单位
 */
+ (NSString *)fileSizeWithInterge:(unsigned long long)size;


// 获取设备型号然后手动转化为对应名称
+ (NSString *)getDeviceName;

+ (NSString *)getMacAddress;

+ (NSString *)getDeviceIPAddresses;

+(NSString *)deviceModel;

/**
 获取运营商信息
 
 @return name
 */
+ (NSString *)getCarrierName;

/**
 设备总的存储空间
 
 @return 大小
 */
+(NSString *)deviceAllSize;


/**
 设备未使用的空间大小
 
 @return 大小
 */
+(NSString *)deviceUnUseSize;


/**
 物理内存大小
 
 @return 格式化大小
 */
+(NSString *)devicePhysicalRunTimeSize;


/**
 可使用内存大小
 
 @return 大小
 */
+(NSString *)deviceUnUsePhysicalRunTimeSize;


+(NSString *)myNumber;

@end
