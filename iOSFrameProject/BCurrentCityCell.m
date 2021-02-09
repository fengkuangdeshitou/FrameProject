//
//  BCurrentCityCell.m
//  Bee
//
//  Created by 林洁 on 16/1/12.
//  Copyright © 2016年 Lin. All rights reserved.
//

#import "BCurrentCityCell.h"
#import "BAddressHeader.h"

@implementation BCurrentCityCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = BG_CELL;
        [self.contentView addSubview:self.GPSButton];
        [self.contentView addSubview:self.activityIndicatorView];
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.locationManager];
        [self setUp];
    }
    return self;
}

- (void)setUp{
    [self.locationManager startWithBlock:^{
        [self.GPSButton setHidden:YES];
        [self.activityIndicatorView startAnimating];
        
        // 设置定位时长
        self.runLoopCount = 0;
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(runLoopTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        [self.timer fire];
        self.isLocaling = YES;
    } completionBlock:^(CLLocation *location) {
        
        // 开始定位
        [self.searchManager startReverseGeocode:location completeionBlock:^(LNLocationGeocoder *locationGeocoder, NSError *error) {
            self.isLocaling = NO;
            if (!error) {
                [self.activityIndicatorView stopAnimating];
                [self.label setHidden:YES];
                NSMutableString *mutableString = [NSMutableString stringWithFormat:@"%@",locationGeocoder.city];
                NSString *title = [mutableString stringByReplacingOccurrencesOfString:@"市" withString:@""];
                [self.GPSButton setTitle:title forState:UIControlStateNormal];
                [self.GPSButton setHidden:NO];
                self.GPSButton.userInteractionEnabled = YES;
                if (![title hasSuffix:@"市"] && ![title hasSuffix:@"地区"] && ![title hasSuffix:@"自治州"]) {
                    title = [NSString stringWithFormat:@"%@市", title];
                }
                
                YN = 1;
            } else {
                [self.activityIndicatorView stopAnimating];
                [self.label setHidden:YES];
                [self.GPSButton setTitle:@"定位失败" forState:UIControlStateNormal];
                self.GPSButton.userInteractionEnabled = NO;
                self.GPSButton.alpha = 0.6;
                [self.GPSButton setHidden:NO];
                
                YN = 0;
                
            }
        }];
    } failure:^(CLLocation *location, NSError *error) {
        
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Event Response
- (void)buttonWhenClick:(void (^)(UIButton *))block{
    self.buttonClickBlock = block;
}

- (void)buttonClick:(UIButton*)button{
    self.buttonClickBlock(button);
}

#pragma mark - Getter and Setter
- (UIButton*)GPSButton{
    if (_GPSButton == nil) {
        _GPSButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _GPSButton.frame = CGRectMake(15, 15 , BUTTON_WIDTH, BUTTON_HEIGHT);
        [_GPSButton setTitle:@"" forState:UIControlStateNormal];
        _GPSButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _GPSButton.tintColor = [UIColor blackColor];
        _GPSButton.backgroundColor = [UIColor whiteColor];
        _GPSButton.alpha = 0.8;
        _GPSButton.layer.borderColor = [UIColorFromRGBA(237, 237, 237, 1.0) CGColor];
        _GPSButton.layer.borderWidth = 1;
        _GPSButton.layer.cornerRadius = 3;
        [_GPSButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _GPSButton;
}

- (UIActivityIndicatorView*)activityIndicatorView{
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(15, 15, BUTTON_HEIGHT, BUTTON_HEIGHT)];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _activityIndicatorView.color = [UIColor grayColor];
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
}

- (UILabel*)label{
    if (_label == nil) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(15 + BUTTON_HEIGHT, 15, BUTTON_WIDTH, BUTTON_HEIGHT)];
        _label.text = @"定位中...";
        _label.font = [UIFont systemFontOfSize:16.0f];
    }
    return _label;
}

- (LNLocationManager*)locationManager{
    if (_locationManager == nil) {
        _locationManager = [[LNLocationManager alloc] init];
    }
    return _locationManager;
}

- (LNSearchManager*)searchManager{
    if (_searchManager == nil) {
        _searchManager = [[LNSearchManager alloc] init];
    }
    return _searchManager;
}


/**
 *  计时定位的时长的方法
 */
- (void)runLoopTimer:(NSTimer *)sender {
    self.runLoopCount++;
    
    if (self.runLoopCount >= 20-1 &&  YN != 1) {
        self.runLoopCount = 0;
        [self.activityIndicatorView stopAnimating];
        [self.label setHidden:YES];
        [self.GPSButton setTitle:@"定位失败" forState:UIControlStateNormal];
        self.GPSButton.userInteractionEnabled = NO;
        self.GPSButton.alpha = 0.6;
        [self.GPSButton setHidden:NO];
        self.isLocaling = NO;
    }
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
