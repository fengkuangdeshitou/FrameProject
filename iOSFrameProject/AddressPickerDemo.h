//
//  AddressPickerDemo.h
//  BAddressPickerDemo
//
//  Created by 林洁 on 16/1/13.
//  Copyright © 2016年 onlylin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressPickerDemo;
@protocol AddressPickerDemoDelegate <NSObject>

@optional
- (void)AddressPickerDemo:(AddressPickerDemo *)addressDemo DidSelectedCity:(NSString *)city;

@end

@interface AddressPickerDemo : UIViewController

@property (assign, nonatomic) id<AddressPickerDemoDelegate> addressDelegate;

@property (assign, nonatomic) BOOL isShowAll;

/**
 根据城市名称获取城市相关信息（城市中心坐标， 区域编码）
 
 @param cityName 城市名称
 @return 城市相关信息字典
 */
+ (NSDictionary *)getCityRelativeInfoWith:(NSString *)cityName;

/**
 根据城市的regionCode获取城市相关信息（城市中心坐标， 区域编码）
 
 @param regionCode 城市名称
 @return 城市相关信息字典
 */
+ (NSDictionary *)getCityRelativeInfoWithRegion:(NSString *)regionCode;


/**
 根据当前城市截取首部的省份和城市
 
 @param address 详细地址信息
 @param city 当前城市
 @return 显示的地址信息
 */
+ (NSString *)getReadCityAddressWithAddressStr:(NSString *)address andCurrentCity:(NSString *)city;


// 字符串进行UTF8编码
+ (NSString *)stringAddEncodeWithString:(NSString *)str;

// 字符串进行UTF8解码
+ (NSString *)stringReplaceEncodeWithString:(NSString *)str;

// MARK: 隐藏手机中间4位为*号
+ (NSString *)stringPhoneNumEncodeStartWithString:(NSString *)str;

@end
