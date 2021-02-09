//
//  AddressPickerDemo.m
//  BAddressPickerDemo
//
//  Created by 林洁 on 16/1/13.
//  Copyright © 2016年 onlylin. All rights reserved.
//

#import "AddressPickerDemo.h"
#import "BAddressPickerController.h"

@interface AddressPickerDemo ()<BAddressPickerDelegate,BAddressPickerDataSource>

@end

@implementation AddressPickerDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.title = @"城市选择";
    NSDictionary *titleTextDic;
    titleTextDic = @{NSFontAttributeName:[UIFont systemFontOfSize:18.0], NSForegroundColorAttributeName:
                         [UIColor blackColor]};
    self.navigationController.navigationBar.titleTextAttributes = titleTextDic;
    self.navigationController.navigationBar.tintColor =
    [UIColor darkGrayColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    // 导航栏中左边的按钮
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemClick:)];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    if (self.isShowAll) {
        UIBarButtonItem *rightBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick:)];
        self.navigationItem.rightBarButtonItem = rightBarBtnItem;
    }
    
    BAddressPickerController *addressPickerController = [[BAddressPickerController alloc] initWithFrame:self.view.frame];
    addressPickerController.dataSource = self;
    addressPickerController.delegate = self;
    
    [self addChildViewController:addressPickerController];
    [self.view addSubview:addressPickerController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 导航栏中左边的按钮点击的响应的方法
- (void)leftBarButtonItemClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 导航栏中右边的按钮点击的响应的方法
- (void)rightBarButtonItemClick:(UIBarButtonItem *)sender {
    if ([self.addressDelegate respondsToSelector:@selector(AddressPickerDemo:DidSelectedCity:)]) {
        [self.addressDelegate AddressPickerDemo:self DidSelectedCity:self.navigationItem.rightBarButtonItem.title];
    }
}

#pragma mark - BAddressController Delegate
- (NSArray*)arrayOfHotCitiesInAddressPicker:(BAddressPickerController *)addressPicker{
    return @[@"北京",@"上海",@"深圳",@"杭州",@"广州",@"武汉",@"天津",@"重庆",@"成都",@"西安"];
}


- (void)addressPicker:(BAddressPickerController *)addressPicker didSelectedCity:(NSString *)city{
    if ([self.addressDelegate respondsToSelector:@selector(AddressPickerDemo:DidSelectedCity:)]) {
        [self.addressDelegate AddressPickerDemo:self DidSelectedCity:city];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)beginSearch:(UISearchBar *)searchBar{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)endSearch:(UISearchBar *)searchBar{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


// MARK: view did appear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:true];
}


/**
 根据城市名称获取城市相关信息（城市中心坐标， 区域编码）
 
 @param cityName 城市名称
 @return 城市相关信息字典
 */
+ (NSDictionary *)getCityRelativeInfoWith:(NSString *)cityName {
    if (!cityName) {
        return nil;
    }
    // 统一的城市数据选择
    NSDictionary *cityCodeDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"citysCode"];
    
    // 网络城市数据
    for (NSDictionary *dictData in [cityCodeDict objectForKey:@"children"]) {
        NSArray *subCitysArray = [dictData objectForKey:@"children"];
        if (subCitysArray.count == 0 || [subCitysArray isEqual:@""]) {   // 直辖市
            if ([[dictData objectForKey:@"regionName"] hasPrefix:cityName] || [cityName isEqual:[dictData objectForKey:@"regionName"]]) {
                return dictData;
            }
        } else {
            for (NSDictionary *dictDataSub in subCitysArray) {
                if ([[dictDataSub objectForKey:@"regionName"] hasPrefix:cityName] || [cityName isEqual:[dictDataSub objectForKey:@"regionName"]]) {
                    return dictDataSub;
                }
            }
        }
    }
    
    return nil;
}



/**
 根据城市的regionCode获取城市相关信息（城市中心坐标， 区域编码）
 
 @param regionCode 城市名称
 @return 城市相关信息字典
 */
+ (NSDictionary *)getCityRelativeInfoWithRegion:(NSString *)regionCode {
    // 统一的城市数据选择
    NSDictionary *cityCodeDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"citysCode"];
    
    // 网络城市数据
    for (NSDictionary *dictData in [cityCodeDict objectForKey:@"children"]) {
        NSArray *subCitysArray = [dictData objectForKey:@"children"];
        if (subCitysArray.count == 0 || [subCitysArray isEqual:@""]) {   // 直辖市
            if ([regionCode isEqual:[dictData objectForKey:@"regionCode"]]) {
                return dictData;
            }
        } else {
            for (NSDictionary *dictDataSub in subCitysArray) {
                if ([regionCode isEqual:[dictDataSub objectForKey:@"regionCode"]]) {
                    return dictDataSub;
                }
            }
        }
    }
    
    return nil;
}

// 字符串进行UTF8编码
+ (NSString *)stringAddEncodeWithString:(NSString *)str {
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// 字符串进行UTF8解码
+ (NSString *)stringReplaceEncodeWithString:(NSString *)str {
    NSMutableString *mutable = [[NSMutableString alloc] initWithString:str];
    NSString *testString = [mutable stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    
    return [testString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// MARK: 隐藏手机中间4位为*号
+ (NSString *)stringPhoneNumEncodeStartWithString:(NSString *)str {
    return  [str stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
}



/**
 根据当前城市截取首部的省份和城市

 @param address 详细地址信息
 @param city 当前城市
 @return 显示的地址信息
 */
+ (NSString *)getReadCityAddressWithAddressStr:(NSString *)address andCurrentCity:(NSString *)city {
    if (city == nil) {
        return address;
    }
    NSRange cityRange = [address rangeOfString:city];
    if (cityRange.location != NSNotFound) {
        // 包含
        return [address substringFromIndex:cityRange.location + cityRange.length];
    }
    
    return address;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
